// Ports library demo, blinks leds on all 4 ports in slightly different ways
// 2009-02-13 <jcw@equi4.com> http://opensource.org/licenses/mit-license.php
// $Id: blink_ports.pde 5402 2010-04-30 19:24:52Z jcw $

#include <Ports.h>
#include <RF12.h> // needed to avoid a linker error :(
#include <avr/sleep.h>
#include <OneWire.h>
#include <payload.h>

Port FlowPump (3); // The flow pump measurement
//Port Temp (3); // 3 x DS18B20 temp sensors measuring panel in/out temp and outside temp
Port heater (4); // gives power to the heater electronics
Port floorPump (3);  // the floor pump driver (fet) port 3 Dio
Port solarPump (3);  // the solar pump driver (fet) port 3 Aio

OneWire ds18b20 (7); // 1-wire temperature sensors, uses DIO port 4
uint8_t oneID[8];

static uint8_t initOneWire () {
    if (ds18b20.search(oneID)) {
        Serial.print(" 1-wire");
        for (uint8_t i = 0; i < 8; ++i) {
            Serial.print(' ');
            Serial.print(oneID[i], HEX);
        }
        Serial.println();
    }
    ds18b20.reset();
}

static void askTemp1Wire()
{
    ds18b20.reset();
    ds18b20.skip();
    ds18b20.write(0x4E); // write to scratchpad
    ds18b20.write(0);
    ds18b20.write(0);
    ds18b20.write(0x1F); // 9-bits is enough, measurement takes 94 msec
    ds18b20.reset();
    ds18b20.skip();
    ds18b20.write(0x44, 1); // start conversion, parasite pull up on the end
}

/**
 * Call after 750ms afther askTemp1Wire
 */
static int readTemp1wire () {
  ds18b20.reset();
  // ds18b20.select(oneID);
//  ds18b20.skip();
  ds18b20.write(0xBE); // read scratchpad
  uint8_t data[9];
  for (uint8_t j = 0; j < 9; ++j)
      data[j] = ds18b20.read();
  ds18b20.reset();
  if (OneWire::crc8(data, 8) != data[8]) {
      Serial.println(" crc? ");
      return 0;
  }
//  else { 
//    Serial.print("Data read: '"); 
//    for (uint8_t j = 0; j < 9; ++j)
//      Serial.print(data[j], HEX);
//  }
  
  return ((data[1] << 8) + data[0]) * 10 >> 4; // degrees * 10
}

MilliTimer sendTimerPanel; // to time sending msgs 
unsigned long receivedTime = 0; // to expire pump on message
byte needToSend = false;
boolean tempAsked = false;
casitaData payloadData;
int panelOut; // holds the panel out temp
int tankInStart, tankInTop; //store tankin when panel pump starts and the top tenp it hits
boolean up, down = false; // cycle the solarpanel pump
unsigned long cycleTimer; //timer for the panel pump cycle

volatile int NbTopsFan; //measuring the rising edges of the signal
int Calc;                               
//int hallsensor = 2;    //The pin location of the sensor

/**
 * Interupt controller for the flow meter
 */
void rpm ()     //This is the function that the interupt calls 
{ 
  NbTopsFan++;  //This function measures the rising and falling edge of the hall effect sensors signal
}


/**
 * Function receive data
 */
void receive () {
  // data from the thermostat
  if (rf12_recvDone() && rf12_crc == 0 && (RF12_HDR_MASK & rf12_hdr) == 16) {
    roomBoard* buf =  (roomBoard*) rf12_data;

    payloadData.floorPump = buf->heat;
//    payloadData.fpPwm = buf->fpwm;
//    payloadData.solarPump = buf->solPump;
//    payloadData.spPwm = buf->spwm;
    
    Serial.print("received packet: ");
    Serial.println(payloadData.floorPump ? "heat" : "no heat");
//    Serial.println(payloadData.fpPwm);
//    Serial.println(payloadData.solarPump ? "solPump" : "no solPump");
    receivedTime = millis();
  } else if (millis() > receivedTime + 30000) { //keep on for 30 seconds 
    // if no pump ON signal received for some time, turn off
    payloadData.floorPump = false;
    payloadData.solarPump = false;
  }
  //data from the panels
  if (rf12_recvDone() && rf12_crc == 0 && (RF12_HDR_MASK & rf12_hdr) == 1) {
    panelData* buf =  (panelData*) rf12_data;

    panelOut = buf->tempOut;
  } 
}
        
void setup() {
  Serial.begin(57600);
  Serial.println("\n[Casita]");
  
  rf12_config();
  rf12_easyInit(1); // throttle packet sending to at least 5 seconds apart

  floorPump.mode(OUTPUT);
  floorPump.digiWrite(true); //inverted switch so off is high
  payloadData.floorPump = false;
  payloadData.fpPwm = 100;

  solarPump.mode2(OUTPUT);
  solarPump.digiWrite2(true);  //inverted switch so off is high
  payloadData.solarPump = false;
  payloadData.spPwm = 100;
  
  heater.mode2(OUTPUT);
  heater.digiWrite2(HIGH);  // turns on gas heater 
  
  FlowPump.mode3(INPUT);
  attachInterrupt(1, rpm, RISING);
  
  initOneWire();
}

/**
 * The main loop
 */
void loop() {
  receive();
  
//  byte on = millis() % 10 >= 2;    
  floorPump.digiWrite(!payloadData.floorPump); // & on));
  
  solarPump.digiWrite2(!(panelOut > 300));
  
  if (sendTimerPanel.poll(1500)) {
    needToSend = true;
    
    if (tempAsked)
    {
      // Get flow
      cli();      //Disable interrupts
      payloadData.floorFlow = (NbTopsFan / 7.5) * 10; //(Pulse frequency) / 7.5Q * 10 = e-1 C flow rate Liter / min 
      
      Serial.print("Read temp ");
      payloadData.tankTop = readTemp1wire();
      tempAsked = false;
    }
    else
    {
      // Start counting flow
      NbTopsFan = 0;   //Set NbTops to 0 ready for calculations
      sei(); // Enable interupts
      Serial.print("Ask temp ");
      askTemp1Wire();
      tempAsked = true;
    }
  }
  
  if(payloadData.solarPump) {
    if(!payloadData.needPump) {
      tankInStart = payloadData.tankIn;
      payloadData.needPump = true;
      cycleTimer = millis();
    }    
    if(millis() > cycleTimer + 60000 && payloadData.tankIn >= tankInStart) 
      if(payloadData.tankIn > tankInTop) {
        tankInTop = payloadData.tankIn;
      } else if(millis() > cycleTimer + 600000 && payloadData.tankIn < tankInTop) { // after 10 minutes check if the temp has gone down
        payloadData.needPump = false;  
        tankInStart = tankInTop = 0;
      }        
  }
  
  if (needToSend) {
    needToSend = false;
    while (!rf12_canSend())
      rf12_recvDone();     
    rf12_sendStart(0, &payloadData, sizeof payloadData);
        
    Serial.print("floorpump:");
    Serial.println(payloadData.floorPump ? "ON" : "OFF");
    Serial.print("solarpump:");
    Serial.println(payloadData.solarPump ? "ON" : "OFF");
    Serial.print("Temperatuur tank top: ");
    Serial.print(payloadData.tankTop);
    Serial.println("e-1 C");
    Serial.print(payloadData.floorFlow, DEC); //Prints the number calculated above
    Serial.print(" e-1 C L/min\r\n"); //Prints "L/hour" and returns a  new line
  }
}

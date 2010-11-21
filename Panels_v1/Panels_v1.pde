// Ports library demo, blinks leds on all 4 ports in slightly different ways
// 2009-02-13 <jcw@equi4.com> http://opensource.org/licenses/mit-license.php
// $Id: blink_ports.pde 5402 2010-04-30 19:24:52Z jcw $

#include <Ports.h>
#include <RF12.h> // needed to avoid a linker error :(
#include <avr/sleep.h>
#include <OneWire.h>
#include <payload.h>

Port WaterSensor (1); // measures restance drop on A1 to signal water 'over' the pump
Port FlowPump (2); // The flow pump measurement
//Port Temp (3); // 3 x DS18B20 temp sensors measuring panel in/out temp and outside temp
Port authLed (4); 

OneWire ds18b20 (6); // 1-wire temperature sensors, uses DIO port 3
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

typedef struct {
  byte pump; // is the pump needed?
} centralData;

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
  ds18b20.skip();
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

boolean waterDetected = false;
boolean PumpOn = false;
boolean needPump = false;
MilliTimer sendTimerPanel; // to time sending msgs 
unsigned long receivedTime = 0; // to expire pump on message
unsigned long waterTime = 0; // to delay the water sersor reading
byte needToSend = false;
boolean tempAsked = false;
payload payloadData;

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
  if (rf12_recvDone() && rf12_crc == 0) {
    centralData* buf =  (centralData*) rf12_data;

    needPump = buf->pump;
    
    Serial.print("received packet: ");
    Serial.println(needPump ? "yes" : "no");
    receivedTime = millis();
  } else if (millis() > receivedTime + 5000) {
    // if no pump ON signal received for some time, turn off
    needPump = false;
  }
}
        
void setup() {
  Serial.begin(57600);
  Serial.println("\n[Panels]");
  
  rf12_config();
  rf12_easyInit(1); // throttle packet sending to at least 5 seconds apart

  WaterSensor.mode2(INPUT);
//	Pump.mode(OUTPUT);
//	Temp.mode(INPUT);
  authLed.mode(OUTPUT);
  authLed.digiWrite(0);
  
  FlowPump.mode3(INPUT);
  attachInterrupt(1, rpm, RISING);
  
  initOneWire();
}

/**
 * The main loop
 */
void loop() {
  receive();
  waterDetected = WaterSensor.anaRead() > 1000;
  
  if (waterDetected) { // There is water
    if (!PumpOn && !waterTime) {
      waterTime = millis();
    }
    
    PumpOn = needPump && millis() > waterTime + 5000;
  } else {
    PumpOn = false;
    waterTime = 0;
  }
  
  authLed.digiWrite(needPump); // debug led to see if pump needed
  
  payloadData.pump = PumpOn;
 // payloadData.tempOut = readout1wire();

  if (sendTimerPanel.poll(1000)) {
    needToSend = true;
    
    if (tempAsked)
    {
      // Get flow
      cli();      //Disable interrupts
      payloadData.flow = (NbTopsFan * 60 / 7.5); //(Pulse frequency x 60) / 7.5Q, = flow rate 
      
      Serial.print("Read temp ");
      payloadData.tempOut = readTemp1wire();
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
  
  if (needToSend) {
    needToSend = false;
    if (rf12_canSend())
    {
      char* dataByte = NULL;
      dataByte = (char*) &payloadData;
   
      Serial.print("\nData send: ");
      for (int i; i < sizeof payloadData; i++)
        Serial.print(dataByte[i], HEX);
      Serial.print("\n");
      
      rf12_sendStart(1, &payloadData, sizeof payloadData);
    }
    else
    {
      Serial.println("Error can't send. canSend returned 'false'");
    }
    
    Serial.print("need pump:");
    Serial.println(needPump ? "yes" : "no");
    Serial.print("pump:");
    Serial.println(PumpOn ? "ON" : "OFF");
    Serial.print("water:");
    Serial.println(WaterSensor.anaRead());
    Serial.print("Temperatuur uit: ");
    Serial.print(payloadData.tempOut);
    Serial.println("e-1 C");
    Serial.print(payloadData.flow, DEC); //Prints the number calculated above
    Serial.print(" L/hour\r\n"); //Prints "L/hour" and returns a  new line
  }
}

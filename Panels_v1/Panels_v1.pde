// Ports library demo, blinks leds on all 4 ports in slightly different ways
// 2009-02-13 <jcw@equi4.com> http://opensource.org/licenses/mit-license.php
// $Id: blink_ports.pde 5402 2010-04-30 19:24:52Z jcw $

#include <Ports.h>
#include <RF12.h> // needed to avoid a linker error :(
#include <avr/sleep.h>
#include <OneWire.h>

Port WaterSensor (1); // measures restance drop on A1 to signal water 'over' the pump
//Port Pump (2); // switches the pump on and off
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

struct {
    byte pump;      // pump on or off
    int tempIn:  10; // temperature panel in
    int tempOut:  10; // temperature panel out
    int tempAmb:  10; // temperature outside
} payload;

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
  
  //initOneWire();
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
  
  payload.pump = PumpOn;
 // payload.tempOut = readout1wire();

  if (sendTimerPanel.poll(1000)) {
    needToSend = true;
    
    if (tempAsked)
    {
      Serial.print("Read temp ");
      payload.tempOut = readTemp1wire();
      tempAsked = false;
    }
    else
    {
      Serial.print("Ask temp ");
      askTemp1Wire();
      tempAsked = true;
    }
  }
  
  if (needToSend) {
    needToSend = false;
    if (rf12_canSend())
    {
      rf12_sendStart(1, &payload, sizeof payload);
      //Serial.println("'\nData send");
    }
    else
    {
      Serial.println("Error can't send. canSend returned false'");
    }
    
    Serial.print("need pump:");
    Serial.println(needPump ? "yes" : "no");
    Serial.print("pump:");
    Serial.println(PumpOn ? "ON" : "OFF");
    Serial.print("water:");
    Serial.println(WaterSensor.anaRead());
    Serial.print("Temperatuur uit: ");
    Serial.print(payload.tempOut);
    Serial.println("e-1 C");
  }
}

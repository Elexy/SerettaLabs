// Ports library demo, blinks leds on all 4 ports in slightly different ways
// 2009-02-13 <jcw@equi4.com> http://opensource.org/licenses/mit-license.php
// $Id: blink_ports.pde 5402 2010-04-30 19:24:52Z jcw $

#include <Ports.h>
#include <RF12.h> // needed to avoid a linker error :(
#include <OneWire.h>
#include <payload.h>

Port WaterSensor (2); // measures restance drop on A1 to signal water 'over' the pump
Port authLed (4); 
Port Pump (1); // AIO port 1

OneWire ds18b20 (4); // 1-wire temperature sensors, uses DIO port 1
// now that we have the port include code for reading
#include <tempSensors.h>

boolean waterDetected = false;
boolean PumpOn = false;
boolean needPump = false;
MilliTimer sendTimerPanel; // to time sending msgs 
unsigned long receivedTime = 0; // to expire pump on message
unsigned long waterTime = 0; // to delay the water sersor reading
byte needToSend = false;
boolean tempAsked = false;

// sensors we will read here
SensorInfo sensors[3] = {
    {panelOutID, "tempOut"}, 
    {panelInID, "tempIn"},
    {panelAmbID, "tempAmb" },
};

int sensorPointer;  // pointer to step though

panelData payloadData;
/**
 * Function receive data
 */
void receive () {
  if (rf12_recvDone() && rf12_crc == 0 
    && (RF12_HDR_MASK & rf12_hdr) == 1) {
    casitaData* buf =  (casitaData*) rf12_data;

    needPump = buf->needPump;
    
    Serial.print("received packet: ");
    Serial.println(needPump ? "yes" : "no");
    receivedTime = millis();
  } else if (millis() > receivedTime + 10000) {
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
  Pump.mode2(OUTPUT);
  Pump.digiWrite2(HIGH); // off
  
  sensorPointer = 0; //start with the first sensor    
}

/**
 * The main loop
 */
void loop() {
  DeviceAddress sensor;
  receive();
  needPump = 1;
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
  
//  authLed.digiWrite(needPump); // debug led to see if pump needed
  
  Pump.digiWrite2(!PumpOn); //inverted
  
  payloadData.pump = PumpOn;

  if (sendTimerPanel.poll(2000)) {
    Serial.println("R=");
    for( byte i = 0; i < 8; i++) {
      Serial.print(sensors[sensorPointer].id[i], HEX);
      Serial.print(" ");
    }

    needToSend = true;    
    Serial.print("Ask temp ");
    askTemp1Wire(sensors[sensorPointer].id);
    tempAsked = true;
    delay(1000);
    Serial.print("Read temp ");      
    if(tempAsked && tempTimerPanel.poll(tempWaitTime)) 
    {
      Serial.println(readTemp1wire(sensors[sensorPointer].id));      
      if(sensors[sensorPointer].desc == "tempOut") {
        payloadData.tempOut = readTemp1wire(sensors[sensorPointer].id);
      } else if(sensors[sensorPointer].desc == "TempIn") {
        payloadData.tempIn = readTemp1wire(sensors[sensorPointer].id);
      } else if(sensors[sensorPointer].desc == "tempAmb") {
        payloadData.tempAmb = readTemp1wire(sensors[sensorPointer].id);
      }      
      //  payloadData.mem = readTemp1wire(sensors[sensorPointer].id)
      sensorPointer = (sensorPointer + 1) % 3;    
      tempAsked = false;
    }
  }
    
  if (needToSend) {
    needToSend = false;
    char* dataByte = NULL;
    dataByte = (char*) &payloadData;
   
    Serial.print("\nData send: ");
    for (int i; i < sizeof payloadData; i++)
      Serial.print(dataByte[i], HEX);
    Serial.print("\n");
    while (!rf12_canSend())
      rf12_recvDone();    
    rf12_sendStart(1, &payloadData, sizeof payloadData);
    rf12_sendWait(2);
    
    Serial.print("need pump:");
    Serial.println(needPump ? "yes" : "no");
    Serial.print("pump:");
    Serial.println(PumpOn ? "ON" : "OFF");
    Serial.print("water:");
    Serial.println(WaterSensor.anaRead());
    Serial.print("Temperatuur uit: ");
    Serial.print(payloadData.tempOut);
    Serial.println("e-1 C");
    Serial.print(payloadData.tempIn); 
    Serial.print(" e-1 C");
    Serial.print(payloadData.tempAmb); 
    Serial.print(" e-1 C");
  }
}


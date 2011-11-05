// Ports library demo, blinks leds on all 4 ports in slightly different ways
// 2009-02-13 <jcw@equi4.com> http://opensource.org/licenses/mit-license.php
// $Id: blink_ports.pde 5402 2010-04-30 19:24:52Z jcw $

#include <Ports.h>
#include <RF12.h> // needed to avoid a linker error :(
#include <OneWire.h>
#include <payload.h>

OneWire ds18b20 (4); // 1-wire temperature sensors, uses DIO port 1
// now that we have the port include code for reading
#include <tempSensors.h>

MilliTimer sendTimerPanel; // to time sending msgs 
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
        
void setup() {
  Serial.begin(57600);
  Serial.println("\n[Panels]");
  
  rf12_config();
  rf12_easyInit(1); // throttle packet sending to at least 5 seconds apart

  sensorPointer = 0; //start with the first sensor    
}

/**
 * The main loop
 */
void loop() {
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
      //Serial.println(readTemp1wire(sensors[sensorPointer].id));      
      if(sensors[sensorPointer].desc == "tempOut") {
        payloadData.tempOut = readTemp1wire(sensors[sensorPointer].id);
        //payloadData.tempOut = 1100; //test setup
      } else if(sensors[sensorPointer].desc == "tempIn") {
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
    
    Serial.print("Temperatuur uit: ");
    Serial.print(payloadData.tempOut);
    Serial.println("e-1 C");
    Serial.print(payloadData.tempIn); 
    Serial.println(" e-1 C");
    Serial.print(payloadData.tempAmb); 
    Serial.println(" e-1 C");
  }
}


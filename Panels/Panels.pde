#include <Ports.h>
#include <RF12.h> // needed to avoid a linker error :(
#include <OneWire.h>
#include <payload.h>

OneWire ds18b20 (4); // 1-wire temperature sensors, uses DIO port 1
// now that we have the port include code for reading
#include <tempSensors.h>

// sensors we will read here
SensorInfo sensors[3] = {
    {panelOutID, "tempOut"}, 
    {panelInID, "tempIn"},
    {panelAmbID, "tempAmb" },
};
EMPTY_INTERRUPT(WDT_vect); //dummy to make the sleepy work
int sensorPointer;  // pointer to step though

panelData payloadData;
        
void setup() {
  Serial.begin(57600);
  Serial.println("\n[Panels]");
  
  rf12_config();
  rf12_easyInit(5); // throttle packet sending to at least 5 seconds apart

  sensorPointer = 0; //start with the first sensor    
}

/**
 * The main loop
 */
void loop() {
    delay(500);
    Serial.print("Ask temp ");
    askTemp1Wire(sensors[sensorPointer].id);
    delay(1000);
    Serial.print("Read temp ");      
    //Serial.println(readTemp1wire(sensors[sensorPointer].id));      
    if(sensors[sensorPointer].desc == "tempOut") {
      payloadData.tempOut = readTemp1wire(sensors[sensorPointer].id);
      //payloadData.tempOut = 1100; //test setup
    } else if(sensors[sensorPointer].desc == "tempIn") {
      payloadData.tempIn = readTemp1wire(sensors[sensorPointer].id);
    } else if(sensors[sensorPointer].desc == "tempAmb") {
      payloadData.tempAmb = readTemp1wire(sensors[sensorPointer].id);
      // only send once per cycle, every 3 mins
      rf12_sleep(-1);
      while (!rf12_canSend())
        rf12_recvDone();    
      rf12_sendStart(0, &payloadData, sizeof payloadData);
      rf12_sendWait(2);
      rf12_sleep(0);
    }      
    //  payloadData.mem = readTemp1wire(sensors[sensorPointer].id)
    sensorPointer = (sensorPointer + 1) % 3;    
    
    
    Serial.print("Temperatuur uit: ");
    Serial.print(payloadData.tempOut);
    Serial.println("e-1 C");
    Serial.print(payloadData.tempIn); 
    Serial.println(" e-1 C");
    Serial.print(payloadData.tempAmb); 
    Serial.println(" e-1 C");
    Serial.println("sleeping 1min");
    Sleepy::loseSomeTime(60000);
}


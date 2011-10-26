#include <RF12.h>
#include <Ports.h> //needed to avoid linker error
#include <payload.h> // all the payloads centralized

Port voltage (3);
Port dumpLoad (3); // relay with unpowered = dump ON

byte seqnum;

static int supplyVoltage() {return map(voltage.anaRead(), 0, 1023, 0, 4000); }
static int supplyReading() { return voltage.anaRead(); }

const int numReadings = 10; // size of readings array
const int interval = 25;    // interval to update display

int readings[numReadings];  // the reading from the analog input
int index = 0;              // the index of the current reading
int total = 0;              // the running total
int average = 0;            // the average
int updCounter = 0;         // counter for display updates
windControl payload;        // struct type windControl
double switchTimer = 0;     // to time switches at least 10 seconda apart

void setup () {
  rf12_config();
  rf12_easyInit(2);

  voltage.mode2(INPUT);
  
  dumpLoad.mode(OUTPUT);
  dumpLoad.digiWrite(0);

  Serial.begin(57600);
  Serial.println("\n[WindControl]");
  
  
  // initialize all readings to 0
  for (int thisReading = 0; thisReading < numReadings; thisReading++) readings[thisReading] = 0;
}

void dumpSwitch(boolean state) {
  if(millis() >= switchTimer + 10000 || switchTimer == 0) {
    dumpLoad.digiWrite(state ? 1 : 0 );
    payload.dump=state ? 1 : 0;
    switchTimer = millis();
    Serial.println("time to switch");
  }
}

void loop () {
  // subtract last reading
  total = total - readings[index];
  // put new reading in array
  readings[index] = supplyVoltage();
  // add the reading to the total
  total = total + readings[index];
  // advance to next pos
  index++;
  
  if(index >= numReadings)
    // wrap around
    index = 0;
    
  //calculate the average
  average = total / numReadings;  
  payload.volts = average;
  
  if(supplyVoltage() > 2780) {
    dumpSwitch(false); // at voltages over 27.6 switch to dumpload
  } else {
    dumpSwitch(true); // at voltages under 27.6 switch to battery charging
  }
  
  if(updCounter == interval )
  {
    Serial.print("relay: ");
    Serial.println(payload.dump ? 'on' : 'off');
    Serial.print("Power R: ");
    Serial.print(supplyReading());
    Serial.print(" V: ");
    Serial.print(supplyVoltage());
    Serial.print(" average: ");
    Serial.println(average, DEC);
//    Serial.println(switchTimer+10000);
//    Serial.println(millis());
    while (!rf12_canSend())
      rf12_recvDone();     
    rf12_sendStart(0, &payload, sizeof payload);
    rf12_sendWait(2);
    updCounter = 0; //reset counter
  }
  delay(100);
  updCounter++; //increment counter
}

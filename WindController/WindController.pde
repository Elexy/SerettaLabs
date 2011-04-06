#include <RF12.h>
#include <Ports.h> //needed to avoid linker error

Port voltage (3);
Port dumpLoad (3);

byte seqnum;

static int supplyVoltage() {return map(voltage.anaRead(), 0, 1023, 0, 4000); }
static int supplyReading() { return voltage.anaRead(); }

const int numReadings = 10; // size of readings array
const int interval = 10;    // interval to update display

int readings[numReadings];  // the reading from the analog input
int index = 0;              // the index of the current reading
int total = 0;              // the running total
int average = 0;            // the average
int updCounter = 0;         // counter for display updates


void setup () {
  rf12_config();
  rf12_easyInit(2);

  voltage.mode2(INPUT);
  
  dumpLoad.mode(OUTPUT);
  dumpLoad.digiWrite(0);

  Serial.begin(57600);
  Serial.println("\n[WindControl]");
  
  
  // initialize all readings to 0
  for (int thisReading = 0; thisReading < numReadings; thisReading++)
    readings[thisReading] = 0;
    
//  rf12_easyInit(5);  
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
  
  if(supplyVoltage() > 2760) {
    dumpLoad.digiWrite(0); // at voltages over 27.6 switch to dumpload
    Serial.println("relay:off");
  } else {
    dumpLoad.digiWrite(1); // at voltages under 27.6 switch to battery charging
    Serial.println("relay:on");
  }
  
  if(updCounter == interval )
  {
    Serial.print("Power R: ");
    Serial.print(supplyReading());
    Serial.print(" V: ");
    Serial.print(supplyVoltage());
    Serial.print(" average: ");
    Serial.println(average, DEC);

    updCounter = 0; //reset counter
  }
  
  updCounter++; //increment counter
  
//  rf12_easyPoll();
//  rf12_easySend(&v, sizeof v);
  
  delay(100);
  
  while (!rf12_canSend())
    rf12_recvDone();     
  rf12_sendStart(0, &payloadData, sizeof payloadData);
}

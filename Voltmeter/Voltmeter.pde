#include <RF12.h>
#include <Ports.h> //needed to avoid linker error
#include <PortsLCD.h>

PortI2C myI2C (1);
LiquidCrystalI2C lcd (myI2C);
Port Voltage (4)

byte seqnum;

static int supplyVoltage() {return map(Voltage.anaRead(), 0, 1023, 0, 2990); }
static int supplyReading() { return Voltage.anaRead(); }

const int numReadings = 10; // size of readings array
const int interval = 10;    // interval to update display

int readings[numReadings];  // the reading from the analog input
int index = 0;              // the index of the current reading
int total = 0;              // the running total
int average = 0;            // the average
int updCounter = 0;         // counter for display updates


void setup () {
  Serial.begin(57600);
  Serial.println("\n[PowerVolt]");
  
  lcd.begin(16,2);
  lcd.print("PowerSupply");
  
  // initialize all readings to 0
  for (int thisReading = 0; thisReading < numReadings; thisReading++)
    readings[thisReading] = 0;
    
//  rf12_initialize(16, RF12_868MHZ, 5);
//  rf12_easyInit(0);  
}

void padPrint( int value, int width, boolean leading = true)
{
// pads values with leading zeros to make the given width
char valueStr[6]; // large enough to hold an int
  itoa (value, valueStr, 10);
  int len = strlen(valueStr);
  if(leading) {
    if(len < width){
      len = width-len;
      while(len--)
       lcd.print('0');
    }
    lcd.print(valueStr);  
  } else {
    lcd.print(valueStr);
    if(len < width){
    len = width-len;
      while(len--)
       lcd.print('0');
    }
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
  
  if(updCounter == interval )
  {
//    lcd.setCursor(0,0);
    lcd.home();
//    lcd.print(supplyVoltage());
    lcd.setCursor(0,1);
    padPrint(average / 100, 2);
    lcd.print(".");
    padPrint(average % 100, 2, false);
    lcd.print(" V");
    
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
}

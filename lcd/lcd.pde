#include <PortsLCD.h>
#include <RF12.h>

PortI2C myI2C (1);
LiquidCrystalI2C lcd (myI2C);

void setup() 
{
  // setup the lcd's number or rows and columns
  lcd.begin(16,2);
  // print a message to the LCD
  lcd.print("Finca La Serretta"); 
}

void loop() 
{
  //set the cursor to column 0, line 1
  // note: line 1 is the second line, counting starts as 0
  lcd.setCursor(0,1);
  //print the number of seconds since reset
  lcd.print(millis()/1000);
}

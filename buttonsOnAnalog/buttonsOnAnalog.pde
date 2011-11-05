/*  Example 25.3 - Digital buttons with analog input 
http://tronixstuff.com/tutorials > chapter 25 CC by-sa-nc */
#include <LiquidCrystal.h>
LiquidCrystal lcd(12, 11, 5, 4, 2, 3);
int a=0;
void setup()
{
lcd.begin(20, 4);
pinMode(A5, INPUT); 
// sets analog pin for input 
} 

int readButtons(int pin) 
// returns the button number pressed, or zero for none pressed 
// int pin is the analog pin number to read 
{
int b,c = 0;
c=analogRead(pin); // get the analog value  if (c>1000)
{
b=0; // buttons have not been pressed
}   else
if (c>440 && c<470)
{
b=1; // button 1 pressed
}     else
if (c<400 && c>370)
{
b=2; // button 2 pressed
}       else
if (c>280 && c<310)
{
b=3; // button 3 pressed
}         else
if (c>150 && c<180)
{
b=4; // button 4 pressed
}           else
if (c<20)
{
b=5; // button 5 pressed
}
return b;
}

void loop()
{
a=readButtons(5);
lcd.clear();
if (a==0) // no buttons pressed
{
lcd.setCursor(0,1);
lcd.print("Press a button");
}   else
if (a>0) // someone pressed a button!
{
lcd.setCursor(0,2);
lcd.print("Pressed button ");
lcd.print(a);
}
delay(1000); // give the human time to read LCD
}

// Demo sketch for the Thermo Plug v1
// 2009-09-17 <jcw@equi4.com> http://opensource.org/licenses/mit-license.php
// $Id: thermo_demo.pde 4727 2009-12-08 21:39:49Z jcw $

#include <Ports.h>
#include <RF12.h> // needed to avoid a linker error :(

Port one (1);


void setup () {
    Serial.begin(57600);
    Serial.println("\n[thermo_demo]");
    
    one.mode(OUTPUT);    
}

void loop () {
  one.digiWrite(HIGH);   // sets the LED on
  delay(2000);                  // waits for a second
  one.digiWrite(LOW);    // sets the LED off
  delay(2000);                  // waits for a second
}

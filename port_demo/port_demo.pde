// Demo of the BlinkPlug class
// 2009-12-09 <jcw@equi4.com> http://opensource.org/licenses/mit-license.php
// $Id: blink_demo.pde 4730 2009-12-11 15:36:29Z jcw $

#include <Ports.h>
#include <RF12.h> // needed to avoid a linker error :(

Port solar (3);
Port gas (2);
Port fl (2);

void setup () {
    Serial.begin(57600);
    Serial.println("\n[blink_demo]");

    fl.mode(OUTPUT);
    gas.mode2(OUTPUT);
    solar.mode2(OUTPUT);
}

void loop () {
  fl.digiWrite(1);
  delay(1000);
  fl.digiWrite(0);
  delay(1000);
  
  gas.digiWrite2(1);
  delay(1000);
  gas.digiWrite2(0);
  delay(1000);
  
  solar.digiWrite2(1);  
  delay(1000);
  solar.digiWrite2(0);
  delay(1000);
}

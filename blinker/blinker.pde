#include <Ports.h>
#include <RF12.h>

Port one (1);
Port two (2);
Port three (3);
Port four (4);

void setup() {
  one.mode(OUTPUT);
  two.mode(OUTPUT);
  three.mode(OUTPUT);
  four.mode(OUTPUT);
}

void loop() {
  uint16_t ten = millis() / 10;
  
  one.digiWrite(ten & 0x10); // led 1 blinks every 2 x 0.16 sec
  four.digiWrite(ten & 0x80); // led 1 blinks every 2 x 1.28 sec
  
  // ports 2 and three have support for pwm output
  // use bits 0..7 of ten as pwm outputlevel
  // use 8 for up down choice, i.e. make level ramp up then down
  uint8_t level = ten;
  if(ten & 0x100)
    level = ~level;
    
  // leds 2 and 3 light up and down in oposite ways every 2 x 2.56 sec
  two.anaWrite(level);
  three.anaWrite(level);
}

// Demo display for the Graphics Boad
// 2010-11-14 <jcw@equi4.com> http://opensource.org/licenses/mit-license.php
// $Id: glcd_demo.pde 6564 2011-01-04 19:26:34Z jcw $

#include <GLCD_ST7565.h>
#include <Ports.h>
#include <RF12.h> // needed to avoid a linker error :(
#include <avr/pgmspace.h>

GLCD_ST7565 glcd;

void setup () {
    rf12_initialize(1, RF12_868MHZ);
    rf12_sleep(0);
    
    glcd.begin();
    glcd.backLight(255);

    // draw a string at a location, use _p variant to reduce RAM use
    glcd.drawString_P(40,  0, PSTR("GLCDlib"));
    glcd.drawString_P(10, 16, PSTR("ST7565 128x64 GLCD"));
    glcd.drawString_P(22, 32, PSTR("Graphics Board"));
    glcd.drawString_P(20, 48, PSTR("JeeLabs.org/gb1"));

    glcd.drawCircle(5, 5, 5, WHITE);
    glcd.fillCircle(121, 5, 5, WHITE);
    glcd.fillCircle(6, 58, 5, WHITE);
    glcd.drawCircle(121, 58, 5, WHITE);

    glcd.drawLine(40, 9, 81, 9, WHITE);
    glcd.drawLine(40, 11, 81, 11, WHITE);
    glcd.drawLine(0, 42, 14, 28, WHITE);
    glcd.drawLine(112, 42, 126, 28, WHITE);
    glcd.drawRect(0, 28, 127, 15, WHITE);

    glcd.refresh();
    
    Sleepy::powerDown(); // power consumption is now only the GLCD + backlight
}

void loop () {}

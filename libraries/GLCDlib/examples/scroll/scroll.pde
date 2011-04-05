// gLCD scroll example.
// $Id: glcdhost.pde 6525 2010-12-22 22:37:37Z sevans

#include <GLCD_ST7565.h>
#include <Ports.h>
#include <RF12.h> // needed to avoid a linker error :(

GLCD_ST7565 glcd;

int d = 4;
byte x = 0;

void setup () {
    glcd.begin();
    glcd.backLight(255);
    glcd.refresh();
}

void loop () {
//  glcd.fillRect(3,10,110,50,1);
    glcd.drawLine(0,0,127,63,1);
    glcd.drawString(x,0,"Hello");
    glcd.refresh();
    glcd.drawString(x+36,2,"Wo");
    glcd.drawChar(x+48,3,'r');
    glcd.drawChar(x+54,4,'l');
    glcd.drawString(x+60,5,"d!");
    if (x+d > 55 || x+d < 0) d=-d;
    x=x+d;
    glcd.refresh();
    delay(1000);
    glcd.scroll(SCROLLDOWN,8);
    glcd.refresh();
    delay(1000);
}

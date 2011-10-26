// Demo clock for the Graphics Board, this version runs on the internal clock.
// 2010-11-18 <jcw@equi4.com> http://opensource.org/licenses/mit-license.php
// $Id$

#include <GLCD_ST7565.h>
#include <RTClib.h>
#include <Wire.h> // needed to avoid a linker error :(
#include <Ports.h> // needed to avoid a linker error :(
#include <RF12.h> // needed to avoid a linker error :(
#include <avr/pgmspace.h>
#include "digits.h"

GLCD_ST7565 glcd;
RTC_Millis rtc;

static void drawDigit(byte x, byte d) {
    const long* digit = digits + 64 * d;
    for (byte i = 0; i < 64; ++i) {
        long mask = pgm_read_dword(digit++);
        for (byte j = 0; j < 28; ++j)
            glcd.setPixel(x + j, i, bitRead(mask, 27-j));
    }
}

static void twoDigits(byte x, byte v) {
    drawDigit(x, v / 10);
    drawDigit(x + 32, v % 10);
}

void setup () {
    rtc.begin(DateTime (__DATE__, __TIME__));    
    glcd.begin();
    glcd.backLight(255);
}

void loop () {
    DateTime now = rtc.now();
    // hours
    twoDigits(0, now.hour());
    // minutes
    twoDigits(69, now.minute());
    // blinking colon
    glcd.fillCircle(63, 24, 2, now.second() & 1);
    glcd.fillCircle(63, 40, 2, now.second() & 1);
    // show it!
    glcd.refresh();
}

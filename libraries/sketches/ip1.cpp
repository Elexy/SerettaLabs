// Interpret a pulse train as 16-channel selection for the Input Plug
// 2010-04-19 <jcw@equi4.com> http://opensource.org/licenses/mit-license.php
// $Id: ip1.cpp 6581 2011-01-12 10:37:53Z jcw $

// The main pulse train to select an input is: 1 a b c d (5 bits).
// A short pulse is 0, a long pulse is 1 - reset whenever no pulse is detected.

#include <avr/io.h>
#include <util/delay.h>

#define LIMIT   10  // minimal number of loops to be considered a "1"

typedef unsigned char byte;

inline byte inBit () {
    return PINB & 0x10;
}

static void setup () {
    DDRB = 0x0F;
    PORTB = 0x10 | LIMIT;
}

static void loop () {
    // wait for zero as initial condition
    while (inBit())
        ;
    // shift 6 bits in (including the start bit)
    byte shift = 0;
    for (byte i = 0; i < 5; ++i) {
        // wait for pulse start
        byte n = 255;
        while (!inBit())
            if (--n == 0)
                return; // no pulse detected
        // check how long it takes to return to zero
        n = 0;
        while (inBit())
            if (++n == 255)
                return; // no return-to-zero detected
        // long puls = 1, short pulse = 0
        shift = (shift << 1) | (n >= LIMIT);
    }
    // bit pattern must be: 0 0 0 1 a b c d
    if ((shift & 0xF0) != 0x10)
        return;
    // got a selection, place it on the output pins
    PORTB = shift; // keep bit 4 set as pull-up
}

int main() {
    setup();
    while (1)
        loop();
    // never reached
}

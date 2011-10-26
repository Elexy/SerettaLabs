// Find out how badly damaged the EEPROM is, to be used after "eewear.pde".
// 2011-05-11 <jcw@equi4.com> http://opensource.org/licenses/mit-license.php
// $Id: eewear2.pde 7677 2011-05-11 15:10:49Z jcw $

#include <LiquidCrystal.h>
#include <EEPROM.h>

#define MAXEE 512 // # of EE bytes to test, 1..512 for ATmega168
#define LED 4 // blink LED on DIO1

byte errors[MAXEE]; // error counts for each byte
long cycles; // maximum size is 2,147,483,647
int maxerr = -1; // highest error count so far

static bool check (byte value) {
    digitalWrite(LED, value & 1);
    ++cycles;
    byte errcnt = 0;
    for (int a = 0; a < MAXEE; ++a)
        EEPROM.write(a, value);
    for (int a = 0; a < MAXEE; ++a)
        if (EEPROM.read(a) != value) {
            errors[a]++;
            if (errors[a] > errcnt)
                errcnt = errors[a];
        }
    if (errcnt != maxerr) {
        maxerr = errcnt;
        Serial.print("Cycle: ");
        Serial.print(cycles);
        Serial.print(", errors: ");
        Serial.println(maxerr);
    }
    return maxerr < 62;
}

static void report() {
    for (int a = 0; a < MAXEE; ++a) {
        byte e = errors[a];
        char c = e == 0 ? '.' :
                 e < 10 ? '1' + e :
                 e < 36 ? 'a' + e - 10 :
                 e < 62 ? 'A' + e - 36 : '?';
        Serial.print(c);
        if (a % 8 < 7)
            Serial.print(' ');
        else
            Serial.println();
    }
}

void setup () {
    Serial.begin(57600);
    Serial.println("\n[eewear2]");
    pinMode(LED, OUTPUT);
}

void loop () {
    if (!check(85) || !check(170)) {
        report();
        while (1)
            ;
    }
}

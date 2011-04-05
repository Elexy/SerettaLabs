// Receive / decode FS20, (K)S300, and EM10* signals using an 868 MHz OOK radio
// 2009-04-08 <jcw@equi4.com> http://opensource.org/licenses/mit-license.php

#include <util/crc16.h>

// receiver signal is connected to analog input 0
#define RXDATA 14

enum { UNKNOWN, T0, T1, OK, DONE };

// track bit-by-bit reception using multiple independent state machines
struct { char bits; uint8_t state; uint64_t data; } FS20;
struct { char bits; uint8_t state, pos, data[16]; } S300;
struct { char bits; uint8_t state, pos, seq; uint16_t data[10]; } EM10;

static uint8_t FS20_bit(char value) {
    FS20.data = (FS20.data << 1) | value;
    if (FS20.bits < 0 && (uint8_t) FS20.data != 0x01 || ++FS20.bits != 45)
        return OK;
    return DONE;
}

static uint8_t S300_bit(char value) {
    uint8_t *ptr = S300.data + S300.pos;
    *ptr = (*ptr >> 1) | (value << 4);
    
    if (S300.bits < 0 && *ptr != 0x10)
        return OK; // not yet synchronized

    if (++S300.bits == 4) {
        if (S300.pos >= 9 && S300.data[0] == 0x11 || S300.pos >= 15) {
            *ptr >>= 1;
            return DONE;
        }
    } else if (S300.bits >= 5) {
        ++S300.pos;
        S300.bits = 0;
    }

    return OK;
}

static uint8_t EM10_bit(char value) {
    uint16_t *ptr = EM10.data + EM10.pos;
    *ptr = (*ptr >> 1) | (value << 8);
    
    if (EM10.bits < 0 && *ptr != 0x100)
        return OK; // not yet synchronized

    if (++EM10.bits == 8) {
        if (EM10.pos >= 9) {
            *ptr >>= 1;
            return DONE;
        }
    } else if (EM10.bits >= 9) {
        ++EM10.pos;
        EM10.bits = 0;
    }

    return OK;
}

ISR(ANALOG_COMP_vect) {
    // count is the pulse length in units of 4 usecs
    uint8_t count = TCNT2;
    TCNT2 = 0;

    // FS20 pulse widths are 400 and 600 usec (split on 300, 500, and 700)
    // see http://fhz4linux.info/tiki-index.php?page=FS20%20Protocol
    if (FS20.state != DONE)
        switch ((count - 25) / 50) {
            case 1:  FS20.state = FS20.state == T0 ? FS20_bit(0) : T0; break;
            case 2:  FS20.state = FS20.state == T1 ? FS20_bit(1) : T1; break;
            default: FS20.state = UNKNOWN;
        }

    // (K)S300 pulse widths are 400 and 800 usec (split on 200, 600, and 1000)
    // see http://www.dc3yc.homepage.t-online.de/protocol.htm
    if (S300.state != DONE)
        switch ((count + 50) / 100) {
            case 1:  S300.state = S300.state == T1 ? S300_bit(0) : T0; break;
            case 2:  S300.state = S300.state == T0 ? S300_bit(1) : T1; break;
            default: S300.state = UNKNOWN;
        }

    // EM10 pulse widths are 400 and 800 usec (split on 200, 600, and 1000)
    // see http://fhz4linux.info/tiki-index.php?page=EM+Protocol
    if (EM10.state != DONE) {
        switch ((count + 50) / 100) {
            case 1:  EM10.state = EM10.state == T0 ? EM10_bit(0) : T0; break;
            case 2:  if (EM10.state == T0) {
                        EM10.state = EM10_bit(1);
                        break;
                     } // else fall through
            default: EM10.state = UNKNOWN;
        }
    }
}

static void reset_FS20() {
    FS20.bits = -1;
    FS20.data = 0xFF;
    FS20.state = UNKNOWN;
}

static void reset_S300() {
    S300.bits = -1;
    S300.pos = 0;
    S300.data[0] = 0x1F;
    S300.state = UNKNOWN;
}

static void reset_EM10() {
    EM10.bits = -1;
    EM10.pos = 0;
    EM10.data[0] = 0x1FF;
    EM10.state = UNKNOWN;
}

ISR(TIMER2_OVF_vect) {
    if (FS20.state != DONE) 
        reset_FS20();
    if (S300.state != DONE) 
        reset_S300();
    if (EM10.state != DONE) 
        reset_EM10();
}

void setup() {
    Serial.begin(57600);
    Serial.println("\n[recv868ook]");

    pinMode(RXDATA, INPUT);
    digitalWrite(RXDATA, 1); // pull-up

    /* enable analog comparator with fixed voltage reference */
    ACSR = _BV(ACBG) | _BV(ACI) | _BV(ACIE);
    ADCSRA &= ~ _BV(ADEN);
    ADCSRB |= _BV(ACME);
    ADMUX = 0; // ADC0

    /* prescaler 64 -> 250 KHz = 4 usec/count, max 1.024 msec (16 MHz clock) */
    TCNT2 = 0;
    TCCR2A = 0;
    TCCR2B = _BV(CS22);
    TIMSK2 = _BV(TOIE2);
    
    reset_FS20();
    reset_S300();
    reset_EM10();
}

void loop() {
    if (FS20.state == DONE) {    
        uint8_t b[5];
        for (uint8_t i = 0; i < 5; ++i)
            b[4-i] = FS20.data >> (1 + 9 * i);
            
        uint8_t sum = 6 + b[0] + b[1] + b[2] + b[3];
        uint8_t ok = sum == b[4];
        
        Serial.print(ok ? "FS20" : " ?fs");
        for (uint8_t i = 0; i < 4; ++i) {
            Serial.print(' ');
            Serial.print(b[i], DEC);
        }
        Serial.println();
    
        if (ok) // skip repeats
            delay(120);
    
        reset_FS20();
    }
  
    if (S300.state == DONE) {    
        uint8_t ones = 0, sum = 37 - S300.data[S300.pos], chk = 0;
        for (uint8_t i = 0; i < S300.pos; ++i) {
            uint8_t b = S300.data[i];
            ones += b >> 4;
            sum += b;
            chk ^= b;
        }
        sum &= 0x0F;
        chk &= 0x0F;
        
        if (ones == S300.pos && chk == 0 && sum == 0) {
            if (S300.pos == 15)
                Serial.print('K');
            Serial.print("S300 ");
            S300.pos -= 2; // don't show checksums when they are ok
        } else
            Serial.print(" ?ks ");

        for (uint8_t i = 0; i <= S300.pos; ++i)
            Serial.print(S300.data[i] & 0x0F, HEX);
        Serial.println();
        
        reset_S300();
    }
  
    if (EM10.state == DONE) {    
        if ((uint8_t) EM10.data[2] != EM10.seq) {
            uint8_t ones = 0, chk = 0;
            for (uint8_t i = 0; i < 10; ++i) {
                ones += EM10.data[i] >> 8;
                chk ^= EM10.data[i];
            }
            uint8_t ok = ones == 9 && chk == 0;
        
            Serial.print(ok ? "EM10" : " ?em");
            for (uint8_t i = 0; i < 9; ++i) {
                Serial.print(' ');
                Serial.print((uint8_t) EM10.data[i], DEC);
            }
            Serial.println();
        
            if (ok) // skip repeats
                EM10.seq = EM10.data[2];
        }
        
        reset_EM10();
    }
}

// Receive / decode FS20, (K)S300, and EM10* signals using an 868 MHz OOK radio
// 2009-04-08 <jcw@equi4.com> http://opensource.org/licenses/mit-license.php

#include <util/crc16.h>

// The basic idea is to measure pulse widths between 0/1 and 1/0 transitions,
// and to keep track of pulse width sequences in a state machine.

// receiver signal is connected to AIO1
#define RXDATA 14

enum { UNKNOWN, T0, T1, OK, DONE };

// track bit-by-bit reception using multiple independent state machines
struct { char bits; byte state; uint32_t prev; uint64_t data; } FS20;
struct { char bits; byte state, pos, data[16]; } S300;
struct { char bits; byte state, pos, seq; word data[10]; } EM10;

static byte FS20_bit (char value) {
    FS20.data = (FS20.data << 1) | value;
    if (FS20.bits < 0 && (byte) FS20.data != 0x01)
        return OK;
    if (++FS20.bits == 45 && ((FS20.data >> 15) & 1) == 0 ||
          FS20.bits == 54 && ((FS20.data >> 24) & 1))
        return DONE;
    return OK;
}

static byte S300_bit (char value) {
    byte *ptr = S300.data + S300.pos;
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

static byte EM10_bit (char value) {
    word *ptr = EM10.data + EM10.pos;
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

static void ook868interrupt () {
    // count is the pulse length in units of 4 usecs
    byte count = TCNT2;
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

static void reset_FS20 () {
    FS20.bits = -1;
    FS20.data = 0xFF;
    FS20.state = UNKNOWN;
}

static void reset_S300 () {
    S300.bits = -1;
    S300.pos = 0;
    S300.data[0] = 0x1F;
    S300.state = UNKNOWN;
}

static void reset_EM10 () {
    EM10.bits = -1;
    EM10.pos = 0;
    EM10.data[0] = 0x1FF;
    EM10.state = UNKNOWN;
}

static void ook868timeout () {
    if (FS20.state != DONE) 
        reset_FS20();
    if (S300.state != DONE) 
        reset_S300();
    if (EM10.state != DONE) 
        reset_EM10();
}

static void ook868setup () {
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

// Poll and return a count > 0 when a valid packet has been received:
//  4 = S300
//  5 = FS20
//  6 = FS20 extended
//  7 = KS300
//  9 = EM10*

static byte ook868poll (byte* buf) {
    if (FS20.state == DONE) {  
        uint32_t since = millis() - FS20.prev;
        if (since > 150) {          
            byte len = FS20.bits / 9;
            byte sum = 6;
            for (byte i = 0; i < len; ++i) {
                byte b = FS20.data >> (1 + 9 * i);
                buf[len-i-1] = b;
                if (i > 0)
                    sum += b;
            }
            if (sum == buf[len-1]) {
                FS20.prev = millis();
                reset_FS20();
                return len;
            }
        }
        
        reset_FS20();
    }
  
    if (S300.state == DONE) {    
        byte n = S300.pos, ones = 0, sum = 37 - S300.data[n], chk = 0;
        for (byte i = 0; i < n; ++i) {
            byte b = S300.data[i];
            ones += b >> 4;
            sum += b;
            chk ^= b;
            
            if (i & 1)
                buf[i>>1] |= b << 4;
            else
                buf[i>>1] = b & 0x0F;
        }
        
        reset_S300();
        
        if (ones == n && (chk & 0x0F) == 0 && (sum & 0x0F) == 0)
            return n >> 1;
    }
  
    if (EM10.state == DONE) {    
        if ((byte) EM10.data[2] != EM10.seq) {
            byte ones = 0, chk = 0;
            for (byte i = 0; i < 10; ++i) {
                word v = EM10.data[i];
                ones += v >> 8;
                chk ^= v;
                buf[i] = v;
            }
            
            if (ones == 9 && chk == 0) {
                EM10.seq = EM10.data[2];
                reset_EM10();
                return 9;
            }
        }
        
        reset_EM10();
    }
    
    return 0;
}

ISR(ANALOG_COMP_vect) {
    ook868interrupt();
}

ISR(TIMER2_OVF_vect) {
    ook868timeout();
}

void setup () {
    Serial.begin(57600);
    Serial.println("\n[recv868ook]");

    ook868setup();
}

void loop () {
    byte buf[10];
    byte n = ook868poll(buf);
    
    if (n) {
        Serial.print("OOK868 ");
        Serial.print(n, DEC);
        for (byte i = 0; i < n; ++i) {
            Serial.print(' ');
            Serial.print(buf[i], DEC);
        }
        Serial.println();
    }
}

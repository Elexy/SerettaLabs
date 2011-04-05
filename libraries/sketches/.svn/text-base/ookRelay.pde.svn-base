// Relay all decoded data from 433/868 OOK transmitters as RFM12B packets.
// Also relay DCF77 time codes and BMP085 barometer readouts once a minute.
// 2009-10-05 <jcw@equi4.com> http://opensource.org/licenses/mit-license.php
//
// see http://news.jeelabs.org/2009/10/12/an-ook-relay/

#include <Ports.h>
#include <PortsBMP085.h>
#include <RF12.h>
#include <util/crc16.h>
#include <avr/pgmspace.h>

// configurable parameters
#define NODE_ID     29              // node ID
#define NODE_MHZ    RF12_868MHZ     // node frequency band
#define NODE_GROUP  5               // node network group
 
// types of received and relayed signals
enum { RF868, RF433, DCF77, BARO };

PortI2C myI2C (3);
BMP085 pressure (myI2C);

// The basic idea is to measure pulse widths between 0/1 and 1/0 transitions,
// and to keep track of pulse width sequences in a state machine.

// can't just change these pin definitions, PIN_868 and PIN_433 use interrupts
#define PIN_868 14  // the 868 MHz receiver is connected to AIO1
#define PIN_433 4   // the 433 MHz receiver is connected to DIO1
#define PIN_DCF 5   // the DCF77 receiver is connected to DIO2

enum { UNKNOWN, T0, T1, T2, T3, OK, DONE };

// track bit-by-bit reception using multiple independent state machines
struct { char bits; byte state; uint32_t prev; uint64_t data; } FS20;
struct { char bits; byte state, pos, data[16]; } S300;
struct { char bits; byte state, pos, seq; word data[10]; } EM10;
struct { byte state; char bits; uint32_t prev; word data; } KAKU;

static MilliTimer sendTimer; // to resend periodically until ack is received
static MilliTimer baroTimer; // to read out barometric pressure once in a while

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
    pinMode(PIN_868, INPUT);
    digitalWrite(PIN_868, 1); // pull-up

    // enable pin change interrupts on PC0
    PCMSK1 = bit(0);
    PCICR |= bit(PCIE1);

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
        byte len = FS20.bits / 9;
        byte sum = 6;
        for (byte i = 0; i < len; ++i) {
            byte b = FS20.data >> (1 + 9 * i);
            buf[len-i-1] = b;
            if (i > 0)
                sum += b;
        }
        if (sum == buf[len-1]) {
            uint32_t since = millis() - FS20.prev;
            FS20.prev = millis();
            reset_FS20();
            if (since > 150)
                return len;
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

static byte KAKU_bit(byte value) {
    KAKU.data = (KAKU.data >> 1) | (value << 11);
    return ++KAKU.bits != 12 ? OK : DONE;
}

static void ook433interrupt () {
    // width is the pulse length in usecs, for either polarity
    static word last;
    word width = micros() - last;
    last += width;

    // KAKU pulse widths are (S) 1x and (L) 3x 375 usec (0 = SLSL, 1 = SLLS)
    if (KAKU.state != DONE) {
        byte w = (width + 360) / 540; // distinguish at 180/720/1260 usec
        switch (w) {
            case 0: // 0..179 usec
            case 3: // 1260..1799 usec
                KAKU.state = UNKNOWN; break;
            case 1: // 180..719 usec
            case 2: // 720..1259 usec
                switch (KAKU.state) {
                    case OK: // start of new data bit
                        KAKU.state = w == 1 ? T0 : UNKNOWN; break;
                    case T0: // short pulse seen
                        KAKU.state = w == 2 ? T1 : UNKNOWN; break;
                    case T1: // short + long pulse seen
                        KAKU.state += w; break;
                    case T2: // short + long + short pulse seen
                        KAKU.state = w == 2 ? KAKU_bit(0) : UNKNOWN; break;
                    case T3: // short + long + long pulse seen
                        KAKU.state = w == 1 ? KAKU_bit(1) : UNKNOWN; break;
                }
                break;
            default: // 1800..UP usec
                KAKU.state = OK; KAKU.bits = 0; KAKU.data = 0; break;
        }
    }
}

static void ook433setup () {
    pinMode(PIN_433, INPUT);
    digitalWrite(PIN_433, 1); // pull-up

    // enable pin change interrupts on PD4
    PCMSK2 = bit(4);
    PCICR |= bit(PCIE2);
}

static int ook433poll () {
    if (KAKU.state == DONE) {
        uint32_t since = millis() - KAKU.prev;
        KAKU.prev = millis();
        KAKU.state = UNKNOWN;
        if (since > 500)
            return KAKU.data & 0x0FFF;
    }
    return -1;
}

ISR(TIMER2_OVF_vect)    { ook868timeout(); }
ISR(PCINT1_vect)        { ook868interrupt(); }
ISR(PCINT2_vect)        { ook433interrupt(); }

// DCF77 radio clock signal decoder

static word dcfWidth;
static byte dcfLevels, dcfBits, dcfParity;
static byte dcfValue[8];
static byte dcfBuf[6];

static prog_uint8_t daysInMonth[] = { 31,28,31,30,31,30,31,31,30,31,30,31 };

// number of days since 2000/01/01, valid for 2001..2099
static word date2days (byte y, byte m, byte d) {
    word days = d;
    for (byte i = 1; i < m; ++i)
        days += pgm_read_byte(daysInMonth + i - 1);
    if (m > 2 && y % 4 == 0)
        ++days;
    return days + 365 * y + (y - 1) / 4;
}

static uint32_t unixTime (word days, byte h, byte m, byte s, byte t) {
    uint32_t secs = 946681200L; // 2000/01/01 00:00:00 CET
    return secs + ((((days * 24L + h + (t ? -1 : 0)) * 60) + m) * 60) + s;
}

static byte dcfExtract (byte pos, byte len) {
    word *p = (word*) (dcfValue + (pos >> 3));
    byte val = (*p >> (pos & 7)) & ((1 << len) - 1);
    return val - (val / 16) * 6; // bcd -> dec
}

static byte dcfMinute () {
    dcfBuf[0] = dcfExtract(50, 8);
    dcfBuf[1] = dcfExtract(45, 5);
    dcfBuf[2] = dcfExtract(36, 6);
    dcfBuf[3] = dcfExtract(29, 6);
    dcfBuf[4] = dcfExtract(21, 7);
    dcfBuf[5] = dcfExtract(17, 1);
    return 1 <= dcfBuf[0] && dcfBuf[0] <= 99 &&
            1 <= dcfBuf[1] && dcfBuf[1] <= 12 &&
             1 <= dcfBuf[2] && dcfBuf[2] <= 31 &&
              dcfBuf[3] <= 23 && dcfBuf[4] <= 59;
}

static void dcf77setup () {
    pinMode(PIN_DCF, INPUT);
    digitalWrite(PIN_DCF, 1); // pull-up
}

static byte dcf77poll (byte signal) {
    byte ok = 0;
    static uint32_t last;
    if (millis() != last) {
        last = millis();

        // track signal levels using an 8-bit shift register
        dcfLevels = (dcfLevels << 1) | signal;
        if (dcfLevels == 0x07F) {
            if (dcfWidth > 1000) {
                if (dcfBits == 59)
                    ok = dcfMinute();
                memset(dcfValue, 0, sizeof dcfValue);
                dcfBits = 0;
            }
            dcfWidth = 0;
        } else if (dcfLevels == 0xFE) {
            // Serial.print("dcf width ");
            // Serial.println((int) dcfWidth);
            if (dcfWidth >= 144) {
                dcfValue[dcfBits>>3] |= _BV(dcfBits & 7);
                dcfParity ^= 1;
            }
            switch (++dcfBits) {
                case 15: dcfParity = 0;
                case 29: case 36: case 59: if (dcfParity) dcfBits = 0;
            }
            dcfWidth = 0;
        }
        ++dcfWidth;
    }
    return ok;
}

// sent = end of buffer as sent in last packet
// fill = end of data in sendBuf, always >= sent
static byte sendBuf[64], sent, fill;

// append data to the send buffer, with type/length byte preceding it
static void newData (const void* ptr, byte len, byte type) {
    // if the data doesn't fit, clear send buffer first
    if (fill + 1 + len > sizeof sendBuf)
        sent = fill = 0;
    // append type/length byte and actual data to send buffer
    sendBuf[fill++] = len | (type << 4);
    memcpy(sendBuf + fill, ptr, len);
    fill += len;
}

// remove the sent data from the buffer, shift down any remaining data
static void dropData () {
    memmove(sendBuf, sendBuf + sent, fill - sent);
    fill -= sent;
    sent = 0;
}

void setup () {
    Serial.begin(57600);
    Serial.println("\n[ookRelay]");
    rf12_initialize(NODE_ID, NODE_MHZ, NODE_GROUP);
    ook868setup();
    ook433setup();
    dcf77setup();
    pressure.getCalibData();
}

void loop () {
    byte buf[10];
    byte len = ook868poll(buf);
    if (len) {
        static char* names[] = {
            "S300", "FS20", "FS20X", "KS300", "?", "EM10", 
        };
        Serial.print(names[len-4]);
        for (byte i = 0; i < len; ++i) {
            Serial.print(' ');
            Serial.print(buf[i], DEC);
        }
        Serial.println();
        newData(buf, len, RF868);
    }

    int k = ook433poll();
    if (k >= 0) {
        Serial.print("KAKU ");
        Serial.println(k, HEX);
        newData(&k, sizeof k, RF433);
    }
    
    if (dcf77poll(digitalRead(PIN_DCF))) {
        Serial.print("DCF ");
        Serial.print(2000 + dcfBuf[0], DEC);
        Serial.print(' ');
        Serial.print(dcfBuf[1], DEC);
        Serial.print(' ');
        Serial.print(dcfBuf[2], DEC);
        Serial.print(' ');
        Serial.print(dcfBuf[3], DEC);
        Serial.print(' ');
        Serial.print(dcfBuf[4], DEC);
        Serial.print(' ');
        Serial.print(dcfBuf[5], DEC);
        Serial.print(' ');
        word days = date2days(dcfBuf[0], dcfBuf[1], dcfBuf[2]);
        Serial.println(unixTime(days, dcfBuf[3], dcfBuf[4], 0, dcfBuf[5]));
        newData(dcfBuf, 6, DCF77);
    }
    
    // if the sensor is not present, we'll get a bogus value back
    if (baroTimer.poll(60000) && pressure.measure(BMP085::TEMP) != 0xFFFF) {
        pressure.measure(BMP085::PRES);
        int baroBuf[2];
        long pres;
        pressure.calculate(baroBuf[0], pres);
        baroBuf[1] = pres / 10;
        
        Serial.print("BMP ");
        Serial.print(baroBuf[0]);
        Serial.print(' ');
        Serial.println(baroBuf[1]);
        newData(baroBuf, sizeof baroBuf, BARO);
    }

    // the rest of the code deals with relaying the decoded data via RF12
    // sending starts a re-send timer, which gets cleared when an ack comes in
    // careful with new data while some of the old data has already been sent
    
    static byte retries; // automatic resend detection
    
    if (rf12_recvDone() && rf12_crc == 0 &&
            rf12_hdr == (RF12_HDR_CTL | RF12_HDR_DST | NODE_ID)) {
        Serial.print(" ACK, sent ");
        Serial.print(sent, DEC);
        Serial.print(" fill ");
        Serial.println(fill, DEC);
        dropData(); // got an ack, clear pending data
        sendTimer.set(0);
        // retries = 8; // next send can do up to 8 retries, since we saw an ack
    }
    
    if (fill > 0 && rf12_canSend() &&
            (sendTimer.idle() || sendTimer.poll() && retries > 0)) {
        Serial.print(" OUT, sent ");
        Serial.print(sent, DEC);
        Serial.print(" fill ");
        Serial.println(fill, DEC);
        rf12_sendStart(RF12_HDR_ACK, sendBuf, fill);
        sent = fill;
        if (retries > 0) {
            --retries;
            sendTimer.set(3000);
        } else
            dropData();
    }
}

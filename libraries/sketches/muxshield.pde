// Multiplex up to 5 FTDI-connected slave boards via software serial emulation
// Also has logic to re-flash the slaves from data stored by the boot loader.
// 2009-03-17 <jcw@equi4.com> http://opensource.org/licenses/mit-license.php

#include <NewSoftSerial.h>
#include <avr/pgmspace.h>

// RX_BUFSIZ and TX_BUFSIZ both have to be a power of two
#define RX_BUFSIZ   128
#define RX_MASK     (RX_BUFSIZ - 1)
#define TX_BUFSIZ   32
#define TX_MASK     (TX_BUFSIZ - 1)

// pin allocations

#define TXD1    2
#define TXD2    3
#define TXD3    4
#define TXD4    5
#define TXD5    6
                
#define DTR1    8
#define DTR2    9
#define DTR3    10
#define DTR4    11
#define DTR5    12

#define RXD1    14
#define RXD2    15
#define RXD3    16
#define RXD4    17
#define RXD5    18

#define SENSE   7   // switch, 0 = ALT, 1 = STD
#define RED     13  // red LED
#define GREEN   19  // green LED

// all the RX inputs are on port C, bits 0..4
#define rxdBit(idx)     bitRead(PINC, (idx))
// all the TX outputs are on port D, bits 2..6
#define txdSet(mask)    (PIND = (PIND & 0x83) | (mask))

uint8_t state[5], rxdata[5], rxnext[5], rxfill[5], txnext[5], txfill[5];
uint8_t rxbuf[5][RX_BUFSIZ], txbuf[5][TX_BUFSIZ];
volatile int16_t rxavail[5];
uint8_t currChan, activeChan, demuxChan;
volatile uint8_t txpos;
uint8_t txdata[30];

// used only for reflashing
NewSoftSerial ss (RXD1, TXD1);

static void waitStart(uint8_t idx) {
    state[idx] = 1 - rxdBit(idx);
}

static void verifyStart(uint8_t idx) {
    state[idx] = (1 - rxdBit(idx)) << 1;
}

static void skip(uint8_t idx) {
    ++state[idx];
}

static void readBit(uint8_t idx) {
    rxdata[idx] = (rxdata[idx] >> 1) + (rxdBit(idx) << 7);
    ++state[idx];
}

static void dataReady(uint8_t idx) {
    rxavail[idx] = rxdata[idx];
    ++state[idx];
}

static void resumeIdle(uint8_t idx) {
    state[idx] &= rxdBit(idx) - 1;
}

void (*rxdecoder[])(uint8_t) = {
    waitStart, verifyStart,
    skip, skip, readBit,
    skip, skip, readBit,
    skip, skip, readBit,
    skip, skip, readBit,
    skip, skip, readBit,
    skip, skip, readBit,
    skip, skip, readBit,
    skip, skip, readBit,
    dataReady, resumeIdle,
};

SIGNAL(TIMER1_COMPA_vect) {
    rxdecoder[state[0]](0);
    rxdecoder[state[1]](1);
    rxdecoder[state[2]](2);
    rxdecoder[state[3]](3);
    rxdecoder[state[4]](4);
    
    if (txpos < sizeof txdata) {
        txdSet(txdata[txpos]);
        txdata[txpos++] |= 0x7C;
    }
}

static void setBaud(long baud) {
    int divisor = F_CPU / (3 * baud);

    // WGM mode 4, no prescaler (1:1)
    TCCR1A = 0;
    TCCR1B = bit(WGM12) | bit(CS10);
    // fire at three times the baud rate
    OCR1A = divisor;
    TIMSK1 = bit(OCIE1A);

    Serial.print("BAUD ");
    Serial.print(baud);
    Serial.print(" DIV ");
    Serial.println(divisor);
}

static void setTxBit(uint8_t mask, uint8_t pos, uint8_t value) {
    if (value == 0) {
        txdata[pos++] ^= mask; 
        txdata[pos++] ^= mask; 
        txdata[pos] ^= mask; 
    }
}

static void waitForAck(NewSoftSerial& ss) {
#if 0
    uint8_t c;
    while ((c = ss.read()) != 0x14)
        Serial.println(c, HEX);
    while ((c = ss.read()) != 0x10)
        Serial.println(c, HEX);
#else
    while (ss.read() != 0x14)
        ;
    while (ss.read() != 0x10)
        ;
#endif
}

static void resetSlave(uint8_t idx) {
    digitalWrite(DTR1 + idx, 1);
    delay(3);
    digitalWrite(DTR1 + idx, 0); // the downward flank resets
}

static void reflashSlave(uint8_t idx) {
    ss.setRX(RXD1 + idx);
    ss.setTX(TXD1 + idx);
    ss.begin(19200);

    resetSlave(idx);
    delay(250);
    
    // check for an attached board
    ss.print("0 ");
    long limit = millis() + 500;
    while (!ss.available())
        if (millis() >= limit)
            return; // no response

    waitForAck(ss);
    
    Serial.print("Programming #");
    Serial.print(idx + 1);
    Serial.print(' ');
    digitalWrite(RED, 1);
    
    for (uint16_t addr = 0; addr < 0x3800; addr += 128) {
        Serial.print('.');
        // send word address
        ss.print('U');
        ss.print((uint8_t) (addr >> 1));
        ss.print((uint8_t) (addr >> 9));
        ss.print(' ');
        waitForAck(ss);
        // send one page of data
        ss.print('d');
        ss.print((uint8_t) 0);
        ss.print((uint8_t) 128);
        ss.print('m');
        uint8_t mask = 0xFF;
        for (uint8_t i = 0; i < 128; ++i) {
            uint8_t b = pgm_read_byte(addr + i + 0x3800);
            ss.print(b);
            mask &= b;
        }
        ss.print(' ');
        waitForAck(ss);
        if (mask == 0xFF)
            break; // last page consisted of only 0xFF's
    }
    
    digitalWrite(RED, 0);
    Serial.println(" done");
}

void setup() {
    Serial.begin(57600);
    Serial.println("\n[muxshield]");
    
    digitalWrite(RED, 0);
    digitalWrite(GREEN, 0);
    pinMode(RED, OUTPUT);
    pinMode(GREEN, OUTPUT);

    // initialize all channels
    for (uint8_t idx = 0; idx < 5; ++idx) {
        digitalWrite(RXD1 + idx, 1);
        digitalWrite(TXD1 + idx, 1);
        digitalWrite(DTR1 + idx, 1);
        pinMode(RXD1 + idx, INPUT);
        pinMode(TXD1 + idx, OUTPUT);
        pinMode(DTR1 + idx, OUTPUT);
        rxavail[idx] = -1;
    }
    
    // send the stored program code to all slaves if so requested
    if (digitalRead(SENSE) == 0) {
        for (uint8_t idx = 0; idx < 5; ++idx)
            reflashSlave(idx);
        // disable all pin change interrupts, this switches off NewSoftSerial
        PCICR = PCMSK0 = PCMSK1 = PCMSK2 = 0;
    }
    
    // prepare the transmit bits
    memset(txdata, 0x7C, txpos);
    
    // reset all channels at the same time
    for (uint8_t idx = 0; idx < 5; ++idx)
        resetSlave(idx);
    
    activeChan = -1; // force switch on first send
    
    // start decoding received data
    setBaud(9600);
}

void loop() {
    // place available characters in their receive buffers
    for (uint8_t idx = 0; idx < 5; ++idx) {
        if (rxavail[idx] >= 0) {
            uint8_t fill = rxfill[idx];
            rxbuf[idx][fill] = rxavail[idx];
            rxfill[idx] = (fill + 1) & RX_MASK;
            rxavail[idx] = -1;
        }
    }
    
    if (UCSR0A & bit(UDRE0)) {
        // the serial transmitter has room to send another byte
        uint8_t idx = currChan;
        uint8_t next = rxnext[idx];
        uint8_t canSend = next != rxfill[idx];
        if (canSend) {
            // this channel has data to send
            if (activeChan != idx) {
                // we're not "on" this channel right now, switch to it first
                activeChan = idx;
                Serial.print((char) (idx + 1)); // send switch byte: 0x01..0x05
            } else {
                // send one byte for this channel
                Serial.print(rxbuf[idx][next]);
                rxnext[idx] = (next + 1) & RX_MASK;
            }
        } else {
            // no data left to send here, move on to next channel
            if (++currChan >= 5)
                currChan = 0;
        }
        digitalWrite(GREEN, canSend);
    }
    
    if (Serial.available()) {
        char c = Serial.read();
        if (1 <= c && c <= 5)
            demuxChan = c - 1;
        else {
            uint8_t idx = demuxChan;
            uint8_t fill = txfill[idx];
            txbuf[idx][fill] = c;
            txfill[idx] = (fill + 1) & TX_MASK;
            if (txpos > sizeof txdata)
                txpos = sizeof txdata; // there is something to send
        }
    }
    
    if (txpos == sizeof txdata) {
        // advance txpos one more past end if there is nothing to send
        uint8_t pos = sizeof txdata + 1;
        for (uint8_t idx = 0; idx < 5; ++idx) {
            uint8_t next = txnext[idx];
            if (next != txfill[idx]) {
                uint8_t c = txbuf[idx][next];
                uint8_t mask = bit(idx + 2);
                setTxBit(mask, 0, 0);
                setTxBit(mask, 3, c & 0x01);
                setTxBit(mask, 6, c & 0x02);
                setTxBit(mask, 9, c & 0x04);
                setTxBit(mask, 12, c & 0x08);
                setTxBit(mask, 15, c & 0x10);
                setTxBit(mask, 18, c & 0x20);
                setTxBit(mask, 21, c & 0x40);
                setTxBit(mask, 24, c & 0x80);
                txnext[idx] = (next + 1) & TX_MASK;
                pos = 0;
            }
        }
        txpos = pos; // this will start sending, if pos is zero
    }
}

// Driver for 16x32 led panel from Futurlec
// see http://news.jeelabs.org/2009/09/29/another-display-option/
// 2009-09-15 <jcw@equi4.com> http://opensource.org/licenses/mit-license.php
// $Id: led16x32.pde 6001 2010-09-09 22:49:39Z jcw $

#define CLOCK   4
#define LATCH   5
#define STROBE  6
#define SN1     14
#define SN2     15
#define SN3     16

static void initLEDs (byte dim) {
    pinMode(CLOCK, OUTPUT);
    pinMode(STROBE, OUTPUT);
    pinMode(LATCH, OUTPUT);
    pinMode(SN1, OUTPUT);
    pinMode(SN2, OUTPUT);
    pinMode(SN3, OUTPUT);
    digitalWrite(CLOCK, 0);
    digitalWrite(STROBE, 1);
    digitalWrite(LATCH, 1);
    digitalWrite(SN1, 0);
    digitalWrite(SN2, 0);
    digitalWrite(SN3, 0);    
    setLEDs(16, 0, 0);
    analogWrite(STROBE, dim); // 0 = bright, 254 = dim, 255 = off
}

static void setLEDs (byte column, word left, word right) {
    for (byte i = 0; i < 16; ++i) {
        digitalWrite(SN1, i == column);
        digitalWrite(SN2, left & 1); left >>= 1;
        digitalWrite(SN3, right & 1); right >>= 1;
        digitalWrite(CLOCK, 1);
        digitalWrite(CLOCK, 0);
    }
    digitalWrite(LATCH, 0);
    digitalWrite(LATCH, 1);
}

void setup () {
    initLEDs(240);
}

static word greeting[][2] = {
    { 0x0001, 0xDDAA },
    { 0x0003, 0x9DAA },
    { 0x0007, 0x1DAA },
    { 0x000E, 0x1DAA },
    { 0x001C, 0x1DAA },
    { 0x0038, 0x1DAA },
    { 0x0070, 0x1DAA },
    { 0x00E0, 0x1DAA },
    { 0x01C0, 0x1DAA },
    { 0x0380, 0x1DAA },
    { 0x0700, 0x1DAA },
    { 0x0E00, 0x1DAA },
    { 0x1C00, 0x1DAA },
    { 0x3800, 0x1DAA },
    { 0x7000, 0x1DAA },
    { 0xFFFF, 0xDDAA },
};

void loop () {
    word t = micros();
    if (t & 0x3F0)
        return;
    byte i = (t >> 10) & 0x0F;
    
    setLEDs(i, greeting[i][0], greeting[i][1]);
}

// Decode DCF-77 radio signal and show time of day on a 7-segment LED display
// This code uses no timers, it's all done from a millisecond polling loop
// Project home page is http://lab.equi4.com/files/sequential_clock.php
//
// 2008-11-18  v1  public release by Jean-Claude Wippler as MIT-licensed OSS
// 2008-11-27  v2  fix negative/overflow bug by using unsigned values

#include <stdio.h> // sprintf, not essential (prints timestamp to serial I/O)

//##############################################################################
// DCF77 receiver decode logic
// see http://www.giangrandi.ch/electronics/dcf77/signal.html

// pins used for dcf receiver, chosen to match physical pin-out
#define DCF_POWER_PIN 2
#define DCF_EARTH_PIN 3
#define DCF_PULSE_PIN 4
#define DCF_RESET_PIN 5

// the on-board led will track the pulse value
#define DEBUG_LED_PIN 13

// pulses shorter than 140 ms are 0, longer are 1
#define TRIGGER_TIME 140
// count twice as long, decide by whether more or less than half were set
#define COUNT_TIME (2 * TRIGGER_TIME)
// wait another 620 mS (i.e. total 900) ignoring signal, then look for up flank
#define WAIT_TIME 620
// no pulse within 1.6 s means this is the 59s gap
#define GAP_TIME (1600 - (COUNT_TIME + WAIT_TIME))

char bitcount;            // next bit to be decoded
char parity;              // parity so far
long long databits;       // reception buffer, collects 59 bits as single value
int year;                 // decoded year
char month, day, hh, mm;  // other decoded values
char ok;                  // true if the decoded values are valid
unsigned long nextmin = 999999999; // when to bump to the next min if no signal

void initDCF() {
  // the DCF receiver needs its reset line held high to make it start reliably
  pinMode(DCF_POWER_PIN, OUTPUT);
  pinMode(DCF_EARTH_PIN, OUTPUT);
  pinMode(DCF_RESET_PIN, OUTPUT);
  digitalWrite(DCF_POWER_PIN, 1);
  digitalWrite(DCF_EARTH_PIN, 0);
  digitalWrite(DCF_RESET_PIN, 1);
  delay(1000);
  digitalWrite(DCF_RESET_PIN, 0);
}

int extractBCD(int pos, int len) {
  char val = (char) (databits >> pos) & ((1 << len) - 1);
  return val - (val / 16) * 6;
}

void markMinute() {
  Serial.println();
  if (bitcount == 59 && !parity) {
    year = extractBCD(50, 8) + 2000;
    month = extractBCD(45, 5);
    day = extractBCD(36, 6);
    hh = extractBCD(29, 6);
    mm = extractBCD(21, 7);
    ok = 2008 <= year && year <= 2099 && 1 <= month && month <= 12 &&
          1 <= day && day <= 31 && hh <= 23 && mm <= 59;
    char buf[20];            // 
    sprintf(buf, "%c %04d/%02d/%02d %02d:%02d", ok ? '=' : '?',
						year, month, day, hh, mm);
    Serial.println(buf);
  }
}

void markSecond(int tally) {
  int bitval = tally / TRIGGER_TIME;
  databits |= (long long) bitval << bitcount;
  parity ^= bitval;
  switch (bitcount++) {
  case 14:
    // ignore bits 0..14, and assume they always have even parity
    parity = 0;
    break;
  case 28: 
  case 35:
    if (parity) {
      Serial.println('?');
      bitcount = 0; // forces rejection because the gap won't end up at bit 59
    }
    break;
  }
  Serial.print(bitval);
}

void pollDCF(char pin) {
  enum { 
    Idle, Starting, Counting, Waiting
  };
  static char state = Idle;
  static int ms = 0;
  static int tally;

  switch (state) {
  case Idle: // wait for the leading flank, also check for the 59s gap
    if (++ms > GAP_TIME) {
      markMinute();
      ms = bitcount = parity = 0;
      databits = 0;
    } 
    else if (pin)
      state = Starting;
    break;
  case Starting: // leading flank seen, check that it is still high 1 ms later
    if (pin) {
      state = Counting;
      ms = tally = 0;
    }
    break;
  case Counting: // first part: count how many times the signal is high
    tally += pin;
    if (++ms > COUNT_TIME) {
      markSecond(tally);
      state = Waiting;
      ms = 0;
    }
    break;
  case Waiting: // second part: ignore the signal until almost the next pulse
    if (++ms > WAIT_TIME && !pin) {
      state = Idle;
      ms = 0;
    }
    break;
  }
}

void advance() {
  if (++mm >= 60) {
    mm = 0;
    if (++hh >= 24)
      hh = 0;
  }
}

//##############################################################################
// Sequential 7-segment LED display logic
//
// 7-segment bit allocation used in the "digits" array:
//
//     b7 b7 b7
//  b2          b6
//  b2          b6
//  b2          b6
//     b1 b1 b1
//  b3          b5
//  b3          b5
//  b3          b5
//     b4 b4 b4    b0    

// pins used for the 7 leds, plus the decimal point (pin0 = b7, ..., pin7 = b0)
#define DISPLAY_PIN0  6
#define DISPLAY_PIN1  7
#define DISPLAY_PIN2  8
#define DISPLAY_PIN3  9
#define DISPLAY_PIN4  10
#define DISPLAY_PIN5  11
#define DISPLAY_PIN6  12
#define DISPLAY_PIN7  14

// special "digits"
#define DOT   10
#define BLANK 11

// display rate, how many millisecs to display each digit before moving on
#define DIGIT_TIME 500

char currdigit;     // index of current digit being displayed
char fill = 18;     // number of digits to display initially
char digits[50] = { // buffer for decoded digits to show
  0x7A, // D
  0xEE, // A
  0xBC, // G
  0x00,
  0x70, // J
  0xFC, // O
  0xB6, // S
  0x00,
  0x70, // J
  0xEE, // A
  0xB6, // S
  0xCE, // P
  0x9E, // E
  0x0A, // R
  0xB6, // S
  0x00,
  0x00,
  0x00,
}; // this initial contents will be shown until good DCF reception

void init7seg() {
  pinMode(DISPLAY_PIN0, OUTPUT);
  pinMode(DISPLAY_PIN1, OUTPUT);
  pinMode(DISPLAY_PIN2, OUTPUT);
  pinMode(DISPLAY_PIN3, OUTPUT);
  pinMode(DISPLAY_PIN4, OUTPUT);
  pinMode(DISPLAY_PIN5, OUTPUT);
  pinMode(DISPLAY_PIN6, OUTPUT);
  pinMode(DISPLAY_PIN7, OUTPUT);
}

void clear7seg() {
  fill = 0;
}

void addDigit(char value) {
  if (fill < sizeof digits) {
    switch (value) {
      case 0:   value = 0xFC; break;
      case 1:   value = 0x60; break;
      case 2:   value = 0xDA; break;
      case 3:   value = 0xF2; break;
      case 4:   value = 0x66; break;
      case 5:   value = 0xB6; break;
      case 6:   value = 0x3E; break;
      case 7:   value = 0xE0; break;
      case 8:   value = 0xFE; break;
      case 9:   value = 0xE6; break;
      case DOT: value = 0x01; break;
      default:  value = 0x00; break;
    }
    digits[fill++] = value;
  }
}

void update7seg(unsigned cycle) {
  char mask = fill > 0 ? digits[cycle % fill] : 0;
  // unrolled loop, to avoid taking too much time
  digitalWrite(DISPLAY_PIN0, (mask & 0x80) != 0);
  digitalWrite(DISPLAY_PIN1, (mask & 0x40) != 0);
  digitalWrite(DISPLAY_PIN2, (mask & 0x20) != 0);
  digitalWrite(DISPLAY_PIN3, (mask & 0x10) != 0);
  digitalWrite(DISPLAY_PIN4, (mask & 0x08) != 0);
  digitalWrite(DISPLAY_PIN5, (mask & 0x04) != 0);
  digitalWrite(DISPLAY_PIN6, (mask & 0x02) != 0);
  digitalWrite(DISPLAY_PIN7, (mask & 0x01) != 0);
}

//##############################################################################
// Glue code, one-time setup, and main run loop

void displayTime() {
  clear7seg();
  addDigit(hh / 10);
  addDigit(hh % 10);
  addDigit(DOT);
  addDigit(mm / 10);
  addDigit(mm % 10);
  addDigit(BLANK);
  addDigit(BLANK);
  addDigit(BLANK);
}

void setup() {
  Serial.begin(115200);
  Serial.println("\n[DCF77_JOS.2]");
  
  init7seg();
  initDCF();
}

static unsigned long msecs;

void loop() {
  digitalWrite(DEBUG_LED_PIN, digitalRead(DCF_PULSE_PIN));

  if (msecs != millis()) {
    msecs = millis();
    
    // will set ok to 1 each time a good time has been received
    pollDCF(digitalRead(DCF_PULSE_PIN));
    
    // advance to next minute when it's time, even without dcf reception
    if (!ok && msecs >= nextmin) {
      advance();
      ok = 1;
    }
    
    // display the new time
    if (ok) {
      nextmin = msecs + 60000;
      displayTime();
      ok = 0;
    }

    if (msecs % DIGIT_TIME <= 1)
      update7seg(msecs / DIGIT_TIME);
  }
}

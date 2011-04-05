// Test 433 MHz receiver
// Project home page is http://lab.equi4.com/files/wireless433.php
//
// 2008-11-27  v1  public release by Jean-Claude Wippler as MIT-licensed OSS
// 2008-12-02      don't display past received bytes, ignore empty/noise packets
// 2008-12-03      omit internal pullup, much better sync start bytes and logic
//
// Hardware setup: Arduino with Conrad 433 MHz receiver connected as follows:
//
//    +----------------------------+
//    |                         () +-- Antenna
//    |                            |
//    +-+---+--------------------+-+
//      |   |                    |
//     GND +5V               DATA/D10
//
// Sample output with two good receptions and a bad one:
//
// [RECV433_TEST.1]
// 1 3:22/0#0 --------------------------------------> OK!
//  0 1 2 0 1 2 0 1 2 0 1 2 0 1 2 0 1 2 0 1 56 243
// 2 3:22/0#0 --------------------------------------> OK!
//  0 1 2 0 1 2 0 1 2 0 1 2 0 1 2 0 1 2 0 1 56 243
// 3 3:4/22576#2
//  255 255 255 255
// [etc]

#include <util/crc16.h>

#define RXDATA 10
#define RX_PIN (PINB & _BV(PINB2))

char rxdata;
char bytes[22];
int crc, errors;

void setup() {
  Serial.begin(115200);
  Serial.println("\n[RECV433_TEST.1]");
  pinMode(RXDATA, INPUT);
}

int sync() {
  while (!RX_PIN)
    ;
  char last = millis(), pulse = 0;
  while (RX_PIN)
    pulse = millis() - last;
  return pulse;
}

char readBit() {
  delayMicroseconds(50);
  if (!RX_PIN)
    ++errors;
  delayMicroseconds(400);
  rxdata = (rxdata << 1) | (RX_PIN != 0);
  while (RX_PIN)
    ;
  delayMicroseconds(50);
  if (RX_PIN)
    ++errors;
  while (!RX_PIN)
    ;
  return rxdata;
}

void loop() {
  int leadin, i, n;
  
  while ((leadin = sync()) < 3 || leadin > 7)
    ;
  rxdata = 0xFF;
  while (readBit() != 0x01)
    ;
  
  crc = ~0;
  errors = 0;
  for (i = 0; i < sizeof bytes; ++i) {
    for (int j = 0; j < 8; ++j)
      readBit();
    bytes[i] = rxdata;
    crc = _crc16_update(crc, rxdata);
    if (errors)
      break;
  }
  
  n = i;
  if (n == 0)
    return; // ignore short junk
  
  static int tally = 0;
  tally = (tally + 1) % 10;
  Serial.print(tally);      // receive packet number
  Serial.print(' ');
  Serial.print(leadin);     // number of msecs in leadin
  Serial.print(':');
  Serial.print(i);          // number of bits received
  Serial.print('/');
  Serial.print(crc);        // calculated crc value, will be 0 if data is ok
  Serial.print('#');
  Serial.print(errors);     // number of errors in second bit half
  if (crc == 0 && errors == 0)
    Serial.print(" --------------------------------------> OK!");
  Serial.println();
  
  for (i = 0; i < n; ++i) {
    Serial.print(' ');
    Serial.print(bytes[i] & 0xFF);
  }
  Serial.println();
}

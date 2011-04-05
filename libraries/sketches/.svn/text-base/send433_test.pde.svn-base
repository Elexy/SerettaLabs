// Test 433 MHz transmitter
// Project home page is http://lab.equi4.com/files/wireless433.php
//
// 2008-11-27  v1  public release by Jean-Claude Wippler as MIT-licensed OSS
// 2008-12-03      add on-while-sending led and send improved packet header
//
// Hardware setup: Arduino with Conrad 433 MHz transmitter connected as follows:
//
//                    +5V
//                     |
//    +----------------+-+
//    |                  |
//    |               () |
//    +-+--------------+-+
//      |              |
//  DATA/D2           GND

#include <util/crc16.h>

#define TXDATA 2
#define TX_SET (PORTD |= _BV(PD2))
#define TX_CLEAR (PORTD &= ~_BV(PD2))

#define LED 13

char bytes[20];

void sendByte(char data) {
  for (int i = 0; i < 8; ++i) {
    int width = data & 0x80 ? 0 : 400;
    delayMicroseconds(200 + width);
    TX_SET;
    delayMicroseconds(800 - width);
    TX_CLEAR;
    data <<= 1;
  }
}

void sendBuffer() {
  // 5 msec start pulse, for conditioning
  TX_SET;
  delay(5);
  TX_CLEAR;

  // calculate crc
  int crc = ~0;
  for (char i = 0; i < sizeof bytes; ++i)
    crc = _crc16_update(crc, bytes[i]);
  
  // send header, data buffer, and crc
  for (char i = 0; i < 5; ++i)
    sendByte(0x16);
  sendByte(0x01);
  for (char i = 0; i < sizeof bytes; ++i)
    sendByte(bytes[i]);
  sendByte(crc);
  sendByte(crc >> 8);
    
  // 50 msec idle
  delay(50);
}

void setup() {
  pinMode(LED, OUTPUT);
  pinMode(TXDATA, OUTPUT);
  TX_CLEAR;
  
  int i;
  for (i = 0; i < sizeof bytes; ++i)
    bytes[i] = i % 3;
}

void loop() {
  digitalWrite(LED, 1);
  sendBuffer();
  digitalWrite(LED, 0);
  delay(3000);
}

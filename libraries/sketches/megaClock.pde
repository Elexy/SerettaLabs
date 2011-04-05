// Real time clock with LCD display using plugs + Plug Shield, see also jeeClock
// 2009-11-29 <jcw@equi4.com> http://opensource.org/licenses/mit-license.php
// $Id: megaClock.pde 6001 2010-09-09 22:49:39Z jcw $

#include <PortsLCD.h>
#include <RTClib.h>
#include <Wire.h>
#include <RF12.h> // needed to avoid a linker error :(

// interface to the LCD plug using the Wire library

enum {
  MCP_IODIR, MCP_IPOL, MCP_GPINTEN, MCP_DEFVAL, MCP_INTCON, MCP_IOCON,
  MCP_GPPU, MCP_INTF, MCP_INTCAP, MCP_GPIO, MCP_OLAT
};

// bits 0..3 and D4..D7, the rest is connected as follows
#define MCP_BACKLIGHT   0x80
#define MCP_ENABLE      0x40
#define MCP_OTHER       0x20
#define MCP_REGSEL      0x10

class MyLCD : public LiquidCrystalBase {
  byte address;
public:
  MyLCD (byte addr =0x24) : address (addr) {
    _displayfunction = LCD_4BITMODE | LCD_1LINE | LCD_5x8DOTS;
  }
protected:
  virtual void config() {
    // IOCON: SEQOP = 1, ODR = 1, rest zero
    Wire.beginTransmission(address);
    Wire.send(MCP_IOCON);
    Wire.send(0x24);
    Wire.endTransmission();
    // set all outputs, the remaining power-up default register values are all 0
    Wire.beginTransmission(address);
    Wire.send(MCP_IODIR);
    Wire.send(0); // IODIR: all outputs
    Wire.endTransmission();
  }
  virtual void send(byte value, byte mode) {
    if (mode != 0)
      mode = MCP_REGSEL;
    write4bits((value >> 4) | mode);
    write4bits((value & 0x0F) | mode);
  }
  virtual void write4bits(byte value) {
    value |= MCP_BACKLIGHT | MCP_ENABLE;
    Wire.beginTransmission(address);
    Wire.send(MCP_GPIO);
    Wire.send(value);
    Wire.send(value ^ MCP_ENABLE);
    Wire.send(value);
    Wire.endTransmission();
  }
};

MyLCD lcd;
RTC_DS1307 rtc;

static void print2dig(byte value, char sep) {
  lcd.print(value/10);
  lcd.print(value%10);
  lcd.print(sep);
}

void setup() {
  Wire.begin();
  lcd.begin(16, 2);
  rtc.begin();
  
  // uncomment next line to adjust the RTC
  //rtc.adjust(DateTime(__DATE__, __TIME__));
}

void loop() {
  DateTime now = rtc.now();
  
  lcd.setCursor(0, 0);
  lcd.print(now.year());
  lcd.print('/');
  print2dig(now.month(), '/');
  print2dig(now.day(), ' ');
  
  lcd.setCursor(0, 1);
  print2dig(now.hour(), ':');
  print2dig(now.minute(), ':');
  print2dig(now.second(), ' ');
}

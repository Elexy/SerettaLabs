// Demo sketch for LCD connected to I2C port via MCP230017 I/O expander
// 2009-09-23 <jcw@equi4.com> http://opensource.org/licenses/mit-license.php
// $Id: lcdPlug.pde 6001 2010-09-09 22:49:39Z jcw $

// extended from the LiquidCrystal library from the Arduino 0017 IDE
// see http://news.jeelabs.org/2009/09/26/generalized-liquidcrystal-library/

// #ifndef LiquidCrystal_h
// #define LiquidCrystal_h

#include <inttypes.h>
#include "Print.h"

// commands
#define LCD_CLEARDISPLAY 0x01
#define LCD_RETURNHOME 0x02
#define LCD_ENTRYMODESET 0x04
#define LCD_DISPLAYCONTROL 0x08
#define LCD_CURSORSHIFT 0x10
#define LCD_FUNCTIONSET 0x20
#define LCD_SETCGRAMADDR 0x40
#define LCD_SETDDRAMADDR 0x80

// flags for display entry mode
#define LCD_ENTRYRIGHT 0x00
#define LCD_ENTRYLEFT 0x02
#define LCD_ENTRYSHIFTINCREMENT 0x01
#define LCD_ENTRYSHIFTDECREMENT 0x00

// flags for display on/off control
#define LCD_DISPLAYON 0x04
#define LCD_DISPLAYOFF 0x00
#define LCD_CURSORON 0x02
#define LCD_CURSOROFF 0x00
#define LCD_BLINKON 0x01
#define LCD_BLINKOFF 0x00

// flags for display/cursor shift
#define LCD_DISPLAYMOVE 0x08
#define LCD_CURSORMOVE 0x00
#define LCD_MOVERIGHT 0x04
#define LCD_MOVELEFT 0x00

// flags for function set
#define LCD_8BITMODE 0x10
#define LCD_4BITMODE 0x00
#define LCD_2LINE 0x08
#define LCD_1LINE 0x00
#define LCD_5x10DOTS 0x04
#define LCD_5x8DOTS 0x00

class LiquidCrystalBase : public Print {
public:
  LiquidCrystalBase () {}
  
  void begin(byte cols, byte rows, byte charsize = LCD_5x8DOTS);

  void clear();
  void home();

  void noDisplay();
  void display();
  void noBlink();
  void blink();
  void noCursor();
  void cursor();
  void scrollDisplayLeft();
  void scrollDisplayRight();
  void leftToRight();
  void rightToLeft();
  void autoscroll();
  void noAutoscroll();

  void createChar(byte, byte[]);
  void setCursor(byte, byte); 
  virtual void write(byte);
  void command(byte);
protected:
  virtual void config() =0;
  virtual void send(byte, byte) =0;
  virtual void write4bits(byte) =0;

  byte _displayfunction;
  byte _displaycontrol;
  byte _displaymode;
  byte _initialized;
  byte _numlines,_currline;
};

// #endif
// end of LC.h
// #include "LiquidCrystal.h"

#include <stdio.h>
#include <string.h>
#include <inttypes.h>
#include "WProgram.h"

#if 0
LiquidCrystalBase::LiquidCrystalBase(byte rs, byte rw, byte enable,
			     byte d0, byte d1, byte d2, byte d3)
{
  init(1, rs, rw, enable, d0, d1, d2, d3, 0, 0, 0, 0);
}

void LiquidCrystalBase::init(byte fourbitmode, byte rs, byte rw, byte enable,
			 byte d0, byte d1, byte d2, byte d3,
			 byte d4, byte d5, byte d6, byte d7)
{
  _rs_pin = rs;
  _rw_pin = rw;
  _enable_pin = enable;
  
  _data_pins[0] = d0;
  _data_pins[1] = d1;
  _data_pins[2] = d2;
  _data_pins[3] = d3; 
  _data_pins[4] = d4;
  _data_pins[5] = d5;
  _data_pins[6] = d6;
  _data_pins[7] = d7; 

  pinMode(_rs_pin, OUTPUT);
  // we can save 1 pin by not using RW. Indicate by passing -1 instead of pin#
  if (_rw_pin != -1) { 
    pinMode(_rw_pin, OUTPUT);
  }
  pinMode(_enable_pin, OUTPUT);
  
  if (fourbitmode)
    _displayfunction = LCD_4BITMODE | LCD_1LINE | LCD_5x8DOTS;
  else 
    _displayfunction = LCD_8BITMODE | LCD_1LINE | LCD_5x8DOTS;
  
  begin(16, 1);  
}

#endif

void LiquidCrystalBase::begin(byte cols, byte lines, byte dotsize) {
  if (lines > 1) {
    _displayfunction |= LCD_2LINE;
  }
  _numlines = lines;
  _currline = 0;

  // for some 1 line displays you can select a 10 pixel high font
  if ((dotsize != 0) && (lines == 1)) {
    _displayfunction |= LCD_5x10DOTS;
  }

  // SEE PAGE 45/46 FOR INITIALIZATION SPECIFICATION!
  // according to datasheet, we need at least 40ms after power rises above 2.7V
  // before sending commands. Arduino can turn on way befer 4.5V so we'll wait 50
  delayMicroseconds(50000); // can't use delay, may get called before main!

  // Now we pull both RS and R/W low to begin commands
  config();
  
  //put the LCD into 4 bit or 8 bit mode
  if (! (_displayfunction & LCD_8BITMODE)) {
    // this is according to the hitachi HD44780 datasheet
    // figure 24, pg 46

    // we start in 8bit mode, try to set 4 bit mode
    write4bits(0x03);
    delayMicroseconds(4500); // wait min 4.1ms

    // second try
    write4bits(0x03);
    delayMicroseconds(4500); // wait min 4.1ms
    
    // third go!
    write4bits(0x03); 
    delayMicroseconds(150);

    // finally, set to 8-bit interface
    write4bits(0x02); 
  } else {
    // this is according to the hitachi HD44780 datasheet
    // page 45 figure 23

    // Send function set command sequence
    command(LCD_FUNCTIONSET | _displayfunction);
    delayMicroseconds(4500);  // wait more than 4.1ms

    // second try
    command(LCD_FUNCTIONSET | _displayfunction);
    delayMicroseconds(150);

    // third go
    command(LCD_FUNCTIONSET | _displayfunction);
  }

  // finally, set # lines, font size, etc.
  command(LCD_FUNCTIONSET | _displayfunction);  

  // turn the display on with no cursor or blinking default
  _displaycontrol = LCD_DISPLAYON | LCD_CURSOROFF | LCD_BLINKOFF;  
  display();

  // clear it off
  clear();

  // Initialize to default text direction (for romance languages)
  _displaymode = LCD_ENTRYLEFT | LCD_ENTRYSHIFTDECREMENT;
  // set the entry mode
  command(LCD_ENTRYMODESET | _displaymode);

}

/********** high level commands, for the user! */
void LiquidCrystalBase::clear()
{
  command(LCD_CLEARDISPLAY);  // clear display, set cursor position to zero
  delayMicroseconds(2000);  // this command takes a long time!
}

void LiquidCrystalBase::home()
{
  command(LCD_RETURNHOME);  // set cursor position to zero
  delayMicroseconds(2000);  // this command takes a long time!
}

void LiquidCrystalBase::setCursor(byte col, byte row)
{
  int row_offsets[] = { 0x00, 0x40, 0x14, 0x54 };
  if ( row > _numlines ) {
    row = _numlines-1;    // we count rows starting w/0
  }
  
  command(LCD_SETDDRAMADDR | (col + row_offsets[row]));
}

// Turn the display on/off (quickly)
void LiquidCrystalBase::noDisplay() {
  _displaycontrol &= ~LCD_DISPLAYON;
  command(LCD_DISPLAYCONTROL | _displaycontrol);
}
void LiquidCrystalBase::display() {
  _displaycontrol |= LCD_DISPLAYON;
  command(LCD_DISPLAYCONTROL | _displaycontrol);
}

// Turns the underline cursor on/off
void LiquidCrystalBase::noCursor() {
  _displaycontrol &= ~LCD_CURSORON;
  command(LCD_DISPLAYCONTROL | _displaycontrol);
}
void LiquidCrystalBase::cursor() {
  _displaycontrol |= LCD_CURSORON;
  command(LCD_DISPLAYCONTROL | _displaycontrol);
}

// Turn on and off the blinking cursor
void LiquidCrystalBase::noBlink() {
  _displaycontrol &= ~LCD_BLINKON;
  command(LCD_DISPLAYCONTROL | _displaycontrol);
}
void LiquidCrystalBase::blink() {
  _displaycontrol |= LCD_BLINKON;
  command(LCD_DISPLAYCONTROL | _displaycontrol);
}

// These commands scroll the display without changing the RAM
void LiquidCrystalBase::scrollDisplayLeft(void) {
  command(LCD_CURSORSHIFT | LCD_DISPLAYMOVE | LCD_MOVELEFT);
}
void LiquidCrystalBase::scrollDisplayRight(void) {
  command(LCD_CURSORSHIFT | LCD_DISPLAYMOVE | LCD_MOVERIGHT);
}

// This is for text that flows Left to Right
void LiquidCrystalBase::leftToRight(void) {
  _displaymode |= LCD_ENTRYLEFT;
  command(LCD_ENTRYMODESET | _displaymode);
}

// This is for text that flows Right to Left
void LiquidCrystalBase::rightToLeft(void) {
  _displaymode &= ~LCD_ENTRYLEFT;
  command(LCD_ENTRYMODESET | _displaymode);
}

// This will 'right justify' text from the cursor
void LiquidCrystalBase::autoscroll(void) {
  _displaymode |= LCD_ENTRYSHIFTINCREMENT;
  command(LCD_ENTRYMODESET | _displaymode);
}

// This will 'left justify' text from the cursor
void LiquidCrystalBase::noAutoscroll(void) {
  _displaymode &= ~LCD_ENTRYSHIFTINCREMENT;
  command(LCD_ENTRYMODESET | _displaymode);
}

// Allows us to fill the first 8 CGRAM locations
// with custom characters
void LiquidCrystalBase::createChar(byte location, byte charmap[]) {
  location &= 0x7; // we only have 8 locations 0-7
  command(LCD_SETCGRAMADDR | (location << 3));
  for (int i=0; i<8; i++) {
    write(charmap[i]);
  }
}

/*********** mid level commands, for sending data/cmds */

inline void LiquidCrystalBase::command(byte value) {
  send(value, LOW);
}

inline void LiquidCrystalBase::write(byte value) {
  send(value, HIGH);
}

class LiquidCrystal : public LiquidCrystalBase {
public:
  LiquidCrystal(byte rs, byte enable,
		byte d0, byte d1, byte d2, byte d3, byte d4, byte d5, byte d6, byte d7);
  LiquidCrystal(byte rs, byte rw, byte enable,
		byte d0, byte d1, byte d2, byte d3, byte d4, byte d5, byte d6, byte d7);
  LiquidCrystal(byte rs, byte rw, byte enable,
		byte d0, byte d1, byte d2, byte d3);
  LiquidCrystal(byte rs, byte enable,
		byte d0, byte d1, byte d2, byte d3);

  void init(byte fourbitmode, byte rs, byte rw, byte enable,
	    byte d0, byte d1, byte d2, byte d3, byte d4, byte d5, byte d6, byte d7);
  
  virtual void config();
  virtual void send(byte, byte);
  virtual void write4bits(byte);

  void write8bits(byte);
  void pulseEnable();

  byte _rs_pin; // LOW: command.  HIGH: character.
  byte _rw_pin; // LOW: write to LCD.  HIGH: read from LCD.
  byte _enable_pin; // activated by a HIGH pulse.
  byte _data_pins[8];
};

// When the display powers up, it is configured as follows:
//
// 1. Display clear
// 2. Function set: 
//    DL = 1; 8-bit interface data 
//    N = 0; 1-line display 
//    F = 0; 5x8 dot character font 
// 3. Display on/off control: 
//    D = 0; Display off 
//    C = 0; Cursor off 
//    B = 0; Blinking off 
// 4. Entry mode set: 
//    I/D = 1; Increment by 1 
//    S = 0; No shift 
//
// Note, however, that resetting the Arduino doesn't reset the LCD, so we
// can't assume that its in that state when a sketch starts (and the
// LiquidCrystal constructor is called).

LiquidCrystal::LiquidCrystal(byte rs, byte rw, byte enable,
	     byte d0, byte d1, byte d2, byte d3, byte d4, byte d5, byte d6, byte d7)
{
  init(0, rs, rw, enable, d0, d1, d2, d3, d4, d5, d6, d7);
}

LiquidCrystal::LiquidCrystal(byte rs, byte enable,
	     byte d0, byte d1, byte d2, byte d3, byte d4, byte d5, byte d6, byte d7)
{
  init(0, rs, -1, enable, d0, d1, d2, d3, d4, d5, d6, d7);
}

LiquidCrystal::LiquidCrystal(byte rs, byte rw, byte enable,
	     byte d0, byte d1, byte d2, byte d3)
{
  init(1, rs, rw, enable, d0, d1, d2, d3, 0, 0, 0, 0);
}

LiquidCrystal::LiquidCrystal(byte rs,  byte enable,
	     byte d0, byte d1, byte d2, byte d3)
{
  init(1, rs, -1, enable, d0, d1, d2, d3, 0, 0, 0, 0);
}

void LiquidCrystal::init(byte fourbitmode, byte rs, byte rw, byte enable,
			 byte d0, byte d1, byte d2, byte d3, byte d4, byte d5, byte d6, byte d7)
{
  _rs_pin = rs;
  _rw_pin = rw;
  _enable_pin = enable;
  
  _data_pins[0] = d0;
  _data_pins[1] = d1;
  _data_pins[2] = d2;
  _data_pins[3] = d3; 
  _data_pins[4] = d4;
  _data_pins[5] = d5;
  _data_pins[6] = d6;
  _data_pins[7] = d7; 

  pinMode(_rs_pin, OUTPUT);
  // we can save 1 pin by not using RW. Indicate by passing -1 instead of pin#
  if (_rw_pin != -1) { 
    pinMode(_rw_pin, OUTPUT);
  }
  pinMode(_enable_pin, OUTPUT);
  
  if (fourbitmode)
    _displayfunction = LCD_4BITMODE | LCD_1LINE | LCD_5x8DOTS;
  else 
    _displayfunction = LCD_8BITMODE | LCD_1LINE | LCD_5x8DOTS;
  
  begin(16, 1);  
}

/************ low level data pushing commands **********/

void LiquidCrystal::config() {
  // SEE PAGE 45/46 FOR INITIALIZATION SPECIFICATION!
  // according to datasheet, we need at least 40ms after power rises above 2.7V
  // before sending commands. Arduino can turn on way befer 4.5V so we'll wait 50
  delayMicroseconds(50000); 
  // Now we pull both RS and R/W low to begin commands
  digitalWrite(_rs_pin, LOW);
  digitalWrite(_enable_pin, LOW);
  if (_rw_pin != -1) { 
    digitalWrite(_rw_pin, LOW);
  }
}

// write either command or data, with automatic 4/8-bit selection
void LiquidCrystal::send(byte value, byte mode) {
  digitalWrite(_rs_pin, mode);

  // if there is a RW pin indicated, set it low to Write
  if (_rw_pin != -1) { 
    digitalWrite(_rw_pin, LOW);
  }
  
  if (_displayfunction & LCD_8BITMODE) {
    write8bits(value); 
  } else {
    write4bits(value>>4);
    write4bits(value);
  }
}

void LiquidCrystal::pulseEnable(void) {
  digitalWrite(_enable_pin, LOW);
  delayMicroseconds(1);    
  digitalWrite(_enable_pin, HIGH);
  delayMicroseconds(1);    // enable pulse must be >450ns
  digitalWrite(_enable_pin, LOW);
  delayMicroseconds(100);   // commands need > 37us to settle
}

void LiquidCrystal::write4bits(byte value) {
  for (int i = 0; i < 4; i++) {
    pinMode(_data_pins[i], OUTPUT);
    digitalWrite(_data_pins[i], (value >> i) & 0x01);
  }

  pulseEnable();
}

void LiquidCrystal::write8bits(byte value) {
  for (int i = 0; i < 8; i++) {
    pinMode(_data_pins[i], OUTPUT);
    digitalWrite(_data_pins[i], (value >> i) & 0x01);
  }
  
  pulseEnable();
}

// end of LC.cpp

#include <Ports.h>
#include <RF12.h> // needed to avoid a linker error :(

class LiquidCrystalI2C : public LiquidCrystalBase {
  DeviceI2C device;
  byte offset;
public:
  LiquidCrystalI2C (const PortI2C& p, byte addr =0x20, byte bank =0);
protected:
  virtual void config();
  virtual void send(byte, byte);
  virtual void write4bits(byte);
};

LiquidCrystalI2C::LiquidCrystalI2C (const PortI2C& p, byte addr, byte bank)
    : device (p, addr), offset (bank << 4) {
  _displayfunction = LCD_4BITMODE | LCD_1LINE | LCD_5x8DOTS;
  begin(16, 2);  
}

/************ low level data pushing commands **********/

enum {
  MCP_IODIR, MCP_IPOL, MCP_GPINTEN, MCP_DEFVAL, MCP_INTCON, MCP_IOCON,
  MCP_GPPU, MCP_INTF, MCP_INTCAP, MCP_GPIO, MCP_OLAT, MCP_IOCONX
};

// bits 0..3 and D4..D7, the rest is connected as follows
#define MCP_BACKLIGHT   0x80
#define MCP_ENABLE      0x40
#define MCP_RDWR        0x20
#define MCP_REGSEL      0x10

void LiquidCrystalI2C::config() {
  // make sure the registers are in banked mode, must be written to reg 0x0B!
  device.send();
  device.write(MCP_IOCONX);
  device.write(0xC4); // IOCON: BANK = 1, MIRROR = 1, ODR = 1, rest zero
  device.stop();

  // now write IOCON again, in case the chip was already in banked mode
  device.send();
  device.write(MCP_IOCON);
  device.write(0xC4); // IOCON: BANK = 1, MIRROR = 1, ODR = 1, rest zero
  device.stop();

  // set all outputs, the remaining power-up default register values are all 0
  device.send();
  device.write(MCP_IODIR);
  device.write(0); // IODIR: all outputs
  device.stop();
}

// write either command or data, with automatic 4/8-bit selection
void LiquidCrystalI2C::send(byte value, byte mode) {
  if (mode != 0)
    mode = MCP_REGSEL;
  write4bits((value >> 4) | mode);
  write4bits((value & 0x0F) | mode);
}

void LiquidCrystalI2C::write4bits(byte value) {
  device.send();
  device.write(MCP_GPIO + offset);
  device.write(value | MCP_ENABLE);
  device.write(value);
  device.write(value | MCP_ENABLE);
  device.stop();
}

PortI2C myI2C (1);
LiquidCrystalI2C lcd (myI2C);

void setup() {
  // set up the LCD's number of rows and columns: 
  lcd.begin(16, 2);
  // Print a message to the LCD.
  lcd.print("Hello, world!");
}

void loop() {
  // set the cursor to column 0, line 1
  // (note: line 1 is the second row, since counting begins with 0):
  lcd.setCursor(0, 1);
  // print the number of seconds since reset:
  lcd.print(millis()/1000);
}

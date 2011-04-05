// Demo for using the Blink Plug on an Arduino
// 2009-09-17 <jcw@equi4.com> http://opensource.org/licenses/mit-license.php
// $Id: arblink.pde 6001 2010-09-09 22:49:39Z jcw $

// This demo expects the BP to be plugged into Arduino digital pins 8..13 and
// can be configued with the LEDs and buttons facing either OUTWARDS or INWARDS.
// Note that pins 8 and 13 are covered but not actually connected to anything.

#define INWARDS 1

#if INWARDS
#define AIO 9
#define VCC 10
#define GND 11
#define DIO 12
#else
#define AIO 12
#define VCC 11
#define GND 10
#define DIO 9
#endif

static word ledState;

static void setLED (byte pin, byte on) {
    if (on) { // led on = output mode, pulled low
        digitalWrite(pin, 0); pinMode(pin, OUTPUT);
    } else { // led off = input mode, with pull-up resistor
        pinMode(pin, INPUT); digitalWrite(pin, 1);
    }
    // never make the pin a high output, because the button will short it out
}

static byte getButton (byte pin) {
    setLED(pin, 0);
    byte pushed = digitalRead(pin) == 0;
    setLED(pin, bitRead(ledState, pin)); // restore
    return pushed;
}

static void redLED (byte on)   { setLED(DIO, on); bitWrite(ledState, DIO, on); }
static void greenLED (byte on) { setLED(AIO, on); bitWrite(ledState, AIO, on); }

static byte upperButton () { return getButton(DIO); }
static byte lowerButton () { return getButton(AIO); }

void setup () {
    Serial.begin(57600);
    Serial.println("\n[arBlink]");
    
    pinMode(GND, OUTPUT); digitalWrite(GND, 0);
    pinMode(VCC, OUTPUT); digitalWrite(VCC, 1);
    pinMode(DIO, OUTPUT); redLED(0);
    pinMode(AIO, OUTPUT); greenLED(0);
}

void loop () {
    if (upperButton()) // quickly blink the green led 7 times
        for (byte i = 0; i < 7; ++i) {
            delay(100); greenLED(1); delay(100); greenLED(0);
        }
    if (lowerButton()) // slowly blinkl the red led 3 times
        for (byte i = 0; i < 3; ++i) {
            delay(250); redLED(1); delay(250); redLED(0);
        }
    delay(10);
}

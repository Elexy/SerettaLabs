// Examine the pulse patterns coming from an OOK receiver (see also peekrf.pde)
// 2010-04-10 <jcw@equi4.com> http://opensource.org/licenses/mit-license.php
// $Id$
// see http://news.jeelabs.org/2010/04/13/an-ook-scope/

#define PORT 2

volatile uint8_t pull, fill, buf[256];
static uint16_t last;

ISR(ANALOG_COMP_vect) {
    // width is the pulse length in usecs, for either polarity
    uint16_t width = (micros() >> 2) - last;
    last += width;

    if (width <= 5)
        return; // ignore pulses <= 20 µs
        
    if (width >= 128) {
        width = (width >> 1) + 64;
        if (width >= 192) {
            width = (width >> 1) + 96;
            if (width >= 224) {
                width = (width >> 1) + 112;
                if (width >= 240) {
                    width = (width >> 1) + 120;
                    if (width >= 248) {
                        width = (width >> 1) + 124;
                        if (width >= 252) {
                            width = (width >> 1) + 126;
                            if (width > 255)
                                width = 255;
                        }
                    }
                }
            }
        }
    }

    buf[fill++] = width;
}

void setup() {
    Serial.begin(57600);
    Serial.println("\n[ookScope]");
    
    pinMode(13 + PORT, INPUT);  // use the AIO pin
    digitalWrite(13 + PORT, 1); // enable pull-up

    // use analog comparator to switch at 1.1V bandgap transition
    ACSR = _BV(ACBG) | _BV(ACI) | _BV(ACIE);

    // set ADC mux to the proper port
    ADCSRA &= ~ bit(ADEN);
    ADCSRB |= bit(ACME);
    ADMUX = PORT - 1;
}

void loop() {
    if (pull != fill) {
        cli();
        byte b = buf[pull++];
        sei();
        Serial.print(b);
    }
}

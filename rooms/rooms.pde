#include <PortsLCD.h>
#include <Ports.h>
#include <RF12.h>
#include <avr/sleep.h>
#include <OneWire.h>

OneWire ds18b20 (7); // 1-wire temperature sensors, uses DIO port 4

uint8_t oneID[8];
int temp;

PortI2C myI2C (3);
LiquidCrystalI2C lcd (myI2C);

static uint8_t initOneWire () {
    if (ds18b20.search(oneID)) {
        Serial.print(" 1-wire");
        for (uint8_t i = 0; i < 8; ++i) {
            Serial.print(' ');
            Serial.print(oneID[i], HEX);
        }
        Serial.println();
    }
    ds18b20.reset();
}

static void lowPower (byte mode) {
    // prepare to go into power down mode
    set_sleep_mode(mode);
    // disable the ADC
    byte prrSave = PRR, adcsraSave = ADCSRA;
    ADCSRA &= ~ bit(ADEN);
    PRR |= bit(PRADC);
    // zzzzz...
    sleep_mode();
    // re-enable the ADC
    PRR = prrSave;
    ADCSRA = adcsraSave;
}

EMPTY_INTERRUPT(WDT_vect); // just wakes us up to resume

static void watchdogInterrupts (uint8_t mode) {
    MCUSR &= ~(1<<WDRF); // only generate interrupts, no reset
    cli();
    WDTCSR |= (1<<WDCE) | (1<<WDE); // start timed sequence
    WDTCSR = bit(WDIE) | mode; // mode is a slightly quirky bit-pattern
    sei();
}

static byte loseSomeTime (word msecs) {
    // only slow down for periods longer than twice the watchdog granularity
    if (msecs >= 32) {
        for (word ticks = msecs / 16; ticks > 0; --ticks) {
            lowPower(SLEEP_MODE_PWR_DOWN); // now completely power down
            // adjust the milli ticks, since we will have missed several
            extern volatile unsigned long timer0_millis;
            timer0_millis += 16;
        }
        return 1;
    }
    return 0;
}

static MilliTimer sleepTimer;   // poll the sensor once every so often
static MilliTimer aliveTimer;   // without change, force sending every 60 s
static byte radioIsOn = 1;      // track whether the RFM12B is on

static byte periodicSleep (word msecs) {
    // switch to idle mode while waiting for the next event
    lowPower(SLEEP_MODE_IDLE);
    // keep the easy tranmission mechanism going
    if (radioIsOn && rf12_easyPoll() == 0) {
        rf12_sleep(0); // turn the radio off
        radioIsOn = 0;
    }
    // if we will wait for quite some time, go into total power down mode
    if (!radioIsOn) {
        // see http://news.jeelabs.org/2009/12/18/battery-life-estimation/
        if (loseSomeTime(sleepTimer.remaining()))
            sleepTimer.set(1); // really did a power down, trigger right now
    }
    // return true if the time has come to do something meaningful
    return sleepTimer.poll(msecs);
}

static void wakeupToSend (const void* ptr, byte len) {
    char sending = rf12_easySend(ptr, len);
    if (sending) // clear timer if we are about to send a packet anyway
        aliveTimer.set(0);
    // otherwise force a "sign of life" packet out every 60 seconds
    if (aliveTimer.poll(60000))
        sending = rf12_easySend(0, 0); // always returns 1
    if (sending) {
        // make sure the radio is on again
        if (!radioIsOn)
            rf12_sleep(-1); // turn the radio back on
        radioIsOn = 1;
    }
}


static int readout1wire () {
    ds18b20.reset();
    ds18b20.skip();
    ds18b20.write(0x4E); // write to scratchpad
    ds18b20.write(0);
    ds18b20.write(0);
    ds18b20.write(0x1F); // 9-bits is enough, measurement takes 94 msec
    ds18b20.reset();
    ds18b20.skip();
    ds18b20.write(0x44, 1); // start conversion, parasite pull up on the end
    delay(750); // wait until conversion is done
    ds18b20.reset();
    // ds18b20.select(oneID);
    ds18b20.skip();
    ds18b20.write(0xBE); // read scratchpad
    uint8_t data[9];
    for (uint8_t j = 0; j < 9; ++j)
        data[j] = ds18b20.read();
    ds18b20.reset();
    if (OneWire::crc8(data, 8) != data[8]) {
        Serial.println(" crc? ");
        return 0;
    }
    return ((data[1] << 8) + data[0]) * 10 >> 4; // degrees * 10
}

// this code is called once per second, but not all calls will be reported
static void newReadings() {
    temp = readout1wire();
}

unsigned int time;

void setup() {  
    Serial.begin(57600);
    Serial.print("\n[temp]");
    // initialize wireless node for 868 Mhz, group 5, node 9
    rf12_initialize(9, RF12_868MHZ, 5);
//    rf12_config();
    rf12_easyInit(5); // throttle packet sending to at least 5 seconds apart

    initOneWire();
}

void loop() {  
//    if (periodicSleep(1000)) {
        newReadings();        
        Serial.print("ROOM ");
        Serial.print('9');
        Serial.print(' ');
        Serial.print((int) temp);
        Serial.println();
        delay(500); // make sure tx buf is empty before going back to sleep

        wakeupToSend(&temp, sizeof temp);
//    }
}

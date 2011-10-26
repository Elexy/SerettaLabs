// Hooking up a DS1307 (5V) or DS1340Z (3V) real time clock via I2C.
// see http://jeelabs.org/cp1
// 2009-09-17 <jcw@equi4.com> http://opensource.org/licenses/mit-license.php
// $Id: rtc_demo.pde 5302 2010-04-12 07:52:28Z jcw $

// the real-time clock is connected to port 1 in I2C mode (AIO = SCK, dIO = SDA)

#include <Ports.h>
#include <RF12.h> // needed to avoid a linker error :(

PortI2C myport (2 /*, PortI2C::KHZ400 */);
DeviceI2C rtc (myport, 0x68);

static byte bin2bcd (byte val) {
    return val + 6 * (val / 10);
}

static byte bcd2bin (byte val) {
    return val - 6 * (val >> 4);
}

static void setDate (byte yy, byte mm, byte dd, byte h, byte m, byte s) {
    rtc.send();
    rtc.write(0);
    rtc.write(bin2bcd(s));
    rtc.write(bin2bcd(m));
    rtc.write(bin2bcd(h));
    rtc.write(bin2bcd(0));
    rtc.write(bin2bcd(dd));
    rtc.write(bin2bcd(mm));
    rtc.write(bin2bcd(yy));
    rtc.write(0);
    rtc.stop();
}

static void getDate (byte* buf) {
	rtc.send();
	rtc.write(0);	
    rtc.stop();

	rtc.receive();
    buf[5] = bcd2bin(rtc.read(0));
    buf[4] = bcd2bin(rtc.read(0));
    buf[3] = bcd2bin(rtc.read(0));
    rtc.read(0);
    buf[2] = bcd2bin(rtc.read(0));
    buf[1] = bcd2bin(rtc.read(0));
    buf[0] = bcd2bin(rtc.read(1));
    rtc.stop();
}

void setup() {
    Serial.begin(57600);
    Serial.println("\n[rtc_demo]");

    // test code:
    setDate(11, 9, 1, 18, 22, 0);
}

void loop() {    
    byte now[6];
    getDate(now);
    
    Serial.print("rtc");
    for (byte i = 0; i < 6; ++i) {
        Serial.print(' ');
        Serial.print((int) now[i]);
    }
    Serial.println();
        
	delay(1000);
}

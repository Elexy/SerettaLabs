// Hooking up a DS1307 (5V) or DS1340Z (3V) real time clock via I2C.
// see http://jeelabs.org/cp1
// 2009-09-17 <jcw@equi4.com> http://opensource.org/licenses/mit-license.php
// $Id: rtc_demo.pde 5302 2010-04-12 07:52:28Z jcw $

// the real-time clock is connected to port 1 in I2C mode (AIO = SCK, dIO = SDA)

#include <Ports.h>
#include <RF12.h> // needed to avoid a linker error :(
#include <payload.h> // contains all the message structs

PortI2C myport (2 /*, PortI2C::KHZ400 */);
DeviceI2C rtc (myport, 0x68);

Port valve  (1); // water valve
Port sensor (4); // moisture sensor
Port override (3); //jumper for testing


//timeSignal now;

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

    valve.mode(OUTPUT); //use DIO port 1
    valve.digiWrite(false); // initialize to OFF
    
    sensor.mode(INPUT); //use AIO port 4

    override.mode(INPUT); //use DIO port 3        
    // test code:
//    setDate(11, 8, 29, 14, 27, 20);
    rf12_config();
    rf12_easyInit(5); // throttle packet sending to at least 5 seconds apart
}

void loop() {    
    byte now[8];
    getDate(now);
    
    Serial.print("rtc");
    for (byte i = 0; i < 8; ++i) {
        Serial.print(' ');
        Serial.print((int) now[i]);
        
    }
    Serial.println();
    
    boolean moist = sensor.anaRead() > 400 && sensor.anaRead() < 615 ? true : false;
    boolean moistCheck = false;
    // open water valve between 20:00 and 20:10
    if(now[3] == 20 && now[4] >= 25 && now[4] < 36)  {
      if (!moist && !moistCheck)
      {
        valve.digiWrite(true);
        moistCheck = true;
        Serial.print("open");
        now[8] = 1;
      } else {
        valve.digiWrite(false);
        Serial.print("closed");
        now[8] = 0;
      }
    } else {
      moistCheck = false;
      valve.digiWrite(false);
    }
    Serial.print("moisture: ");
    
    Serial.print(moist ? "yes" : "no");
    Serial.print(sensor.anaRead());
    
    now[7] = sensor.anaRead();

    while (!rf12_canSend())
      rf12_recvDone();    
    rf12_sendStart(1, &now, sizeof now);
    rf12_sendWait(2);
        
    Serial.println();
        
	delay(5000);
}

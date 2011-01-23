// This "rooms" code is for room sensing, i.e. temp/humid/light/motion.
// 2009-03-18 <jcw@equi4.com> http://opensource.org/licenses/mit-license.php
// $Id: rooms.pde 6100 2010-10-27 13:40:12Z jcw $

// Needs a plug on ports 1 and 4 wired to an SHT11, an LDR, and a PIR sensor.
// The PIR sensor can be either a simple digital I/O pin sensor or a ZDOT SBC.
// Wireless node configuration is obtained from EEPROM, as set by "RF12demo".
// Ports 2 and 3 are unused and could perhaps be used for proximity switches.
// This code was derived from the older "pulse" project and is a bit simpler.

// The orientation of the room board can be a bit confusing:
//
// If EPIR is used, then it connects to port 4 and the LDR uses the EPIR.
// In that case, the SHT11 or DS18B20 connects to port 1.
// The orientation is with the "JeeLabs.org/rb1" text towards the radio.
//
// If EPIR is not used, the the boards is rotated so the PIR is in the middle.
// In that case PIR is on 1, LDR is on 1, and SHT11 or DS18B20 is on port 4.
// The orientation is with the "JeeLabs.org/rb1" text away from the radio.
//
// Feel free to adjust to other configurations or ports, as needed.

#include <Ports.h>
#include <RF12.h>
#include <avr/sleep.h>
#include <payload.h>
#include <PortsSHT11.h>

SHT11 sht11 (4);

Port pir_ldr (1);

uint8_t oneID[8];

static byte getMotion() {
    return pir_ldr.digiRead();
}

static byte getLight() {
    static byte avgLight;
    pir_ldr.digiWrite2(1);  // pull-up AIO
    byte light = pir_ldr.anaRead() >> 2;
    pir_ldr.digiWrite2(0);  // pull-down to reduce power draw in bright light
    // keep track of a running average for light levels
    avgLight = (4 * avgLight + light) / 5;
    return avgLight;
}

static MilliTimer reportTimer;  // don't report too often, unless moved
static byte prevMotion;         // track motion detector state
MilliTimer sendTimerPanel; // to time sending msgs 
roomBoard roomData;
heatingData heating;

static void shtDelay () {
    delay(32);
}

// this code is called once per second, but not all calls will be reported
static void newReadings() {
    byte motion = getMotion();  // always read out, to detect changes quickly
    byte light = getLight();    // always read out, to keep running avg going

    roomData.moved = motion != prevMotion;    
    prevMotion = motion;

    if (reportTimer.poll(30000) || roomData.moved) {
        roomData.light = light;
        float humi, temp;
        sht11.measure(SHT11::HUMI, shtDelay);        
        sht11.measure(SHT11::TEMP, shtDelay);
        sht11.calculate(humi, temp);
        // only accept values if the sensor is present
        if (humi > 1) {
            roomData.humi = humi + 0.5;
            roomData.temp = 10 * temp + 0.5;
        }
//        roomData.lobat = rf12_lowbat();
    }
}

/**
 * Function receive data
 */
void receive () {
  if (rf12_recvDone() && rf12_crc == 0 )
    if((RF12_HDR_MASK & rf12_hdr) == 1) {
      setTemp* buf =  (setTemp*) rf12_data;
  
      roomData.dTemp = (int) buf->temp;
      
      Serial.print("received packet: ");      
      Serial.println(roomData.dTemp);
    } 
}


void setup() {
    Serial.begin(57600);
    Serial.print("\n[LivingRoom]");
    rf12_config();
    rf12_easyInit(1); // throttle packet sending to at least 1 seconds apart

    pir_ldr.mode(INPUT);
    pir_ldr.digiWrite(1);   // pull-up DIO
    pir_ldr.mode2(INPUT);
    pir_ldr.digiWrite2(1);  // pull-up AIO

    roomData.dTemp = 199;
}

boolean heater = false;

void loop() {
    receive();    
    
    if (sendTimerPanel.poll(5000)) {
        newReadings();        
        
        Serial.print("Living ");
        Serial.print((int) roomData.light);
        Serial.print(' ');
        Serial.print((int) roomData.moved);
        Serial.print(' ');
        Serial.print((int) roomData.humi);
        Serial.print(' ');
        Serial.print((int) roomData.temp);
        Serial.print(' ');
        Serial.print((int) roomData.dTemp);
        
        if (roomData.temp >= roomData.dTemp + 1) heater = false;
        
        while (!rf12_canSend())
          rf12_recvDone();
        rf12_sendStart(0, &roomData, sizeof roomData);            
//        rf12_sendWait(2);
        if (roomData.temp < roomData.dTemp - 1 || heater ) {
          heating.heat = 1;
          heating.fpwm = 100;
          roomData.heat = 1;          
          while (!rf12_canSend())
            rf12_recvDone();
          rf12_sendStart(RF12_HDR_ACK | RF12_HDR_DST | 30, &heating, sizeof heating);
          rf12_sendWait(2);
          heater = true;
        } else {
          roomData.heat = 1;
        }
        Serial.print(" ");
        Serial.println(heating.heat ? '1' : '0');
    }
}

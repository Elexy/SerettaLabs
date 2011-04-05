// Remote LCD node, gets its data from a central JeeNode
// 2010-04-05 <jcw@equi4.com> http://opensource.org/licenses/mit-license.php
// see http://news.jeelabs.org/2010/04/08/turning-the-protocol-around/
// $Id: remoteLCD2.pde 6001 2010-09-09 22:49:39Z jcw $

#include <PortsLCD.h>
#include <RF12.h>

PortI2C myBus (1);
LiquidCrystalI2C lcd (myBus);
MilliTimer timer;

void setup () {
    Serial.begin(57600);
    Serial.println("\n[remoteLCD2]");
    // intialize wireless node for 868 MHz, group 4, node 9
    rf12_initialize(9, RF12_868MHZ, 4);
    rf12_easyInit(0);
    // show a startup message on the LCD
    lcd.begin(16, 2);
    lcd.print("[remoteLCD]");
}

void loop () {
    if (timer.poll(5000))
        rf12_easySend(0, 0); // force packet send, no data
    
    // poll continuously to pick up the ack data
    if (rf12_easyPoll() > 0) {
        // clear screen, return to home, display received string
        lcd.clear();
        for (byte i = 0; i < rf12_len; ++i)
            if (rf12_data[i] == '\n')
                lcd.setCursor(0,1);
            else
                lcd.print(rf12_data[i]);
    }
}

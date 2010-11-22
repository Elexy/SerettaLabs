// Remote LCD node, gets its data from a central JeeNode
// 2010-04-05 <jcw@equi4.com> http://opensource.org/licenses/mit-license.php
// see http://news.jeelabs.org/2010/04/06/demo-remote-lcd/
// $Id: remoteLCD1.pde 5286 2010-04-07 18:44:51Z jcw $

    #include <PortsLCD.h>
    #include <RF12.h>
    
    PortI2C myBus (3);
    LiquidCrystalI2C lcd (myBus);
    
    char character;
    
    void setup () {
        Serial.begin(57600);
        Serial.println("\n[remoteLCD]");
        // intialize wireless node for 868 MHz, group 4, node 20
        rf12_initialize(20, RF12_868MHZ, 5);
        // show a startup message on the LCD
        lcd.begin(16, 2);
        lcd.print("[remoteLCD]");
    }
    
    void loop () {
        if (rf12_recvDone() && rf12_crc == 0) {
            // clear screen, return to home position, and display received string
            lcd.clear();
                byte hdr = rf12_hdr;
                byte a   = rf12_data[0];
                byte b   = rf12_data[1];
                byte c   = rf12_data[2];
                byte d   = rf12_data[3];
            
                int device_id   = hdr & 0x1F;
                lcd.print((int) device_id);
                lcd.print(' ');
                int light       = a ;
                lcd.print((int) light);
                lcd.print(' ');
                int motion      = b & 1;
                lcd.print((int) motion );
                lcd.print(' ');
                int humidity    = b >> 1;
                lcd.print((int) humidity);
                lcd.setCursor(0,1);
                lcd.print("temp:");
                int temperature = (((256 * (d&3) + c) ^ 512) - 512);
                lcd.print((int) temperature/10);
                lcd.print('.');
                lcd.print((int) temperature%10);
                lcd.print(' ');          
                int battery     = (d >> 2) & 1;
                lcd.print((int) battery);
                lcd.print(' ');                   
            
    //        Serial.println(" ok");
        }
    }

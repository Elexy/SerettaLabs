// Show incoming Room Node messages on the Graphics Board
// 2010-11-15 <jcw@equi4.com> http://opensource.org/licenses/mit-license.php
// $Id: glcdNode.pde 6197 2010-11-16 12:13:41Z jcw $

// Note, this sketch requires the ST7565 library by Limor Fried, see:
//      https://github.com/adafruit/ST7565-LCD
// With one change to the source code, as described in this weblog post:
//      http://jeelabs.org/2010/11/17/room-node-display/

#include "ST7565.h"
#include <Ports.h>
#include <RF12.h>

class GraphicsBoard : public ST7565, public Print {
    byte x, y, dirty;
    MilliTimer refreshTimer;
    
    void newline() {
        extern byte gLCDbuf[];
        byte *p = gLCDbuf;
        x = 0;
        if (++y >= 8) {
            --y;
            memcpy(gLCDbuf, gLCDbuf + 128, 1024 - 128);
            memset(gLCDbuf + 1024 - 128, 0, 128);
        }
    }
    
public:
    GraphicsBoard ()
        : ST7565 (14, 4, 17, 7), x (0), y (0), dirty (0) {}
    
    void begin() {
        st7565_init();
        st7565_command(CMD_DISPLAY_ON);
        st7565_command(CMD_SET_ALLPTS_NORMAL);
        st7565_set_brightness(0x15);
        clear();
        display();
    }
    
    void poll(byte rate =100) {
        if (refreshTimer.poll(rate) && dirty) {
            display();
            dirty = 0;
        }
    }
    
    virtual void write(byte c) {
        dirty = 1;
        if (c == '\r') {
            x = 0;
            return;
        }
        if (c == '\n') {
            x = 127;
            return;
        }
        if (x >= 126)
            newline();
        drawchar(x, y, c);
        x += 6;
    }
};

GraphicsBoard glcd;
byte index;
char line[25];

struct {
    byte light;     // light sensor: 0..255
    byte moved :1;  // motion detector: 0..1
    byte humi  :7;  // humidity: 0..100
    int temp   :10; // temperature: -500..+500 (tenths)
    byte lobat :1;  // supply voltage dropped under 3.1V: 0..1
} payload;

void setup () {
    Serial.begin(57600);
    Serial.println("\n[glcdNode]");
    rf12_initialize(1, RF12_868MHZ, 5);
    glcd.begin();
    glcd.println(" <<< glcdNode.pde >>>");
}

void loop () {
    glcd.poll();
    
    // assume all 4-byte packets come from Room Nodes ...
    if (rf12_recvDone() && rf12_crc == 0) {
        if (++index > 99)
            index = 0;
        if (rf12_len == sizeof payload) {
            memcpy(&payload, (void*) rf12_data, sizeof payload);
            sprintf(line, "%02d%c%2d%c%3d.%dC%3d%%%4d*", 
                            index, payload.lobat ? '!' : ' ',
                            rf12_hdr & 0x1F, payload.moved ? ':' : '#',
                            payload.temp / 10, payload.temp % 10,
                            payload.humi, payload.light);
            
            Serial.println(line);
            glcd.println(line);
        }
    }
}

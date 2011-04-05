// Grpahics library for 128x64 display based on ST7565 (JeeLabs Graphics Board)
// $Id$
//
// Originally derived from code by cstone@pobox.com and Limor Fried / Adafruit.
// Massive changes by Steve Evans and Jean-Claude Wippler, Dec 2010 to Jan 2011.
// Licensed as LGPL.

#include <avr/pgmspace.h>
#include <WProgram.h>
#include <util/delay.h>
#include <stdlib.h>
#include "GLCD_ST7565.h"
#include "GLCD_ST7565_cmds.h"

#define PIN_SID  14
#define PIN_SCLK 4
#define PIN_A0   17
#define PIN_RST  7

#define LCDUNUSEDSTARTBYTES 4

#define swap(a, b) { byte t = a; a = b; b = t; }

// a 5x7 font table
extern byte PROGMEM font5x7[];

// the memory buffer for the LCD
static byte gLCDBuf[1024];

// Switch from fast direct bit flipping to slower Arduino bit writes.
//#define slowSPI

// This makes the library track where changes have occurred and only update the smallest rectangle required
// If you are writing direct to the gLCDBuf you will either need to turn this off, or call setUpdateArea() with the
// area you have been working on so it can track the changes.
#define enablePartialUpdate

// moves some of the enablePartialUpdate logic further up the procedure tree. Removing it from setPixel and putting
// it into the higher level routines such as draw/fill rect/circle/triangle. Makes the sketch larger, but faster in
// graphical intensive applications.
#define tradeSizeForSpeed  // This needs enablePartialUpdate


#ifdef enablePartialUpdate
static byte xUpdateMin;
static byte xUpdateMax;
static byte yUpdateMin;
static byte yUpdateMax;
#endif

// If the top line is appearing halfway down the screen, try the other mode.
#define PAGE_FLIP 0x7
// #define PAGE_FLIP 0x3

static void SPIWrite(byte c) {
#ifdef slowSPI
    shiftOut(PIN_SID, PIN_SCLK, MSBFIRST, c);
#else
    for (byte mask = 0x80; mask != 0; mask >>= 1) {
        bitWrite(PORTC, 0, c & mask);
        // this is 15% faster, but it's too fast for this chip...
        //PIND = bit(4);
        //PIND = bit(4);
        // even plain set/clear is too fast, so slow down a bit more
        bitSet(PORTD, 4);
        bitSet(PORTD, 4);
        bitClear(PORTD, 4);
        bitClear(PORTD, 4);
    }
#endif
}

static void st7565_Command(byte c) {
#ifdef slowSPI
    digitalWrite(PIN_A0, LOW);
#else
    bitClear(PORTC, 3);
#endif
    SPIWrite(c);
}

static void st7565_Data(byte c) {
#ifdef slowSPI
    digitalWrite(PIN_A0, HIGH);
#else
    bitSet(PORTC, 3);
#endif
    SPIWrite(c);
}

static void st7565_Set_Brightness(byte val) {
    st7565_Command(CMD_SET_VOLUME_FIRST);
    st7565_Command(CMD_SET_VOLUME_SECOND | (val & 0x3F));
}

static void setPage(byte p) {
    st7565_Command(CMD_SET_PAGE | (p ^ PAGE_FLIP));
}

static void st7565_Init() {
    // set pin directions
    pinMode(PIN_SID,  OUTPUT);
    pinMode(PIN_SCLK, OUTPUT);
    pinMode(PIN_A0,   OUTPUT);
    pinMode(PIN_RST,  OUTPUT);

    digitalWrite(PIN_RST, LOW);
    _delay_ms(500);
    digitalWrite(PIN_RST, HIGH);

    st7565_Command(CMD_SET_BIAS_7);
    st7565_Command(CMD_SET_ADC_NORMAL);
    st7565_Command(CMD_SET_COM_NORMAL);
    st7565_Command(CMD_SET_DISP_START_LINE);
    st7565_Command(CMD_SET_POWER_CONTROL);
    st7565_Command(CMD_SET_RESISTOR_RATIO);
    // st7565_Command(CMD_SET_BIAS_9);

#ifdef enablePartialUpdate
    xUpdateMax = 0;
    yUpdateMax = 0;
    xUpdateMin = LCDWIDTH-1;
    yUpdateMin = LCDHEIGHT-1;
#endif
}

void GLCD_ST7565::begin() {
    st7565_Init();
    st7565_Command(CMD_DISPLAY_ON);
    st7565_Command(CMD_SET_ALLPTS_NORMAL);
    st7565_Set_Brightness(0x15); // strictly speaking this is the contrast of the LCD panel, the twist on the crystals.
    clear();
}

void GLCD_ST7565::backLight(byte level) {
    analogWrite(3, level);
}

// the most basic function, set a single pixel
void GLCD_ST7565::setPixel(byte x, byte y, byte color) {
    if (x >= LCDWIDTH || y >= LCDHEIGHT)
        return;

    // x is which column
    if (color) 
        gLCDBuf[x + (y/8)*128] |=  _BV(7-(y%8));  
    else
        gLCDBuf[x + (y/8)*128] &= ~_BV(7-(y%8));

#ifdef enablePartialUpdate
    if (x<xUpdateMin) xUpdateMin=x;
    if (x>xUpdateMax) xUpdateMax=x;
    if (y<yUpdateMin) yUpdateMin=y;
    if (y>yUpdateMax) yUpdateMax=y;
#endif
}

static void mySetPixel(byte x, byte y, byte color) {
#ifdef tradeSizeForSpeed
    if (x >= LCDWIDTH || y >= LCDHEIGHT)
        return;

    // x is which column
    if (color) 
        gLCDBuf[x+ (y/8)*128] |=  _BV(7-(y%8));  
    else
        gLCDBuf[x+ (y/8)*128] &= ~_BV(7-(y%8));
#else
    GLCD_ST7565::setPixel(x, y, color);
#endif
}

void GLCD_ST7565::drawBitmap(byte x, byte y, 
                        const byte *bitmap, byte w, byte h, byte color) {
    for (byte j=0; j<h; j++) {
        for (byte i=0; i<w; i++ ) {
            if (pgm_read_byte(bitmap + i + (j/8)*w) & _BV(j%8))
                setPixel(x+i, y+j, color);
        }
    }
}

void  GLCD_ST7565::drawChar(byte x, byte y, char c) {
    if (y <= LCDHEIGHT - 8) {          
#ifdef enablePartialUpdate
        if (x < xUpdateMin) xUpdateMin = x;
        if (y < yUpdateMin) yUpdateMin = y;
        if (y+6 > yUpdateMax) yUpdateMax = y+6;
        if (x+4 > xUpdateMax) xUpdateMax = x+4;
#endif
        byte* p = gLCDBuf + x + ((y>>3) * 128);
        y &= 7;
        byte topmask = 0xFF<<(8-y);
        byte bottommask = 0xFF>>y;
        for (byte i = 0; i < 5; ++i) {
            byte f = pgm_read_byte(font5x7+(c*5)+i);
            *p &= topmask;
            *p |= f >> y;
            *(p+128) &= bottommask;
            *(p+128) |= f << (8-y);
            ++p;
        }
    }
}

void GLCD_ST7565::drawString(byte x, byte y, const char *c) {
    while (*c) {
        drawChar(x, y, *c++);
        x += 6; // 6 pixels wide
        if (x + 6 >= LCDWIDTH) {
            x = 0;    // ran out of this line
            if (y+8 >= LCDHEIGHT)
                return; // ran out of space :(
            y += 8;
        }
    }
}

void GLCD_ST7565::drawString_P(byte x, byte y, const char *c) {
    for (;;) {
        char ch = pgm_read_byte(c++);
        if (ch == 0)
            break;
        drawChar(x, y, ch);
        x += 6; // 6 pixels wide
        if (x + 6 >= LCDWIDTH) {
            x = 0;    // ran out of this line
            if (y+8 >= LCDHEIGHT)
                return; // ran out of space :(
            y += 8;
        }
    }
}

// bresenham's algorithm - thx wikpedia <-- Pity you didn't quite get it right ;-)
void GLCD_ST7565::drawLine(byte x0, byte y0, byte x1, byte y1, 
                      byte color) {
#ifdef tradeSizeForSpeed            
    if (x0 > xUpdateMax) xUpdateMax = x0;
    if (x0 < xUpdateMin) xUpdateMin = x0;
    if (x1 > xUpdateMax) xUpdateMax = x1;
    if (x1 < xUpdateMin) xUpdateMin = x1;
                                      
    if (y0 > yUpdateMax) yUpdateMax = y0;
    if (y0 < yUpdateMin) yUpdateMin = y0;
    if (y1 > yUpdateMax) yUpdateMax = y1;
    if (y1 < yUpdateMin) yUpdateMin = y1;
#endif

    byte steep = abs(y1-y0) > abs(x1-x0);
    if (steep) {
        swap(x0, y0);
        swap(x1, y1);
    }
  
    if (x0 > x1) {
        swap(x0, x1);
        swap(y0, y1);
    }
  
    byte dx = x1 - x0, dy = abs(y1 - y0);
    char err = dx / 2, ystep = y0 < y1 ? 1 : -1;
  
    while (x0 <= x1) {
        if (steep)
            mySetPixel(y0, x0, color);
        else
            mySetPixel(x0, y0, color);
        err -= dy;
        if (err < 0) {
            y0 += ystep;
            err += dx;
        }
        ++x0;
    }
}

// draw triangle
void GLCD_ST7565::drawTriangle(byte x0, byte y0, byte x1, byte y1, byte x2, byte y2, byte color) {
    drawLine(x0,y0,x1,y1,color);
    drawLine(x1,y1,x2,y2,color);
    drawLine(x2,y2,x0,y0,color);
}

static void drawTriangleLine(byte x0, byte y0, byte x1, byte y1, byte firstLine, byte *points, byte color) {
#ifdef tradeSizeForSpeed
    if (x0 > xUpdateMax) xUpdateMax = x0;
    if (x0 < xUpdateMin) xUpdateMin = x0;
    if (x1 > xUpdateMax) xUpdateMax = x1;
    if (x1 < xUpdateMin) xUpdateMin = x1;
                                      
    if (y0 > yUpdateMax) yUpdateMax = y0;
    if (y0 < yUpdateMin) yUpdateMin = y0;
    if (y1 > yUpdateMax) yUpdateMax = y1;
    if (y1 < yUpdateMin) yUpdateMin = y1;
#endif

    byte steep = abs(y1 - y0) > abs(x1 - x0);
    if (steep) {
        swap(x0, y0);
        swap(x1, y1);
    }

    if (x0 > x1) {
        swap(x0, x1);
        swap(y0, y1);
    }

    byte dx = x1 - x0, dy = abs(y1 - y0);
    char err = dx / 2, ystep = y0 < y1 ? 1 : -1;

    while (x0 <= x1) {
        if (steep) {
            if (!firstLine)
                GLCD_ST7565::drawLine(y0, x0, points[x0], x0, color);
            else if (x0 >= 0 && x0 < LCDHEIGHT)
                points[x0] = y0;
        } else {
            if (!firstLine)
                GLCD_ST7565::drawLine(x0, y0, points[y0], y0, color);
            else if (y0 >= 0 && y0 < LCDHEIGHT)
                points[y0] = x0;
        }
        err -= dy;
        if (err < 0) {
            y0 += ystep;
            err += dx;
        }
        ++x0;
    }
}

void GLCD_ST7565::fillTriangle(byte x0, byte y0, byte x1, byte y1, byte x2, byte y2, byte color) {
    byte points[LCDHEIGHT]; // 64 bytes taken to store line points for fill.
    // first we need to find the highest and lowest point
    // a little unrolled bubble will do for 3 points
    if (y2 < y1) { swap(y1,y2); swap(x1,x2); }
    if (y1 < y0) { swap(y1,y0); swap(x1,x0); }
    if (y2 < y1) { swap(y1,y2); swap(x1,x2); }
    // Now y0 is the top and y2 is the bottom.
        
    // The longest(vertical) line generate the entries in points array
    // the other lines do the drawing
    drawTriangleLine(x0, y0, x2, y2, 1, points, color);
    drawTriangleLine(x0, y0, x1, y1, 0, points, color);
    drawTriangleLine(x1, y1, x2, y2, 0, points, color);
}

// filled rectangle
void GLCD_ST7565::fillRect(byte x, byte y, byte w, byte h, byte color) {
    // stupidest version - just pixels - but fast with internal buffer!
#ifdef tradeSizeForSpeed
    if (x < xUpdateMin) xUpdateMin = x;
    if (y < yUpdateMin) yUpdateMin = y;
    if (x+w > xUpdateMax) xUpdateMax = x+w;
    if (y+h > yUpdateMax) yUpdateMax = y+h;
#endif

    for (byte i = x; i < x+w; i++) {
        for (byte j = y; j < y+h; ++j)
            mySetPixel(i, j, color);
    }
}

// draw a rectangle
void GLCD_ST7565::drawRect(byte x, byte y, byte w, byte h, byte color) {
    // stupidest version - just pixels - but fast with internal buffer!
#ifdef tradeSizeForSpeed
    if (x < xUpdateMin) xUpdateMin = x;
    if (y < yUpdateMin) yUpdateMin = y;
    if (x+w > xUpdateMax) xUpdateMax = x+w;
    if (y+h > yUpdateMax) yUpdateMax = y+h;
#endif

    for (byte i=x; i<x+w; i++) {
        mySetPixel(i, y, color);
        mySetPixel(i, y+h-1, color);
    }

    for (byte i=y; i<y+h; i++) {
        mySetPixel(x, i, color);
        mySetPixel(x+w-1, i, color);
    } 
}

// draw a circle outline
void GLCD_ST7565::drawCircle(byte x0, byte y0, byte r, byte color) {
#ifdef tradeSizeForSpeed
    if (x0-r < xUpdateMin) xUpdateMin = x0-r;
    if (y0-r < yUpdateMin) yUpdateMin = y0-r;
    if (x0+r > xUpdateMax) xUpdateMax = x0+r;
    if (y0+r > yUpdateMax) yUpdateMax = y0+r;   
#endif

    char f = 1 - r;
    char ddF_x = 1;
    char ddF_y = -2 * r;
    char x = 0;
    char y = r;
  
    mySetPixel(x0, y0+r, color);
    mySetPixel(x0, y0-r, color);
    mySetPixel(x0+r, y0, color);
    mySetPixel(x0-r, y0, color);

    while (x < y) {
        if (f >= 0) {
            y--;
            ddF_y += 2;
            f += ddF_y;
        }
        x++;
        ddF_x += 2;
        f += ddF_x;

        mySetPixel(x0 + x, y0 + y, color);
        mySetPixel(x0 - x, y0 + y, color);
        mySetPixel(x0 + x, y0 - y, color);
        mySetPixel(x0 - x, y0 - y, color);
    
        mySetPixel(x0 + y, y0 + x, color);
        mySetPixel(x0 - y, y0 + x, color);
        mySetPixel(x0 + y, y0 - x, color);
        mySetPixel(x0 - y, y0 - x, color);
    }
}

void GLCD_ST7565::fillCircle(byte x0, byte y0, byte r, byte color) {

#ifdef tradeSizeForSpeed
    if (x0-r < xUpdateMin) xUpdateMin = x0-r;
    if (y0-r < yUpdateMin) yUpdateMin = y0-r;
    if (x0+r > xUpdateMax) xUpdateMax = x0+r;
    if (y0+r > yUpdateMax) yUpdateMax = y0+r;   
#endif

    char f = 1 - r;
    char ddF_x = 1;
    char ddF_y = -2 * r;
    char x = 0;
    char y = r;

    for (byte i=y0-r; i<=y0+r; i++)
        setPixel(x0, i, color);

    while (x < y) {
        if (f >= 0) {
            y--;
            ddF_y += 2;
            f += ddF_y;
        }
        x++;
        ddF_x += 2;
        f += ddF_x;
  
        for (byte i=y0-y; i<=y0+y; i++) {
            mySetPixel(x0+x, i, color);
            mySetPixel(x0-x, i, color);
        } 
        for (byte i=y0-x; i<=y0+x; i++) {
            mySetPixel(x0+y, i, color);
            mySetPixel(x0-y, i, color);
        }    
    }
}

void GLCD_ST7565::refresh() {
#ifdef enablePartialUpdate
    if (xUpdateMin<=xUpdateMax) {
        for (byte p = yUpdateMin>>3; p <= yUpdateMax>>3; ++p) {
            setPage(p);
            st7565_Command(CMD_SET_COLUMN_UPPER |
                            (((xUpdateMin+LCDUNUSEDSTARTBYTES) >> 4) & 0x0F));
            st7565_Command(CMD_SET_COLUMN_LOWER |
                            ((xUpdateMin+LCDUNUSEDSTARTBYTES) & 0x0F));
            st7565_Command(CMD_RMW);
            // With column offset set to 4 you don't need or want this.
            for (byte c = xUpdateMin; c <=xUpdateMax; c++)
                st7565_Data(gLCDBuf[(128*p)+c]);
        }
        // after the screen update, reset the redraw region to nothing.
        xUpdateMax = 0;
        yUpdateMax = 0;
        xUpdateMin = LCDWIDTH-1;
        yUpdateMin = LCDHEIGHT-1;
    }
#else
    for (byte p = 0; p < 8; p++) {
        setPage(p);
        st7565_Command(CMD_SET_COLUMN_LOWER |
                        (LCDUNUSEDSTARTBYTES & 0x0F));
        st7565_Command(CMD_SET_COLUMN_UPPER |
                        ((LCDUNUSEDSTARTBYTES >> 4) & 0x0F));
        st7565_Command(CMD_RMW);
        // With column offset set to 4 you don't need or want this.
        for (byte c = 0; c < 128; c++)
            st7565_Data(gLCDBuf[(128*p)+c]);
    }
#endif
}

void GLCD_ST7565::setUpdateArea(byte x0, byte y0, byte x1, byte y1, byte allowReduction) {
#ifdef enablePartialUpdate
    if (x0 == 0xFF && allowReduction) {
        xUpdateMax = 0;           // reset area to nothing
        yUpdateMax = 0;
        xUpdateMin = LCDWIDTH-1;
        yUpdateMin = LCDHEIGHT-1;     
    } else {
        if (x0 > x1) swap(x0,x1);
        if (y0 > y1) swap(y0,y1);
    
        if (allowReduction) {
            xUpdateMin = x0;
            xUpdateMax = x1;
            yUpdateMin = y0;
            yUpdateMax = y1;
        } else {
            if (x0 < xUpdateMin) xUpdateMin = x0;
            if (x1 > xUpdateMax) xUpdateMax = x1;
            if (y0 < yUpdateMin) yUpdateMin = y0;
            if (y1 > yUpdateMax) yUpdateMax = y1;
        }
    }
#endif
}

void GLCD_ST7565::updateDisplayArea(byte x0,byte y0,byte x1,byte y1, byte reset) {
#ifdef enablePartialUpdate
    if (x0 <= x1 && y0 <= y1) {
        for (byte p = y0>>3; p <= y1>>3; ++p) {
            setPage(p);
            st7565_Command(CMD_SET_COLUMN_UPPER |
                            (((x0+LCDUNUSEDSTARTBYTES) >> 4) & 0x0F));
            st7565_Command(CMD_SET_COLUMN_LOWER |
                            ((x0+LCDUNUSEDSTARTBYTES) & 0x0F));
            st7565_Command(CMD_RMW);
            for (byte c = x0; c <= x1; ++c)
                st7565_Data(gLCDBuf[128*p+c]);
        }
    }
    if (reset || (x0 <= xUpdateMin && x1 >= xUpdateMax &&
                  y0 <= yUpdateMin && y1 >= yUpdateMax)) {
        // if reset set, or the area painted covers the current region,
        // then clear the partial update region
        xUpdateMax = 0;           
        yUpdateMax = 0;
        xUpdateMin = LCDWIDTH-1;
        yUpdateMin = LCDHEIGHT-1;     
    }
#endif
}

// clear everything
void GLCD_ST7565::clear() {
    memset(gLCDBuf, 0x00, sizeof gLCDBuf);
#ifdef enablePartialUpdate
    xUpdateMin = 0; // set the partial update region to the whole screen
    yUpdateMin = 0;
    xUpdateMax = LCDWIDTH-1;
    yUpdateMax = LCDHEIGHT-1;
#endif
}

static void st7565_scrollUp(byte y) {
#ifdef enablePartialUpdate
    xUpdateMin = 0;   // set the partial update region to the whole screen
    yUpdateMin = 0;
    xUpdateMax = LCDWIDTH-1;
    yUpdateMax = LCDHEIGHT-1;
#endif
    if (y>7) {     // easy one, whole line scroll. This routine is used to do the whole line jumps.
        for (byte l = 0; l < 8-(y>>3); ++l) {
            byte* p = gLCDBuf +(l * 128);
            for (byte x = 0; x < LCDWIDTH; ++x) {
                *(p+x) = *(p+(y>>3)*128+x);
            }
        }
        for (byte l = 8-(y>>3); l < 8; ++l) {
            byte* p = gLCDBuf +(l * 128);
            for (byte x = 0; x < LCDWIDTH; ++x)
                *(p+x) = 0;
        }
    }
    byte bits = y&7;
    if (bits) { // And now the fine scroll bit
        for (byte l = 0; l < 7; ++l) {
            byte* p = gLCDBuf +(l * 128);
            for (byte x = 0; x < LCDWIDTH; ++x) {
                byte top = *(p+x)<<bits;
                byte bottom = *(p+x+128)>>(8-bits);
                *(p+x) = top | bottom;                                
            }           
        }   
        byte* p = gLCDBuf +(7 * 128);
        for (byte x = 0; x < LCDWIDTH; ++x)
            *(p+x) = *(p+x)<<bits;
    }
}

static void st7565_scrollDown(byte y) {
#ifdef enablePartialUpdate
    xUpdateMin=0;   // set the partial update region to the whole screen
    yUpdateMin=0;
    xUpdateMax=LCDWIDTH-1;
    yUpdateMax=LCDHEIGHT-1;
#endif
    if (y>7) {     // easy one, whole line scroll.
        for (byte l = 7; l >= (y>>3); --l) {
            byte* p = gLCDBuf + (l * 128);
            for (byte x = 0; x < LCDWIDTH; ++x)
                *(p+x) = *(p-(y>>3)*128+x);
        }
        for (byte l = 0; l < (y>>3); ++l) {
            byte* p = gLCDBuf +(l * 128);
            for (byte x = 0; x < LCDWIDTH; ++x)
                *(p+x) = 0;
        }
    }
    if ((y&7)!=0) {         // And now the fine scroll bit
        byte bits=y&7;
        for (byte l=7;l>0;l--) {
            byte* p = gLCDBuf +(l * 128);
            for (byte x = 0; x < LCDWIDTH; ++x) {
                byte bottom = *(p+x)>>bits;
                byte top = *(p+x-128)<<(8-bits);
                *(p+x) = top | bottom;                                
            }           
        }   
        byte* p = gLCDBuf;
        for (byte x=0;x<LCDWIDTH;x++)
            *(p+x)=*(p+x)>>bits;
    }
}

static void st7565_scrollLeft(byte x) {
    #ifdef enablePartialUpdate
        xUpdateMin=0;   // set the partial update region to the whole screen
        yUpdateMin=0;
        xUpdateMax=LCDWIDTH-1;
        yUpdateMax=LCDHEIGHT-1;
    #endif
    for (byte l=0;l<=7;l++) {
        byte* p = gLCDBuf +(l * 128);
        for (byte b = 0; b < LCDWIDTH-x; ++b)
            *(p+b) = *(p+b+x);
        for (byte b = LCDWIDTH-x; b < LCDWIDTH; ++b)
            *(p+b) = 0;
    }
}

static void st7565_scrollRight(byte x) {
#ifdef enablePartialUpdate
    xUpdateMin = 0;   // set the partial update region to the whole screen
    yUpdateMin = 0;
    xUpdateMax = LCDWIDTH-1;
    yUpdateMax = LCDHEIGHT-1;
#endif
    for (byte l = 0; l < 8; ++l) {
        byte* p = gLCDBuf + (l * 128);
        for (byte b = LCDWIDTH-1; b >= x; --b)
            *(p+b) = *(p+b-x);
        for (byte b = 0; b < x; ++b)
            *(p+b) = 0;
    }
}

void GLCD_ST7565::scroll(byte direction, byte pixels) {
    switch (direction) {
        case SCROLLUP:    st7565_scrollUp(pixels); break;
        case SCROLLDOWN:  st7565_scrollDown(pixels); break;
        case SCROLLLEFT:  st7565_scrollLeft(pixels); break;
        case SCROLLRIGHT: st7565_scrollRight(pixels); break;
    }
}

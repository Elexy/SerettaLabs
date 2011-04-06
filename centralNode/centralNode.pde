#include <EtherCard.h>
#include <Ports.h>
#include <PortsLCD.h>
#include <RF12.h>
#include <payload.h>
#include <PortsSHT11.h>

#define DEBUG 1 // set to 1 to show incoming requests on serial port
#define SMOOTH          3       // smoothing factor used for running averages

SHT11 sht11 (3);

Port pir_ldr (1);

PortI2C myI2C (2);
LiquidCrystalI2C lcd (myI2C);

byte celsius[8] = {
	B01110,
	B01010,
	B01110,
	B00000,
	B00000,
	B00000,
	B00000,
	B00000
};

// ethernet interface mac address
static byte mymac[6] = { 0x54,0x55,0x58,0x10,0x00,0x26 };
// ethernet interface ip address
static byte myip[4] = { 192,168,1,10 };

static byte buf[1000];      // tcp/ip send and receive buffer
static BufferFiller bfill;  // used as cursor while filling the buffer

// buffer for an outgoing data packet
static byte outBuf[RF12_MAXDATA], outDest;
static char outCount = -1;

// listen port for tcp/www:
#define HTTP_PORT 80
#define FEED_ID 20268

EtherCard eth;

static byte getMotion() {
  return pir_ldr.digiRead();
}

static MilliTimer reportTimer;  // don't report too often, unless moved
static byte prevMotion;         // track motion detector state
MilliTimer sendTimerPanel; // to time sending msgs 
MilliTimer lcdTimer; // to time refresh lcd
roomBoard roomData;
casitaData casita;
panelData panels;

// this has to be added since we're using the watchdog for low-power waiting
ISR(WDT_vect) { Sleepy::watchdogEvent(); }

static int smoothedAverage(int prev, int next, byte firstTime =0) {
    if (firstTime)
        return next;
    return ((SMOOTH - 1) * prev + next + SMOOTH / 2) / SMOOTH;
}

static void shtDelay () {
    Sleepy::loseSomeTime(32); // must wait at least 20 ms
}

// this code is called once per second, but not all calls will be reported
static void newReadings() {
//  byte motion = getMotion();  // always read out, to detect changes quickly

//  roomData.moved = motion != prevMotion;    
//  prevMotion = motion;

  byte firstTime = roomData.humi == 0;
  sht11.measure(SHT11::HUMI, shtDelay);        
  sht11.measure(SHT11::TEMP, shtDelay);
  float h, t;
//  sht11.calculate(h, t);
//  int humi = h + 0.5, temp = 10 * t + 0.5;
  int humi = 50, temp = 250;
  roomData.humi = smoothedAverage(roomData.humi, humi, firstTime);
  roomData.temp = smoothedAverage(roomData.temp, temp, firstTime);  
  
//  pir_ldr.digiWrite2(1);  // enable AIO pull-up
//  byte light = ~ pir_ldr.anaRead() >> 2;
//  pir_ldr.digiWrite2(0);  // disable pull-up to reduce current draw
//  roomData.light = smoothedAverage(roomData.light, light, firstTime);
}

int showHeat()
{
  // will contain a rotating heat indicator
  return roomData.dTemp;
}

int count = 0;

void lcdPrintDec( int value)
{
  lcd.print(value / 10);
  lcd.print('.');
  lcd.print(value % 10);
}

void secondLine()
{
  // set the cursor to column 0, line 1
  lcd.setCursor(0, 1);
  //  refresh every x seconds
  if (lcdTimer.poll(4000)) 
  {  
    lcd.print("                "); //clear line
    lcd.setCursor(0, 1);
    switch (count) {
      case 0 :
        lcd.print("fp:");
        lcd.print((int) casita.floorPump);
        lcd.print(" fl:");
        lcd.print((int) casita.floorFlow);
        break;
      case 1 :
        lcd.print("tt");
        lcdPrintDec(casita.tankTop);
//        lcd.write(3);
        lcd.print("ti");
        lcdPrintDec(casita.tankIn);
//        lcd.write(3);
        lcd.print("sp");
        lcd.print(casita.solarPump ? 1 : 0);        
        break;
      case 2 :
        lcd.print("pi");
        lcdPrintDec(panels.tempIn);
        lcd.print("po");
        lcdPrintDec(panels.tempOut);
        lcd.write(3);        
        lcd.print("w:");
        lcd.print(panels.water ? 1 : 0);
        lcd.print("p");
        lcd.print(panels.needPump ? 1 : 0);
        lcd.print(panels.pump ? 1 : 0);        
        break;      
      case 3 :        
        lcd.print("xo:");
        lcdPrintDec(casita.xchangeOut);
        lcd.write(3);
        lcd.print("ah:");
        lcdPrintDec(casita.afterHeater);
        lcd.write(3);
        break;      
      default :
        lcd.print("pump:");
        lcd.print(casita.floorPump);
        lcd.print(" flow:");
        lcd.print(casita.floorFlow);
    }
    count = (count + 1) % 4;
  }
}

/**
 * Function receive data
 */
void receive () {
  // data from the casita
  if (rf12_recvDone() && rf12_crc == 0) {
    Serial.println("received packet");
    if((RF12_HDR_MASK & rf12_hdr) == 30) { // casitadata
      casitaData* buf =  (casitaData*) rf12_data;

      casita.floorPump = buf->floorPump;
      casita.floorFlow = buf->floorFlow;
      casita.tankTop   = buf->tankTop;
      casita.tankIn    = buf->tankIn;
      casita.solarPump = buf->solarPump;
      casita.needPump  = buf->needPump;
      casita.xchangeOut= buf->xchangeOut;
      casita.afterHeater= buf->afterHeater;
      casita.fpPause   = buf->fpPause;      
    } else if ((RF12_HDR_MASK & rf12_hdr) == 1) { //paneldata
      panelData* buf =  (panelData*) rf12_data;

      panels.tempOut = buf->tempOut;
      panels.tempIn  = buf->tempIn;
      panels.tempAmb = buf->tempAmb;
      panels.pump    = buf->pump;
      panels.water   = buf->water;
      panels.needPump= buf->needPump;
    }
  } 
  /*else {
    roomBoard roomData;
    casitaData casita;
    panelData panels;
  }*/
}

void setup() {
  // set up the LCD's number of rows and columns: 
  lcd.begin(16, 2);
  // Print a message to the LCD.
  lcd.print("Thermostaat");
  delay(1000);
  lcd.createChar(3, celsius);
  lcd.clear();

  Serial.begin(57600);
  Serial.print("\n[CentralNode]");
  rf12_config();
  rf12_easyInit(5); // throttle packet sending to at least 1 seconds apart

//  sht11.enableCRC();
  
  pir_ldr.mode(INPUT);
  pir_ldr.digiWrite(1);   // pull-up DIO
  pir_ldr.mode2(INPUT);
  pir_ldr.digiWrite2(1);  // pull-up AIO

  roomData.dTemp = 197;
  
  delay(1000);
  /* init ENC28J60, must be done after SPI has been properly set up! */
//  eth.spiInit();
  eth.initialize(mymac);
  eth.initIp(mymac, myip, HTTP_PORT);

}

char okHeader[] PROGMEM = 
    "HTTP/1.0 200 OK\r\n"
    "Content-Type: text/csv\n\n"
;

static void homePage(BufferFiller& buf) {
    buf.emit_p(PSTR("$F1$D\r\n$D\r\n$D"), okHeader,
      casita.xchangeOut, panels.tempAmb, roomData.temp);
}

boolean heater = false;

void loop() {
    
  word len = eth.packetReceive(buf, sizeof buf);
    // ENC28J60 loop runner: handle ping and wait for a tcp packet
  word pos = eth.packetLoop(buf,len);
    // check if valid tcp data is received
    if (pos) {
        bfill = eth.tcpOffset(buf);
        char* data = (char *) buf + pos;
        Serial.println(data);
        // receive buf hasn't been clobbered by reply yet
        if (strncmp("GET / ", data, 6) == 0)
            homePage(bfill);
        else
            bfill.emit_p(PSTR(
                "HTTP/1.0 401 Unauthorized\r\n"
                "Content-Type: text/html\r\n"
                "\r\n"
                "<h1>401 Unauthorized</h1>"));  
        eth.httpServerReply(buf,bfill.position()); // send web page data
    }
    
//  if ( !(roomData.temp > roomData.dTemp + 1) 
//      &&
//      roomData.temp <= roomData.dTemp - 1 ) {      
//    roomData.heat = 1;
//    heater = true;
//  } else {
//    roomData.heat = 0; 
//    heater = false;
//  }

  // set the cursor to column 0, line 1
  lcd.setCursor(0, 0);
  // print the current temp
  lcdPrintDec(roomData.temp);
  lcd.write(3);
  lcd.print("out:");
  lcdPrintDec(panels.tempAmb);
  lcd.write(3);
  lcd.print("");
  if(casita.fpPause) {
    lcd.print("p");
  } else {
    lcd.print((int) roomData.heat);
  }

  secondLine();
  receive();
  if (sendTimerPanel.poll(5000)) {
    newReadings();     
    
    while (!rf12_canSend())
      rf12_recvDone();
    rf12_sendStart(0, &roomData, sizeof roomData);            
    rf12_sendWait(1);
    
    
    Serial.print("Living ");
    Serial.println((int) panels.tempAmb);
  }
}


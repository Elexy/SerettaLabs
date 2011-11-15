//#include <EtherCard.h>
#include <Ports.h>
#include <PortsLCD.h>
#include <RF12.h>
#include <payload.h>
#include <PortsSHT11.h>

SHT11 sht11 (4);

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
static MilliTimer blTimer;  // don't report too often, unless moved
static byte prevMotion;         // track motion detector state
MilliTimer sendTimerPanel; // to time sending msgs 
MilliTimer lcdTimer; // to time refresh lcd
roomBoard roomData;
casitaData casita;
panelData panels;

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
       roomData.lobat = rf12_lowbat();
  }
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
        lcd.print("tb");
        lcdPrintDec(casita.tankBottom);       
        break;
      case 2 :
        lcd.print("pi");
        lcdPrintDec(panels.tempIn);
        lcd.print("po");
        lcdPrintDec(panels.tempOut);
        lcd.write(3);        
        lcd.print("p");
        lcd.print(casita.solarPump ? 1 : 0);        
        break;      
      case 3 :        
        lcd.print("xo:");
        lcdPrintDec(casita.xchangeOut);
        lcd.write(3);
        lcd.print("ah:");
        lcdPrintDec(casita.afterHeater);
        lcd.write(3);
        break;      
      case 4:
        lcd.print("ti");
        lcdPrintDec(casita.tankIn);
        lcd.print("hp");
        if(casita.errorCode == 1) {
          lcd.print("error");
        } else {
          lcd.print(casita.heaterPump ? 1 : 0);
        }
        break;
      default :
        lcd.print("pump:");
        lcd.print(casita.floorPump);
        lcd.print(" flow:");
        lcd.print(casita.floorFlow);
    }
    count = (count + 1) % 5;
  }
}

/**
 * Function receive data
 */
void receive () {
  // data from the casita
  if (rf12_recvDone() && rf12_crc == 0) {
    Serial.println("received packet");
    //Serial.print(RF12_HDR_MASK & rf12_hdr);
    if((RF12_HDR_MASK & rf12_hdr) == casitaID) { // casitadata
      casitaData* buf =  (casitaData*) rf12_data;

      casita.floorPump = buf->floorPump;
      casita.floorFlow = buf->floorFlow;
      casita.tankTop   = buf->tankTop;
      //Serial.println(buf->tankTop);
      casita.tankBottom= buf->tankBottom;
      casita.tankIn    = buf->tankIn;
      casita.solarPump = buf->solarPump;
      casita.xchangeOut= buf->xchangeOut;
      casita.afterHeater= buf->afterHeater;
      casita.errorCode = buf->errorCode;
      casita.heaterPump = buf->heaterPump;
    } else if ((RF12_HDR_MASK & rf12_hdr) == panelsID) { //paneldata
      panelData* buf =  (panelData*) rf12_data;
Serial.println("received paneldata");
      roomData.panelOut = panels.tempOut = buf->tempOut; //relay panelouttemp
      panels.tempIn  = buf->tempIn;
      panels.tempAmb = buf->tempAmb;
      panels.pump    = buf->pump;
      panels.water   = buf->water;
      Serial.print("## tempAmb ");
      Serial.println((int) panels.tempAmb);
      Serial.print("## panelsIn ");
      Serial.println((int) panels.tempIn);
      Serial.print("## panelsOut ");
      Serial.println((int) panels.tempOut);
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
  // now turn off
  lcd.noBacklight();
  lcd.noDisplay();

  Serial.begin(57600);
  Serial.print("\n[LivingRoom]");
  rf12_config();
  rf12_easyInit(1); // throttle packet sending to at least 1 seconds apart

  pir_ldr.mode(INPUT);
  pir_ldr.digiWrite(1);   // pull-up DIO
  pir_ldr.mode2(INPUT);
  pir_ldr.digiWrite2(1);  // pull-up AIO

  roomData.dTemp = 206;
}

//boolean heater = false;


void loop() {
  receive();
  if (roomData.temp <= roomData.dTemp - 1)
  {      
    roomData.heat = 1;
  } 
  if (roomData.temp >roomData.dTemp + 1) {
    roomData.heat = 0; 
  }
  
  if(roomData.moved) {
    lcd.display();
    lcd.backlight();    
    blTimer.set(30000);
  }
  
  if(blTimer.poll() && !roomData.moved) {
    lcd.noBacklight();
    lcd.noDisplay();
  }
  
  // set the cursor to column 0, line 1
  lcd.setCursor(0, 0);
  // print the current temp
  lcdPrintDec(roomData.temp);
  lcd.write(3);
  lcd.print("out:");
  lcdPrintDec(panels.tempAmb);
  lcd.write(3);
  lcd.print("");
  lcd.print((int) roomData.heat);
    
  secondLine();
  
  roomData.auxHeat = 1;   
  
  if (sendTimerPanel.poll(2000)) {
    newReadings();    
    
    Serial.print((int) roomData.light);
    Serial.print(' ');
    Serial.print((int) roomData.moved);
    Serial.print(' ');
    Serial.print((int) roomData.humi);
    Serial.print(' ');
    Serial.print((int) roomData.temp);
    Serial.print(' ');
    Serial.println(showHeat());
    Serial.print("errorCode: ");
    Serial.println(casita.errorCode);
    Serial.print(" ");
    Serial.println(roomData.heat ? '1' : '0');
    while (!rf12_canSend())
      rf12_recvDone();
    rf12_sendStart(0, &roomData, sizeof roomData);            
    rf12_sendWait(2);
    
  }
}


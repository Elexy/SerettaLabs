/*********************************************************************************************\
 * Sketch: sense2
 * 
 * by: Andy van Dongen
 *
 * purpose:
 * - scan inputs comming from power, gas and water meter
 * - keep track of the total pulses
 * - store values to eeprom to overcome powerloss
 * - report values periodicaly over radio
 *
 \*********************************************************************************************/
#include <avr/io.h>
#include <Ports.h>
#include <RF12.h>
#include <avr/sleep.h>
#include <util/atomic.h>
#include <util/crc16.h>
#include <util/parity.h>
#include <EEPROM.h>

#include "sense.h"
#include "MovingSum.h"

// the persistent data structure that is stored in eeprom
struct {
  byte nodeId;
  byte netGroup;
  byte freqBand;
  byte version;
  unsigned long totalPulse[3];
  word crc;
} 
persistentData;

// sheduler states
enum { 
  CONSOLIDATE, 
  REPORT1, 
  REPORT2, 
  REPORT3, 
  TASK_END };

// sheduler to shedule tasks
Scheduler scheduler (TASK_END);

// array of moving sums (5 minute interval overflowin to hourly)
MovingSum consolidate[3] = {
  MovingSum(300 / (REPORT_PERIOD / 10), 12),     // moving sum every 5 minutes with overlow into 12 * 5 minutes = 1 hour, so last 5 minutes and last hour can be seen
  MovingSum(300 / (REPORT_PERIOD / 10), 12),     // moving sum every 5 minutes with overlow into 12 * 5 minutes = 1 hour, so last 5 minutes and last hour can be seen
  MovingSum(300 / (REPORT_PERIOD / 10), 12)      // moving sum every 5 minutes with overlow into 12 * 5 minutes = 1 hour, so last 5 minutes and last hour can be seen
  };

  /*********************************************************************************************\
   * Setup all ports etc
   \*********************************************************************************************/
  void setup () {
    // set port modes
    pinMode(SENSOR1, INPUT);
    pinMode(SENSOR2, INPUT);
    pinMode(SENSOR3, INPUT);
    pinMode(LED, OUTPUT);

    // pull up the inputs
    digitalWrite(SENSOR1, HIGH);
    digitalWrite(SENSOR2, HIGH);
    digitalWrite(SENSOR3, HIGH);

    // initialize serial interface
    Serial.begin(BAUDRATE);  

    // signal we're alive
    for (int x=0; x < 3; x++) {
      digitalWrite (LED, HIGH);
      delay (250);
      digitalWrite (LED, LOW);
      delay (250);
    }

    // restore the values of the counters to the last known state
    restoreData();

    // initialize the radio
    rf12_initialize(persistentData.nodeId, RF12_868MHZ, persistentData.netGroup);  

    // setup the reporting scheduler so that each meter is reported 3 second after the other
    // in order to give te receiving end time to handle them and to not flood the band
    scheduler.timer(CONSOLIDATE, 30);
    scheduler.timer(REPORT1, 60); 
    scheduler.timer(REPORT2, 90);
    scheduler.timer(REPORT3, 120);

    // show welcome and help screen on serial interface
    showHelp();

    // reset moving sum
    consolidate[0]  =  MovingSum(300 / (REPORT_PERIOD / 10), 12);
    consolidate[1]  =  MovingSum(300 / (REPORT_PERIOD / 10), 12);
    consolidate[2]  =  MovingSum(300 / (REPORT_PERIOD / 10), 12);
  }


/*********************************************************************************************\
 * Main program loop
 \*********************************************************************************************/
void loop ()   {
  digitalWrite(LED, LOW);
  rf12_recvDone();

  handleSerialInput();

  scanInputs();

  detectPulses();

  checkSheduler();
}

/*********************************************************************************************\
 * Handle input over the serial interface
 \*********************************************************************************************/
void handleSerialInput() {
  if(Serial.available()>0) {
    byte inp = Serial.read();
    if (inp != 0) {
      inp = inp - 49;

      if (inp == 0) {
        Serial.println ("\n");
        Serial.print ("Factory reset! Are you shure (y/n): ");
        while (inp != 121 && inp != 110) {
          rf12_recvDone();
          inp=Serial.read();
        }
        if (inp == 121) {
          ResetFactory();
        } 
        else {
          showHelp();
        }
      }
    }
  }
}

/*********************************************************************************************\
 * Read sensor inputs with debounce handling
 \*********************************************************************************************/
unsigned long intervalPulse[3];
long lastDebounceTime[3];
// arrays to detect rising edges
byte state[3];
byte lastState[3];
byte lastReading[3];

void scanInputs() {
  for (int x = 0; x <= 2; x++) {
    int reading = digitalRead(x+SENSOR1);

    // the state is different, due to noise or a pulse
    if (reading != lastReading[x]) {
      // reset the debounce timer
      lastDebounceTime[x] = millis();
    }

    if ((millis() - lastDebounceTime[x]) > DEBOUNCEDELAY) {
      // the sensor state is stable for DEBOUNCEDELAY milli seconds
      // the state is read into the system
      lastState[x] = state[x];
      state[x] = reading;
    }

    // save the reading for next time
    lastReading[x] = reading;
  }
}

/*********************************************************************************************\
 * Detect rising edged, update counters if needed and store new result to eeprom
 \*********************************************************************************************/
void detectPulses() {
  int changed=0;

  // handle the detected rising edges
  for (int x = 0; x <= 2; x++) {
    if (lastState[x] == LOW && state[x] == HIGH) {
      // do some indication
      digitalWrite(LED, HIGH);

      //count the pulse 
      persistentData.totalPulse[x]++;
      intervalPulse[x]++;
      changed=1;
    }
  }  

  if (changed != 0) {
    //store data to EEPROM if changed
    storeData();
  }  
}

/*********************************************************************************************\
 * Check if it is time to consolidate or report something
 \*********************************************************************************************/
void checkSheduler() {
  switch (scheduler.poll()) {
  case CONSOLIDATE:
    for (int x=0; x < 3; x++) {
      consolidate[x].add(intervalPulse[x]);
      intervalPulse[x] = 0;
    }

    scheduler.timer(CONSOLIDATE, REPORT_PERIOD);
    break;
  case REPORT1:
    doReport(0);
    scheduler.timer(REPORT1, REPORT_PERIOD);
    break;
  case REPORT2:
    doReport(1);
    scheduler.timer(REPORT2, REPORT_PERIOD);
    break;
  case REPORT3:
    doReport(2);
    scheduler.timer(REPORT3, REPORT_PERIOD);
    break;
  }
}

/*********************************************************************************************\
 * Send out a meter value over radio
 \*********************************************************************************************/
// payload that is send over the radio
struct SensorPayload {
  word sensorId;
  float values[4]; 
  byte lobat;  // supply voltage dropped under 3.1V: 0..1
} 
payload ;

void doReport(int x) {  
  consolidate[x].add(intervalPulse[x]);
#if DEBUG
  Serial.print ("doReport(");
  Serial.print(x,DEC);
  Serial.println(")");
#endif
  intervalPulse[x] = 0;

  payload.sensorId = BASEID + x;
  payload.values[0] = 1.0 * persistentData.totalPulse[x];
  payload.values[1] = 12.0 * consolidate[x].getTotalPulses();
  payload.values[2] = 1.0 * consolidate[x].getTotalPulsesOverFlow();
  payload.values[3] = 0;
  payload.lobat = 0;

  while (!rf12_canSend())
    rf12_recvDone();
  rf12_sendStart(0, &payload, sizeof payload);
  rf12_sendWait(0);
}

/*********************************************************************************************\
 * Store persistent data to eeprom
 \*********************************************************************************************/
void storeData() {
#if DEBUG
  Serial.print ("storeData(");
  Serial.println(")");
#endif
  persistentData.crc = SettingsCrc();

  char ByteToSave,*pointerToByteToSave=pointerToByteToSave=(char*)&persistentData;    //pointer verwijst nu naar startadres van de struct. Ge-cast naar char omdat EEPROMWrite per byte wegschrijft
  for(int x=0; x<sizeof(persistentData) ;x++)
  {
    EEPROM.write(x,*pointerToByteToSave); 
    pointerToByteToSave++;
  }  
}

/*********************************************************************************************\
 * Restore persistent data from eeprom
 \*********************************************************************************************/
void restoreData() {
  char ByteToSave,*pointerToByteToRead=(char*)&persistentData;   
  for(int x=0; x<sizeof(persistentData);x++)
  {
    *pointerToByteToRead=EEPROM.read(x);
    pointerToByteToRead++;// volgende byte uit de struct
  }

  if(persistentData.version!=VERSION) {
    ResetFactory(); // Als versienummer in EEPROM niet correct is, dan een ResetFactory
  }
  if(persistentData.crc != SettingsCrc()) {
    ResetFactory();
  }
}

/*********************************************************************************************\
 * Calculate crc for persistent data
 \*********************************************************************************************/
word SettingsCrc() {
  word crc = ~0;
  for (byte i = 0; i < sizeof(persistentData) - 2; ++i)
    crc = _crc16_update(crc, ((byte*) &persistentData)[i]);

  return crc;
}

/*********************************************************************************************\
 * Reset all eeprom stored values
 \*********************************************************************************************/
void ResetFactory(void)
{
  for (byte i = 0; i < sizeof(persistentData); ++i)
    ((byte*) &persistentData)[i] = 0;

  persistentData.version            = VERSION;
  persistentData.nodeId             = DEFAULT_NODEID;
  persistentData.netGroup           = DEFAULT_NETGROUP;
  persistentData.freqBand           = RF12_868MHZ;

  storeData();  
  delay(500);
  asm volatile ("jmp 0x0000"); 
}

/*********************************************************************************************\
 * Print help screen
 \*********************************************************************************************/
void showHelp() {
  Serial.println ("\n");
  Serial.print ("[Sense v");
  Serial.print (VERSION / 10,DEC);
  Serial.print (".");
  Serial.print (VERSION % 10,DEC);
  Serial.println ("]\n\n");
  Serial.println ("1: Reset all values to 0");
  Serial.print ("\ninput: ");
}

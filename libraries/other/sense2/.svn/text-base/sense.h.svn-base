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
#ifndef sense_h
#define sense_h

// input definition
#define SENSOR1 4
#define SENSOR2 5
#define SENSOR3 6

// indication led to signal action
#define LED 7 

// base of reported sensor id's --> input 0 = 4000, input 1 = 4001 etc
#define BASEID 0x4000

// default settings for the radio packets
#define DEFAULT_NODEID 2
#define DEFAULT_NETGROUP 212

// time to wait for a input debounce (milli seconds)
#define DEBOUNCEDELAY 50

// for the serial interface
#define BAUDRATE 9600

// set reporting every 30 seconds
#define REPORT_PERIOD 300

// sketch version
#define VERSION 1

#endif

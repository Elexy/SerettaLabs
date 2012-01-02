#include <Ports.h>
#include <RF12.h>

Port buttons (1);
Port sleepToggle (1);

MilliTimer awakeTimer;

ISR(WDT_vect) { Sleepy::watchdogEvent(); }
  
void setup()
{
  Serial.begin(57600);
  Serial.print("\n[buttonTest]");
  rf12_config();
  rf12_easyInit(5); // throttle packet sending to at least 5 seconds apart

  buttons.mode2(INPUT);
  sleepToggle.mode3(INPUT);
  attachInterrupt(1, wakeUp, RISING);
}

void wakeUp()
{
  Serial.println("interrupt");
}

int getButtonDirection(int value)
{
  Sleepy::loseSomeTime(500);
  if(value >= 680 && value <= 700) return 1;
  if(value >= 745 && value <= 765) return 2;
  if(value >= 815 && value <= 830) return 3;
  if(value >= 905 && value <= 920) return 4;
  return 0;
}

int value = 0;

void loop() 
{  
  value = getButtonDirection(buttons.anaRead());
  if(value) Serial.println(value);
}


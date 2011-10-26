// Arduino EEPROM killer
// modeled after code by John Boxall - http://tronixstuff.com - March 2011
// CC by-sa, see http://tronixstuff.wordpress.com/2011/05/11/
//                  discovering-arduinos-internal-eeprom-lifespan/
//
// Note: This sketch will destroy your Arduino's EEPROM
// Do not use with Arduino boards that have fixed microcontrollers

#include <LiquidCrystal.h>
#include <EEPROM.h>

#define MAXEE 1 // # of EE bytes to test, 1..512 for ATmega168

LiquidCrystal lcd(4,5,6,7,8,9);

long cycles; // maximum size is 2,147,483,647
long start; // start time in milliseconds since power-up

void setup () {
  lcd.begin(16, 2); // fire up the LCD

  // nice intro display with countdown
  lcd.clear();
  lcd.setCursor(0,0);
  lcd.print("EEPROM Destroyer");
  for (int a = 10; a > 0; --a) {
    lcd.setCursor(0,1);
    lcd.print("Starting in ");
    lcd.print(a);
    lcd.print("s ");
    delay(999);
  }
  lcd.clear();
  lcd.setCursor(0,0);
  lcd.print("# ");
  start = millis();
}

static bool check (byte value) {
    ++cycles;
    for (int a = 0; a < MAXEE; a++)
        EEPROM.write(a, value);
    for (int a = 0; a < MAXEE; a++)
        if (EEPROM.read(a) != value)
            return 0;
    return 1;
}

void loop () {
    lcd.setCursor(2,0);
    lcd.print(cycles);
    if (!check(85) || !check(170)) {
        lcd.setCursor(0,1);
        lcd.print("s ");
        lcd.print((millis() - start) / 1000);
        lcd.print(" FAIL!!!");
        while (1)
            ;
    }
}

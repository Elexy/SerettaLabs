#include <OneWire.h>


// DS18S20 Temperature chip i/o
OneWire ds18b20(4);  // on pin 10
typedef uint8_t DeviceAddress[8];
DeviceAddress panelOutID = { 0x28, 0xC7, 0xE4, 0xE5, 0x02, 0x00, 0x00, 0x46 };


int HighByte, LowByte, TReading, SignBit, Tc_100, Whole, Fract;

void setup(void) {
  // initialize inputs/outputs
  // start serial port
  Serial.begin(57600);
}

void loop(void) {
  byte i;
  byte present = 0;
  byte data[12];  

  ds18b20.select(panelOutID);
  ds18b20.write(0x44,1);         // start conversion, with parasite power on at the end

  delay(1000);     // maybe 750ms is enough, maybe not
  // we might do a ds18b20.depower() here, but the reset will take care of it.

  present = ds18b20.reset();
  ds18b20.select(panelOutID);    
  ds18b20.write(0xBE);         // Read Scratchpad

  Serial.print("P=");
  Serial.print(present,HEX);
  Serial.print(" ");
  for ( i = 0; i < 9; i++) {           // we need 9 bytes
    data[i] = ds18b20.read();
    Serial.print(data[i], HEX);
    Serial.print(" ");
  }
  Serial.print(" CRC=");
  Serial.print( OneWire::crc8( data, 8), HEX);
  Serial.print(" ");

  LowByte = data[0];
  HighByte = data[1];
  TReading = (HighByte << 8) + LowByte;
  SignBit = TReading & 0x8000;  // test most sig bit
  if (SignBit) // negative
  {
    TReading = (TReading ^ 0xffff) + 1; // 2's comp
  }
  Tc_100 = (6 * TReading) + TReading / 4;    // multiply by (100 * 0.0625) or 6.25

  Whole = Tc_100 / 100;  // separate off the whole and fractional portions
  Fract = Tc_100 % 100;


  if (SignBit) // If its negative
  {
     Serial.print("-");
  }
  Serial.print(Whole);
  Serial.print(".");
  if (Fract < 10)
  {
     Serial.print("0");
  }
  Serial.print(Fract);

  Serial.print("\n");

}

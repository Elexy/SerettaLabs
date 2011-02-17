// DS18B20 Tempsensor addresses
typedef uint8_t DeviceAddress[8];
DeviceAddress tankInID = { 0x28, 0xA3, 0x52, 0x7D, 0x02, 0x00, 0x00, 0x77 };
DeviceAddress panelOutID = { 0x28, 0xC7, 0xE4, 0xE5, 0x02, 0x00, 0x00, 0x46 };
DeviceAddress panelInID = { 0x28, 0xB9, 0x1A, 0xEC, 0x02, 0x00, 0x00, 0x5A };
DeviceAddress panelAmbID = { 0x28, 0x43, 0x35, 0xEC, 0x02, 0x00, 0x00, 0x70 };

MilliTimer tempTimerPanel; // timer to time between ask and read temp on the ds18
int tempWaitTime = 1000; // to time between ask and read temp on the ds18

// shared code
static int askTemp1Wire(DeviceAddress oneID)
{
    ds18b20.reset();
    ds18b20.select(oneID);
    ds18b20.skip();
    ds18b20.write(0x4E); // write to scratchpad
    ds18b20.write(0);
    ds18b20.write(0);
    ds18b20.write(0x1F); // 9-bits is enough, measurement takes 94 msec
    ds18b20.reset();
    ds18b20.skip();
    ds18b20.write(0x44, 1); // start conversion, parasite pull up on the end
}

/**
 * Call after 750ms afther askTemp1Wire
 */
static int readTemp1wire (DeviceAddress oneID) {
  ds18b20.reset();
  ds18b20.select(oneID);
//  ds18b20.skip();
  ds18b20.write(0xBE); // read scratchpad
  uint8_t data[9];
  for (uint8_t j = 0; j < 9; ++j)
      data[j] = ds18b20.read();
  ds18b20.reset();
  if (OneWire::crc8(data, 8) != data[8]) {
      //Serial.println(" crc? ");
      return 0;
  }
//  else { 
//    Serial.print("Data read: '"); 
//    for (uint8_t j = 0; j < 9; ++j)
//      Serial.print(data[j], HEX);
//  }
  
  return ((data[1] << 8) + data[0]) * 10 >> 4; // degrees * 10
}

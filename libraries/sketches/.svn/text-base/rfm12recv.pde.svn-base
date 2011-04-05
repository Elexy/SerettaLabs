// Test 868 MHz reception with RFM12B
// Project home page is http://lab.equi4.com/files/good_rf_rfm12b.php
//
// 2008-12-11  v1  public release by Jean-Claude Wippler as MIT-licensed OSS

#include <avr/io.h>

#define SPI_SS   10
#define SPI_MOSI 11
#define SPI_MISO 12
#define SPI_SCK  13

#define RFM_IRQ 2

#define LED_G 6
#define LED_R 7

uint8_t ChkSum;

void spi_init() {
    digitalWrite(SPI_SS, 1);
    pinMode(SPI_SS, OUTPUT);
    pinMode(SPI_MOSI, OUTPUT);
    pinMode(SPI_MISO, INPUT);
    pinMode(SPI_SCK, OUTPUT);
    
    SPCR = _BV(SPE) | _BV(MSTR);
}

uint8_t spi_send(uint8_t data) {
    SPDR = data;
    while (!(SPSR & _BV(SPIF)))
        ;
    return SPDR;
}

uint16_t rf12_xfer(uint16_t cmd) {
    uint16_t reply;
    digitalWrite(SPI_SS, 0);
    reply = spi_send(cmd >> 8) << 8;
    reply |= spi_send(cmd);
    digitalWrite(SPI_SS, 1);
    return reply;
}

uint8_t rf12_recv(){ 
    while (digitalRead(RFM_IRQ))
        ;
    rf12_xfer(0x0000);  
    uint8_t data = rf12_xfer(0xB000); 
    ChkSum += data;
    return data;
} 

void rf12_init() {
    rf12_xfer(0x80E7); // EL,EF,868band,12.0pF 
    rf12_xfer(0x8201);
    rf12_xfer(0xA640); // 868MHz 
    rf12_xfer(0xC647); // 4.8kbps 
    rf12_xfer(0x94A0); // VDI,FAST,134kHz,0dBm,-103dBm 
    rf12_xfer(0xC2AC); // AL,!ml,DIG,DQD4 
    rf12_xfer(0xCA81); // FIFO8,SYNC,!ff,DR 
    rf12_xfer(0xCED4); // SYNC=2DD4； 
    rf12_xfer(0xC483); // @PWR,NO RSTRIC,!st,!fi,OE,EN 
    rf12_xfer(0x9850); // !mp,90kHz,MAX OUT 
    rf12_xfer(0xCC77); // OB1，OB0, LPX,！ddy，DDIT，BW0 
    rf12_xfer(0xE000); // NOT USE 
    rf12_xfer(0xC800); // NOT USE 
    rf12_xfer(0xC040); // 1.66MHz,2.2V 
}

void setup() {
    spi_init();
    rf12_init();
    pinMode(RFM_IRQ, INPUT);
    
    digitalWrite(LED_G, 1);
    digitalWrite(LED_R, 1);
    pinMode(LED_G, OUTPUT);
    pinMode(LED_R, OUTPUT);
    
    rf12_xfer(0x82D9); // receiver on
    rf12_xfer(0xCA81);
}

void loop() {
    uint8_t i;
    
    rf12_xfer(0xCA83); // Enable FIFO 

    ChkSum = 0;     
          
    for(i=0;i<16;i++){  
      rf12_recv(); 
      digitalWrite(LED_R, 0);
    }     
     
    uint8_t sum = ChkSum;
    
    i=rf12_recv();
    digitalWrite(LED_R, 1);  
    
    rf12_xfer(0xCA81); // Disable FIFO 
     
    if(sum==i){ 
      digitalWrite(LED_G, 0);  
      delay(200); 
      digitalWrite(LED_G, 1); 
    }      
}

// Simple demo for feeding some random data to Pachube.
// 2011-07-08 <jcw@equi4.com> http://opensource.org/licenses/mit-license.php
// $Id: pachube.pde 7751 2011-07-12 12:34:01Z jcw $

#include <Ports.h>
#include <RF12.h> // needed to avoid a linker error :(
#include <avr/sleep.h>
#include <OneWire.h>
#include <payload.h>
#include <EtherCard.h>

// change these settings to match your own setup
#define FEED    "39001"
#define APIKEY  "IwKQ6GINh2VreKYH7hZ4pdbI0_bKG_gsEb4ob0kXzAw"

// ethernet interface mac address
static byte mymac[] = { 0x74,0x69,0x69,0x2D,0x30,0x31 };
// ethernet interface ip address
static byte myip[] = { 192,168,1,203 };
// gateway ip address
static byte gwip[] = { 192,168,1,1 };
// dns ip address
static byte dnsip[] = { 192,168,1,1 };

//char website[] PROGMEM = "192.168.1.1";

byte Ethernet::buffer[700];
uint32_t timer;
Stash stash;

casitaData casita;
roomBoard room;
panelData panel;
/**
 * Function receive data
 */
void receive () {
  if (rf12_recvDone() && rf12_crc == 0) {
    Serial.println("received package");
    if ((RF12_HDR_MASK & rf12_hdr) == livingRoomID ) {
      roomBoard* buf =  (roomBoard*) rf12_data;

      room.heat = buf->heat;
      room.temp = buf->temp;
      room.auxHeat = buf->auxHeat;
      room.panelOut = buf->panelOut;
          
    } else if ((RF12_HDR_MASK & rf12_hdr) == panelsID) { // from the panels
      panelData* buf =  (panelData*) rf12_data;

      panel.tempOut = buf->tempOut;
      panel.tempIn = buf->tempIn;
      panel.tempAmb = buf->tempAmb;
      
    } else if ((RF12_HDR_MASK & rf12_hdr) == casitaID) { // from the panels
      casitaData* buf =  (casitaData*) rf12_data;

      casita.tankIn = buf->tankIn; //temp going into the tank from panels
      casita.tankBottom = buf->tankBottom; // temperature bottom of tank
      casita.tankTop = buf->tankTop; // temperature top of tank
      casita.xchangeIn = buf->xchangeIn; // temperature going in the tank / back from floor
      casita.xchangeOut = buf->xchangeOut; // temperature coming out of the tank
      casita.afterHeater = buf->afterHeater; // temperature coming out of the tank
      casita.floorIn = buf->floorIn; // temperature going in the floor
      casita.floorFlow = buf->floorFlow; // The water flow speed.
      casita.errorCode = buf->errorCode; //error code 
    }
  }
}

void setup () {
  rf12_config();
  rf12_easyInit(5); // throttle packet sending to at least 5 seconds apart
  
  Serial.begin(57600);
  Serial.println("\n[webClient]");

  if (ether.begin(sizeof Ethernet::buffer, mymac) == 0) 
    Serial.println( "Failed to access Ethernet controller");
//  if (!ether.dhcpSetup())
//    Serial.println("DHCP failed");
  ether.staticSetup(myip, gwip, dnsip);

  ether.printIp("IP:  ", ether.myip);
  ether.printIp("GW:  ", ether.gwip);  
  ether.printIp("DNS: ", ether.dnsip);  
  
//  if (!ether.dnsLookup(website))
//    Serial.println("DNS failed");
  ether.hisip = { 192,168,1,1 };
  ether.hisport = 81;
    
  ether.printIp("SRV: ", ether.hisip);
}

void loop () {
  receive();
  
  ether.packetLoop(ether.packetReceive());

  
  if (millis() > timer) {
    timer = millis() + 10000;
    
    Serial.println(timer);
    Serial.println(millis());
  
    // we can determine the size of the generated message ahead of time
    byte sd = stash.create();
    stash.print("data=%5B");
    stash.print((word) room.heat);
    stash.print("%2C");
    stash.print((word) room.temp);
    stash.print("%2C");
    stash.print((word) room.auxHeat);
    stash.print("%2C");
    stash.print((word) room.panelOut);
    stash.print("%2C");
    stash.print((word) panel.tempIn);
    stash.print("%2C");
    stash.print((word) panel.tempAmb);
    stash.print("%2C");
    stash.print((word) panel.tempOut);
    stash.print("%2C");
    stash.print((word) casita.tankIn);
    stash.print("%2C");
    stash.print((word) casita.tankTop);
    stash.print("%2C");
    stash.print((word) casita.tankBottom);
    stash.print("%2C");
    stash.print((word) casita.xchangeIn);
    stash.print("%2C");
    stash.print((word) casita.xchangeOut);
    stash.print("%2C");
    stash.print((word) casita.afterHeater);
    stash.print("%2C");
    stash.print((word) casita.floorIn);
    stash.print("%5D");
    
    stash.save();
    
    // generate the header with payload - note that the stash size is used,
    // and that a "stash descriptor" is passed in as argument using "$H"
    Stash::prepare(PSTR("POST http://192.168.1.1:81/reader/server.php HTTP/1.0" "\r\n"
//                        "Host: $F" "\r\n"
//                        "X-PachubeApiKey: $F" "\r\n"
                        "Content-Type: application/x-www-form-urlencoded" "\r\n"
                        "Content-Length: $D" "\r\n"
                        "\r\n"
                        "$H"),
//            ether.hisip, 
//            website, 
//            PSTR(APIKEY), 
            stash.size(), 
            sd);

    // send the packet - this also releases all stash buffers once done
    ether.tcpSend();
  }
}

Jm doc "Decoder for the roomNode sketch, both serially connected and wireless."

proc SERIAL.ROOM {name l m h t b} {
  Ju tag $name moved $m temp $t rhum $h light $l lobat $b report {
    Value light "light" {$light/2.55} (0-100)
    Value temp "temperature" {$temp} °C -decimals 1
    Value humi "humidity" {$rhum} %
    # Value moved "motion" {$moved} (0-1)
    Value lobat "low battery" {$lobat} (0-1)
  }
}

proc RF12.DECODE {name raw} {
  # struct {
  #     byte light;     // light sensor: 0..255
  #     byte moved :1;  // motion detector: 0..1
  #     byte humi  :7;  // humidity: 0..100
  #     int temp   :10; // temperature: -500..+500 (tenths)
  #     byte lobat :1;  // supply voltage dropped under 3.1V: 0..1
  # } payload;
  return [SERIAL.ROOM $name {*}[RF12demo bitSlicer $raw 8 1 7 -10 1]]
}

Jm rev {$Id: roomNode.tcl 7372 2011-03-18 10:09:52Z jcw $}

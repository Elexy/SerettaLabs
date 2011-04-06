Jm doc "Decoder for the ookRelay2 sketch."

proc RF12.DECODE {name raw} {
  array set map {
    1 VISO 2 EMX 3 KSX 4 FSX
    5 ORSC 6 CRES 7 KAKU 8 XRF 9 HEZ
  }
  set result {}
  while {$raw ne ""} {
    lassign [RF12demo bitSlicer $raw 4 4] type size
    #puts "t $type s $size r [string length $raw] : [string map $map $type]"
    set proto [Ju get map($type) OOK]
    Ju merge result [Decode-$proto $type [string range $raw 1 $size]]
    set raw [string range $raw $size+1 end]
  }
  return $result
}

proc Decode-VISO {type raw} {
  Ju tag VISO hex [binary encode hex $raw]
}

proc Decode-EMX {type raw} {
  # see http://fhz4linux.info/tiki-index.php?page=EM+Protocol
  # example: EMX 0211726daefb214089007900
  lassign [RF12demo bitSlicer [RF12demo bitRemover $raw 8 1] \
                      8 8 8 16 16 16] e u s t a m
  Ju tag EM$e:$u seq $s tot $t avg $a max $m twrap 65536 report {
    Value avg "use (average)" {$avg * 12} W
    Value max "use (maximum)" {$max * 12} W
    Value total "cumulative" {$tot} Wh
  }
}

proc Decode-KSX {type raw} {
  # see http://www.dc3yc.homepage.t-online.de/protocol.htm
  # example: KSX 374309e795104a4ab54c
  # example: KSX 31ca1aabacf401
  lassign [RF12demo bitSlicer [RF12demo bitRemover $raw 4 1] \
                      4 4 4 4 4 4 4 4 4 4 4 4 4] \
    s f t0 t1 t2 t3 t4 t5 t6 t7 t8 t9 t10
  # the scans are a way to get rid of extra leading zero's
  switch $s.[string length $raw] {
    1.7 {
      set t [scan $t2$t1$t0 %d]
      set h [scan $t5$t4$t3 %d]
      if {$f & 0x8} { set t -$t }
      set n [expr {$f & 0x7}]
      Ju tag S300:$n temp $t rhum $h report {
        Value temp "temperature" {$temp} °C -decimals 1
        Value humi "humidity" {$rhum} % -decimals 1
      }
    }
    7.10 {
      # Log ksx {[string length $raw] <$s$f-$t10.$t9.$t8>\
      #           [binary encode hex [RF12demo bitRemover $raw 4 1]]\
      #           [binary encode hex $raw]}
      set t [scan $t2$t1$t0 %d]
      set h [scan $t4$t3 %d]
      set w [scan $t7$t6$t5 %d]
      set r [expr {256 * $t10 + 16 * $t9 + $t8}]
      if {$f & 0x8} { set t -$t }
      set n [expr {$f & 0x2 ? 1 : 0}]
      Ju tag KS300 temp $t rhum $h wind $w rain $r rnow $n rwrap 2048 report {
        Value temp "temperature" {$temp} °C -decimals 1
        Value humi "humidity" {$rhum} %
        Value wind "wind speed" {$wind} km/h -decimals 1
        Value rain "rain (cumulative)" {$rain} (0-2047)
        Value rnow "raining now" {$rnow} (0-1)
      }
    }
    default {
      Ju tag KSX hex [binary encode hex [RF12demo bitRemover $raw 4 1]]
    }
  }
}

proc Decode-FSX {type raw} {
  Ju tag FSX hex [binary encode hex $raw]
}

proc Decode-ORSC {type raw} {
  Ju tag ORSC hex [binary encode hex $raw]
}

proc Decode-CRES {type raw} {
  Ju tag CRES hex [binary encode hex $raw]
}

proc Decode-KAKU {type raw} {
  Ju tag KAKU hex [binary encode hex $raw]
}

proc Decode-XRF {type raw} {
  Ju tag XRF hex [binary encode hex $raw]
}

proc Decode-HEZ {type raw} {
  Ju tag HEZ hex [binary encode hex $raw]
}

proc Decode-OOK {type raw} {
  Ju tag OOK:$type hex [binary encode hex $raw]
}

Jm rev {$Id: ookRelay2.tcl 7490 2011-04-05 13:20:56Z jcw $}
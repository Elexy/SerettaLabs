/**
 * Data payload definition.
 */
typedef struct {
    boolean solarPump; // pump on or off
	byte spPwm; // solar pump pwm
	int tankIn; //temp going into the tank
	boolean needPump; // the additional pump at the panels
    boolean floorPump; // pump on or off
    byte fpPwm; // pump pwm;
    int tankBottom; // temperature bottom of tank
    int tankTop; // temperature top of tank
    int xchangeIn; // temperature going in the tank / back from floor
    int xchangeOut; // temperature coming out of the tank
    int afterHeater; // temperature coming out of the tank
    int floorIn; // temperature going in the floor
    int floorFlow; // The water flow speed.
	boolean fpPause; // pausing the floor pump
} casitaData;

typedef struct {
    boolean pump; // pump on or off
    boolean needPump; //we need the pump
	boolean water; // is there water detected
    int tempIn; // temperature panel in
    int tempOut; // temperature panel out
    int tempAmb; // temperature outside
//    int panelFlow; // The water flow speed.
} panelData;

typedef struct {
    byte light;     // light sensor
    byte moved :1;  // motion detector
    byte humi  :7;  // humidity
	boolean heat  :1; //need heat to be turned on
    int temp   :10; // temperature
//    byte lobat :1;  // supply voltage dropped under 3.1V
	int dTemp  ; // desired temp	
} roomBoard;

typedef struct {
	int temp :10; 
} setTemp;

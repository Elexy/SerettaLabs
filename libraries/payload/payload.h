/**
 * Data payload definition.
 */
typedef struct {
    byte solarPump; // pump on or off
	byte spPwm; // solar pump pwm
    byte floorPump; // pump on or off
    byte fpPwm; // pump pwm
    byte needHeat;
    int tempIn; // temperature panel in
    int tempOut; // temperature panel out
    int tempAmb; // temperature outside
    int panelFlow; // The water flow speed.
    int tankBottom; // temperature bottom of tank
    int tankTop; // temperature top of tank
    int xchangeIn; // temperature going in the tank / back from floor
    int xchangeOut; // temperature coming out of the tank
    int afterHeater; // temperature coming out of the tank
    int floorIn; // temperature going in the floor
    int floorFlow; // The water flow speed.
} casitaData;

typedef struct {
    byte pump; // pump on or off
    byte needPump;
    int tempIn; // temperature panel in
    int tempOut; // temperature panel out
    int tempAmb; // temperature outside
    int panelFlow; // The water flow speed.
} panelData;

typedef struct {
    byte light;     // light sensor
    byte moved :1;  // motion detector
    byte humi  :7;  // humidity
	byte heat  :1; //need heat to be turned on
    int temp   :10; // temperature
//    byte lobat :1;  // supply voltage dropped under 3.1V
	int dTemp  ; // desired temp	
} roomBoard;

typedef struct {
	byte heat;
	byte fpwm;
	byte solPump;
	byte spwm;
} heatingData;

typedef struct {
	byte pump; 
	byte pwm;
} panelPump;

typedef struct {
	int temp :10; 
} setTemp;

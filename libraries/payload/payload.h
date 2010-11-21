/**
 * Data payload definition.
 */
typedef struct {
    byte pump;      // pump on or off
    int tempIn; // temperature panel in
    int tempOut; // temperature panel out
    int tempAmb; // temperature outside
    int flow; // The water flow speed.
} payload;
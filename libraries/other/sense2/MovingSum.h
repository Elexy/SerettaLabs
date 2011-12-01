/*********************************************************************************************\
 * Sketch: sense2
 * 
 * by: Andy van Dongen
 *
 * purpose:
 * - handle moving sums
 *
 * e.g. movingSum(5,12) will ceate an object can hold data:
 * the last 5 running minutes, every minute
 * the last 1 running hour (12 * 5 = 60 minutes)
 *
 \*********************************************************************************************/
#ifndef MovingSum_h
#define MovingSum_h 1

class MovingSum {
private:
  unsigned long *pulses;  
  unsigned long total;

  unsigned long *pulsesOverFlow;  
  unsigned long totalOverFlow;

  int idxSample;
  int maxSample;

  int idxSampleOverFlow;
  int maxSampleOverFlow;

public:
  /*********************************************************************************************\
   * Setup a moving sum with x samples, overflowing into overflow samples
   \*********************************************************************************************/
  MovingSum(int numSamples, int numSamplesOverFlow);

  /*********************************************************************************************\
   * Add a new value to the sum, the last value will be overflowed into the overflow
   * the last value in the overflow will be discarded
   \*********************************************************************************************/
  void add(unsigned long numPulses);

  /*********************************************************************************************\
   * Gets the moving sum
   \*********************************************************************************************/
  unsigned long getTotalPulses();

  /*********************************************************************************************\
   * Gets the moving overflow sum
   \*********************************************************************************************/
  unsigned long getTotalPulsesOverFlow();
};
#endif

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
#include <stdlib.h>
#include <wiring.h>
#include "MovingSum.h"

/*********************************************************************************************\
 * Setup a moving sum with x samples, overflowing into overflow samples
 \*********************************************************************************************/
MovingSum::MovingSum(int numSamples, int numSamplesOverFlow) {
  maxSample = numSamples;
  idxSample = 0;
  total = 0;

  maxSampleOverFlow = numSamplesOverFlow;
  idxSampleOverFlow = 0;
  totalOverFlow = 0;

  // calculate the size of the buffer to be able to store the number of elements
  int newbuffersize = numSamples  * 4; // unsigned long = 4 bytes

  // allocate enough memory for "newelements" number of elements
  void * newarray = malloc ( newbuffersize );

  // did memory allocation fail?
  if (newarray!=0) {
    // clear the newly allocated memory space
    for (int idx= 0;idx < newbuffersize;idx++)
    {
      ((byte *)newarray)[idx] = 0;
    }

    pulses = (unsigned long *)newarray;
  }

  // calculate the size of the buffer to be able to store the number of elements
  newbuffersize = numSamplesOverFlow  * 4; // unsigned long = 4 bytes

  // allocate enough memory for "newelements" number of elements
  newarray = malloc ( newbuffersize );

  // did memory allocation fail?
  if (newarray!=0) {
    // clear the newly allocated memory space
    for (int idx= 0;idx < newbuffersize;idx++)
    {
      ((byte *)newarray)[idx] = 0;
    }

    pulsesOverFlow = (unsigned long *)newarray;
  }
}

/*********************************************************************************************\
 * Add a new value to the sum, the last value will be overflowed into the overflow
 * the last value in the overflow will be discarded
 \*********************************************************************************************/  
void MovingSum::add(unsigned long numPulses){
  total -= pulses[idxSample];
  total += numPulses;
  pulses[idxSample++] = numPulses;

  // cyclic buffer 
  if (idxSample == maxSample) {
    idxSample = 0;

    totalOverFlow -= pulsesOverFlow[idxSampleOverFlow];
    totalOverFlow += total;
    pulsesOverFlow[idxSampleOverFlow++] = total;

    if (idxSampleOverFlow == maxSampleOverFlow) {
      idxSampleOverFlow = 0;
    }
  } 
}

/*********************************************************************************************\
 * Gets the moving sum
 \*********************************************************************************************/  
unsigned long MovingSum::getTotalPulses() {
  return total;
}

/*********************************************************************************************\
 * Gets the moving overflow sum
 \*********************************************************************************************/  
unsigned long MovingSum::getTotalPulsesOverFlow() {
  return totalOverFlow;
}

//This file refers to the example code of 
//System-on-Chip Design with Arm(R) Cortex(R)-M by Joseph Yiu, 2019 
// ----------------------------------------------
// Purpose: Header file for LED utility functions
// ----------------------------------------------

#include "stdint.h"  // Required for the return type of LED_initialize
int32_t LED_Initialize (void); // function prototype for LED_Initialize
void    LED_On         (void); // function prototype for LED_On
void    LED_Off        (void); // function prototype for LED_Off
void 	LED_out    	   (uint8_t val); //send the val to output

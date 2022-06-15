//This file refers to the example code of 
//System-on-Chip Design with Arm(R) Cortex(R)-M by Joseph Yiu, 2019 
// ----------------------------------------------
// Purpose: LED utility functions
// ----------------------------------------------
// Chuanghao Zhang
//----------------------------
#include "LED.h"
#include "cm3_mcu.h"



//-----------------------------------
void    LED_On         (void)
{

  CM3MCU_GPIO0->DATAOUT |= (0xFFUL); // Set data output to 1    
  return;
}
//-----------------------------------
void    LED_Off        (void)
{

  CM3MCU_GPIO0->DATAOUT &= ~(0xFFUL); // Set data output to 0

  return;
}

//-----------------------------------
int32_t LED_Initialize (void)
{

  CM3MCU_GPIO0->DATAOUT &= ~(0xFFUL); // Set data output to 0
  CM3MCU_GPIO0->OUTEN   |= 0xFFUL; // Enable bit 0 as output
  return (0);
}

//set the val to output
void LED_out (uint8_t val)
{
	CM3MCU_GPIO0->DATAOUT = (uint32_t)val;
}

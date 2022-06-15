/*
*This provides SystemInit(void) usually used for system clock initialization
*/

#include <stdint.h>
#include "cm3_mcu.h"
/*----------------------------------------------------------------------------
DEFINES
*----------------------------------------------------------------------------*/
/*----------------------------------------------------------------------------
Define clocks
*----------------------------------------------------------------------------*/
#define XTAL (46000000UL) /* Oscillator frequency */
/*----------------------------------------------------------------------------
Clock Variable definitions
*----------------------------------------------------------------------------*/
uint32_t SystemCoreClock = XTAL; /*!< Processor Clock Frequency */
/*----------------------------------------------------------------------------
Clock functions
*----------------------------------------------------------------------------*/
void SystemCoreClockUpdate (void) /* Get Core Clock Frequency */
{
SystemCoreClock = XTAL;
}
/**
* Initialize the system
*
* @param none
* @return none
*
* @brief Setup the microcontroller system.
* Initialize the System.
*/
void SystemInit (void)
{
SystemCoreClock = XTAL;
return;
}



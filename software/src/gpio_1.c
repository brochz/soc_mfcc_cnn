#include "cm3_mcu.h"
#include "gpio_1.h"
void gpio_1_out_Initialize (void)
{

  CM3MCU_GPIO1->DATAOUT &= ~(0xFFUL); // Set data output to 0
  CM3MCU_GPIO1->OUTEN   |= 0xFFUL; // Enable bit 0 as output
}

//set the val to output
void gpio_1_out (uint8_t val)
{
	CM3MCU_GPIO1->DATAOUT = (uint32_t)val;
}

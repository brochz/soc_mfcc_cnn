#include "adc.h"
//div : must greater than 100 to meet adc conversion speed
//mode: 0 stands for signle transfer, otherwise double transfer
void adc_init_start(uint32_t div, uint32_t mode)
{	
  //config div
    CM3MCU_ADC -> DIV = div;
    /*enable interrupt*/
    //#1. Set NVIC Priority, 3bit
    NVIC_SetPriority(ADC_IRQn, 7);
    //#2. Enable NVIC
    NVIC_EnableIRQ(ADC_IRQn);
    
    //start adc
    if (mode)
    {
        CM3MCU_ADC -> CFG = 7; //111
    } else
    {
        CM3MCU_ADC -> CFG = 5; //101
    }
}

//stop adc
void adc_stop(void)
{
    CM3MCU_ADC -> CFG = 0; 
    NVIC_DisableIRQ(ADC_IRQn);
}

//return one sample in [11:0]
//or two samples in [16+11:16] and [11:0]
//ohter bits are 0
uint32_t adc_read_data(void)
{
    return CM3MCU_ADC -> DAT;
}







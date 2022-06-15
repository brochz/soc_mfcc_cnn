#ifndef ADC_H
#define ADC_H
#include "cm3_mcu.h"
void adc_init_start(uint32_t div, uint32_t mode);
void adc_stop(void);
uint32_t adc_read_data(void);

#endif


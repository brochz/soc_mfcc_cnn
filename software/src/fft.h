
#ifndef FFT_H
#define FFT_H

#include "cm3_mcu.h"
void fft_init(uint32_t n_need, uint32_t scale, uint32_t window);
void fft_write(int din);
float fft_read(void);
extern uint32_t fft_need;
#endif

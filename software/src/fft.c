#include "fft.h"

//window must euqal to 0 or 1
void fft_init(uint32_t n_need, uint32_t scale, uint32_t window){
    //n_need = 129, scale = 2**2,  int enable, window = 1,
    CM3MCU_FFT -> CFG = n_need<<8 | scale<<4 | 2 | window;
    /*enable interrupt*/
	//#1. Set NVIC Priority, 3bit
	NVIC_SetPriority(FFT_IRQn, 7);
	//#2. Enable NVIC
	NVIC_EnableIRQ(FFT_IRQn);
    //Start fft
    CM3MCU_FFT -> CTL = 1;
}

void fft_write(int din){
    CM3MCU_FFT -> DIN = din;
}

float fft_read(void){
    return CM3MCU_FFT -> DOUT;
}


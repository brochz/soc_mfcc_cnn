#include "adc.h"
#include "fft.h"
#include "cm3_calculate.h"
#include "buffer.h"
#include "weight.h"
#include "stdio.h"

//ADC_Handler priority = 1
void ADC_Handler(void)
{
    uint32_t sample = adc_read_data(); //clear int

//		//test code 
//		if (ibuf == 1000) return;
//		testbuf[ibuf++] = (sample>>16);
//		return;
//	
		//test code end
    if (adc_buffer.index == HOPSIZE)
    {
        while (adc_buffer.index)
        {
            fft_write(adc_buffer.buffer[adc_buffer.index--]);
        }

    }
		//test code 
		//printf("%x: %d\n", sample, (sample>>16));
		//printf("%x: %d\n", sample, (sample & 0x0000ffff)-ADC_BIAS);
		
    //move current sample to adc_buffer 
    adc_buffer.buffer[adc_buffer.index++] = (sample & 0x0000ffff) -  ADC_BIAS;
    adc_buffer.buffer[adc_buffer.index++] = (sample>>16) -  ADC_BIAS;

    fft_write(adc_buffer.buffer[adc_buffer.index-2]);
    fft_write(adc_buffer.buffer[adc_buffer.index-1]);
    return;
}

//FFT_Handler  priority = 2
void FFT_Handler(void)
{
    uint32_t i;
    for ( i = 0; i < FFT_NEED; i++)
    {
        fft_buffer[i] = fft_read();
    }

    //if the buffer is full return, abound this frame, wait cnn to read buffer
    if (mfccs_buffer.index == N_FRAMES_PER)
    {
        return;
    }

    //get 26 filters result and compute log
    for ( i = 0; i < N_FILTER_BANKS; i++)
    {
        bank_result_buffer[i] = fmac(CM3MCU_MAC0, (float *)mel_filter_banks_coes_W[i], fft_buffer+
            mel_filter_banks_start_len[i][0], mel_filter_banks_start_len[i][1]);
        // printf("%.10f,\n", bank_result_buffer[i]);
    }
    //add 10e-8, avoid log(0)
    fadd_bias(CM3MCU_MAC0, bank_result_buffer, 1e-8, N_FILTER_BANKS);
    //log base e
    for ( i = 0; i < N_FILTER_BANKS; i++)
    {
        bank_result_buffer[i] = flog(bank_result_buffer[i]);
    }	
    //calculate DCT result
    for ( i = 0; i < N_MFFCCS; i++)
    {
        mfccs_buffer.buffer[mfccs_buffer.index][i] = fmac(CM3MCU_MAC0, bank_result_buffer, dct_coe[i], N_FILTER_BANKS);
    }
    mfccs_buffer.index++;
    return;
}

#include "buffer.h"

//give the initial adc_buffer value HOPSIZE, means buffer is full
ADC_buffer adc_buffer = {HOPSIZE};

//buffers used in fft handler
float fft_buffer [FFT_NEED]; //129        
float bank_result_buffer [N_FILTER_BANKS];  //26
Mfccs_buffer mfccs_buffer = {0};

//CNN buffer
float cnn_input_buffer   [N_FRAMES][N_MFFCCS];
//CNN fix buffer 
float conv1_buffer[58][11][4];
float pool1_buffer[29][5][4];
float conv2_buffer[27][3][8];
float pool2_buffer[13][1][8];  //also the flatten buffer

float dense1_buffer[64];
float dense2_buffer[10];

//functions for buffers operation
void wait_and_trans_mfccs_to_cnn_buffer(void)
{
    uint32_t i, j;
    //wait N_FRAMES_PER mfccs
    while (mfccs_buffer.index != N_FRAMES_PER);
    //move the data
    for(i = 0; i < N_FRAMES_PER; i++)
    {
        for(j = 0; j < N_MFFCCS; j++)
        {
            cnn_input_buffer[i + N_FRAMES - N_FRAMES_PER][j] = mfccs_buffer.buffer[i][j];
        }
    }
    //clear mfccs buffer
    mfccs_buffer.index = 0;
}

void cnn_buffer_shift(void)
{
    uint32_t i, j;
    for(i = 0; i < N_FRAMES - N_FRAMES_PER; i++)
    {
        for(j = 0; j < N_MFFCCS; j++)
        {
            cnn_input_buffer[i][j] = cnn_input_buffer[i+N_FRAMES_PER][j];
        }
    }

}

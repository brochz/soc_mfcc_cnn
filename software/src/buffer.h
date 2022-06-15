//This file contains 

// defines and all buffers 
#ifndef BUFFER_H
#define BUFFER_H

#define SR      8000
#define HOPSIZE 128
#define FRAMESIZE 256
#define ADC_BIAS   2048
#define FFT_NEED   129
#define SCALE   2   //**2  input  p-p(1000) x2 pp(4000)
#define N_FILTER_BANKS 26
#define N_FRAMES  60
#define N_MFFCCS 13
#define INFER_FREQ 4  //every 0.25s conduct one predict
#define N_FRAMES_PER 15

#include "cm3_mcu.h"
typedef struct ADC_buffer
{
    uint32_t  index; // point to next  empty position, initial value is HOPSIZE//2
    int       buffer [HOPSIZE]; //this is the the sample value after substract the bias
}ADC_buffer;

typedef struct Mfccs_buffer
{
    uint32_t  index; // point to next  empty position, initial value is 0
    float     buffer [N_FRAMES_PER][N_MFFCCS]; //this is the the sample value after substract the bias
}Mfccs_buffer;

//adc buffer
extern ADC_buffer adc_buffer;
//FFT & MFCCs buffer
extern float fft_buffer         [FFT_NEED];
extern float bank_result_buffer [N_FILTER_BANKS];
extern Mfccs_buffer mfccs_buffer;

//CNN in buffer
extern float cnn_input_buffer   [N_FRAMES][N_MFFCCS];

//CNN fix size middle buffer and output buffer 
extern float conv1_buffer[58][11][4];
extern float pool1_buffer[29][5][4];
extern float conv2_buffer[27][3][8];
extern float pool2_buffer[13][1][8];  //also the flatten buffer

extern float dense1_buffer[64];
extern float dense2_buffer[10]; //final cnn output buffer


//Auxiliary function
void wait_and_trans_mfccs_to_cnn_buffer(void);
void cnn_buffer_shift(void);

#endif


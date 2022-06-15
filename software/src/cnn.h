
#ifndef CNN_H
#define CNN_H
#include "buffer.h"
void conv1(const float input[N_FRAMES][N_MFFCCS], const float W[4][3][3][1], const float b[4], float result[58][11][4]);
void pool1(const float input[58][11][4],  float output[29][5][4]);
void conv2(const float input[29][5][4], const float W[8][3][3][4], const float b[8], float result[27][3][8]);
void pool2(const float input[27][3][8],  float output[13][1][8]);
void dense1(const float * input, const float W[104][64], const float b[64] ,float  output[64] );
void linear(const float * input, const float W[64][10], const float b[10] ,float  output[10]);
void softmax(float *inout, uint32_t len);
uint8_t argmax(const float * predict, uint8_t len);
uint8_t cnn(const float input [N_FRAMES][N_MFFCCS]);

#endif

#include "cm3_mcu.h"
#ifndef WEIGHT_H
#define WEIGHT_H
extern const float conv2d_W [4][3][3][1];
extern const float conv2d_b [4] ;


extern const float conv2d_1_W [8][3][3][4]; //8 is #kernals
extern const float conv2d_1_b [8];

extern const float dense_W [104][64];
extern const float dense_b [64];

extern const float dense_1_W [64][10];
extern const float dense_1_b [10];

//sample order 
//(samples, h, w, channels)

//--------------
//(kernals, h, w, channels)
extern const uint32_t conv2d_W_shape   [4];
extern const uint32_t conv2d_1_W_shape4[4];
extern const uint32_t dense_W_shape    [2];
extern const uint32_t dense_1_W_shape  [2];

//For MFCC
extern const float mel_filter_banks_coes_W [26][18];
extern const uint32_t mel_filter_banks_start_len [26][2];
//For DCT
extern const float dct_coe [13][26];

//labels 
extern const char label[10][10];
#endif

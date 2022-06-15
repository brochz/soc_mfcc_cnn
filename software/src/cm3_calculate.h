#ifndef CM3_CALCULATE_H
#define CM3_CALCULATE_H
#include "cm3_mcu.h"
float fmac(CM3MCU_MAC_TypeDef* mac_h, const float * a, const float *b, uint32_t len);
void fadd_bias(CM3MCU_MAC_TypeDef* mac_h, float * array,  float bias, uint32_t len);
float flog(float  in);

#endif

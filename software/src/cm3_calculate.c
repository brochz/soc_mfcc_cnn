#include "cm3_calculate.h"


float fmac(CM3MCU_MAC_TypeDef* mac_h, const float * a, const float *b, uint32_t len)
{
    uint32_t i;
    for ( i = 0; i < len; i++)
    {
        mac_h -> DATINA = a[i];
        mac_h -> DATINB = b[i];
    }
    // __nop();
    return mac_h -> DOUT;
}

void fadd_bias(CM3MCU_MAC_TypeDef* mac_h, float * vector,  float bias, uint32_t len)
{
    uint32_t i;
    for ( i = 0; i < len; i++)
    {
        mac_h -> DATINA = vector[i];
        mac_h -> DATINB = 1.0;
        mac_h -> DATINA = bias;
        mac_h -> DATINB = 1.0;
        __nop();
        __nop();
        __nop();
        //result has 3 cycle delay
        vector[i] = mac_h -> DOUT;
    }
    
}


//perform ln(x) operation
float flog(float  in)
{
    CM3MCU_LOG -> DATIN = in;
    return CM3MCU_LOG -> DOUT;
}


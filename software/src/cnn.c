#include "cm3_calculate.h"
#include "cnn.h"
#include "math.h"
#include "weight.h"
void conv1(const float input[N_FRAMES][N_MFFCCS], const float W[4][3][3][1], const float b[4], float result[58][11][4])
{
    uint32_t k, r, c, i, j; 
    float tmp;
    for ( k = 0; k < 4; k++)
    {
        for ( r = 0; r < 58; r++)
        {
            for ( c = 0; c < 11; c++)
            {   
                //for one mac, 9
                for (i = r; i < r+3; i++)
                {
                    for ( j = c; j < c+3; j++)
                    {
                        //利用cm3_mac(乘加单元)进行浮点向量点积运算 *
                        CM3MCU_MAC1 -> DATINA = W[k][i-r][j-c][0];
                        CM3MCU_MAC1 -> DATINB = input[i][j];
                    }
                    
                }
                //add bias 
                CM3MCU_MAC1 -> DATINA = b[k];
                CM3MCU_MAC1 -> DATINB = 1.0;
                __nop();
                __nop();
                __nop();
                //fetch result from mac unit 
                //RELU
                //MSB = 1 is negtive
                tmp = CM3MCU_MAC1 -> DOUT;

                //Relu operation
                if (*(uint32_t*)(&tmp)>>31) //if tmp < 0.0
                {
                    result[r][c][k] = 0.0;
                }
                else
                {
                    result[r][c][k] = tmp;
                }
                
               
            }
            
        }
        
    }

}

//pooling size is 2x2 and stride is 2x2
//max pooling
void pool1(const float input[58][11][4],  float output[29][5][4])
{
    uint32_t k, r, c;
    float tmp;
     for ( k = 0; k < 4; k++)
    {
        for ( r = 0; r < 29; r ++)
        {
            for ( c = 0; c < 5; c ++)
            {   //three compare 
                tmp = input[r*2][c*2][k] > input[r*2][c*2+1][k]? input[r*2][c*2][k]: input[r*2][c*2+1][k];
                output[r][c][k] = input[r*2+1][c*2][k] > input[r*2+1][c*2+1][k]? input[r*2+1][c*2][k]: input[r*2+1][c*2+1][k];
                if (tmp > output[r][c][k])
                {
                    output[r][c][k] = tmp;
                }
                
            }
        }
    }
}


void conv2(const float input[29][5][4], const float W[8][3][3][4], const float b[8], float result[27][3][8])
{
    uint32_t k, r, c, i, j, d;
    float tmp;
    for ( k = 0; k < 8; k++)
    {
        for ( r = 0; r < 27; r++)
        {
            for ( c = 0; c < 3; c++)
            {   
                //for one mac, 9
                for (i = r; i < r+3; i++)
                {
                    for ( j = c; j < c+3; j++)
                    {
                        for (d = 0; d < 4; d++)
                        {
                            CM3MCU_MAC1 -> DATINA = W[k][i-r][j-c][d];
                            CM3MCU_MAC1 -> DATINB = input[i][j][d];
                        }
                    }
                    
                }
                //add bias 
                CM3MCU_MAC1 -> DATINA = b[k];
                CM3MCU_MAC1 -> DATINB = 1.0;
                __nop();
                __nop();
                __nop();
                //fetch result from mac unit 
                //RELU
                //MSB = 1 is negtive
                tmp = CM3MCU_MAC1 -> DOUT;

                //Relu operation
                if (*(uint32_t*)(&tmp)>>31) //if tmp < 0.0
                {
                    result[r][c][k] = 0.0;
                }
                else
                {
                    result[r][c][k] = tmp;
                }
                
               
            }
            
        }
        
    }

}


//pooling size is 2x3 and stride is 2x3
void pool2(const float input[27][3][8],  float output[13][1][8])
{
    uint32_t k, r;
    float tmp;
     for ( k = 0; k < 8; k++)
    {
        for ( r = 0; r < 13; r ++)
        {
            tmp = input[r*2][0][k] > input[r*2][1][k]? input[r*2][0][k] : input[r*2][1][k];
            tmp = tmp > input[r*2][2][k] ? tmp : input[r*2][2][k];

            output[r][0][k] =  input[r*2+1][0][k] > input[r*2+1][1][k]? input[r*2+1][0][k] : input[r*2+1][1][k];
            output[r][0][k] =  output[r][0][k] > input[r*2+1][2][k] ? output[r][0][k] : input[r*2+1][2][k];
            if (tmp > output[r][0][k])
            {
                output[r][0][k] = tmp;
            }
        }
    }
}

//13*8 -> 64
void dense1(const float * input, const float W[104][64], const float b[64] ,float  output[64] )
{
    uint32_t r, c;
    float tmp;
    for(r = 0; r < 64; r++)
    {
        for(c = 0; c < 104; c++)
        {
            CM3MCU_MAC1 -> DATINA = input[c];
            CM3MCU_MAC1 -> DATINB = W[c][r];
        }

        //add bias 
        CM3MCU_MAC1 -> DATINA = b[r];
        CM3MCU_MAC1 -> DATINB = 1.0;
        __nop();
        __nop();
        __nop();
        //fetch result from mac unit 
        //RELU
        //MSB = 1 is negtive
        tmp = CM3MCU_MAC1 -> DOUT;

        //Relu operation
        if (*(uint32_t*)(&tmp)>>31) //if tmp < 0.0
        {
            output[r] = 0.0;
        }
        else
        {
            output[r] = tmp;
        }           
    }
}


void linear(const float * input, const float W[64][10], const float b[10] ,float  output[10])
{
    uint32_t r, c;
    for(r = 0; r < 10; r++)
    {
        for(c = 0; c < 64; c++)
        {
            CM3MCU_MAC1 -> DATINA = input[c];
            CM3MCU_MAC1 -> DATINB = W[c][r];
        }
        CM3MCU_MAC1 -> DATINA = b[r];
        CM3MCU_MAC1 -> DATINB = 1.0;
        __nop();
        __nop();
        __nop();

        output[r] = CM3MCU_MAC1 -> DOUT;

    }
}

void softmax(float *inout, uint32_t len)
{
    uint32_t i;
    float sum;
    //exp(inout)
    for(i=0; i<len; i++)
    {
        inout[i] = expf(inout[i]);
        CM3MCU_MAC1 -> DATINA = inout[i];
        CM3MCU_MAC1 -> DATINB = 1.0;
    }
        // __nop();
        // __nop();
        // __nop();

    sum = CM3MCU_MAC1 -> DOUT;
    // x/sum
    for(i=0; i<len; i++)
    {
        inout[i] = inout[i] / sum;

    }
    
}

//get the max index , predict length  max to 128
uint8_t argmax(const float * predict, uint8_t len)
{
    uint8_t index = 0, i;
    for(i=0; i<len-1; i++){
        index = predict[i+1] > predict[index] ? i + 1 : index;
    }
    return index;
}


//cnn flow
uint8_t cnn(const float input [N_FRAMES][N_MFFCCS])
{
    conv1(input, conv2d_W, conv2d_b, conv1_buffer);
    pool1(conv1_buffer, pool1_buffer);
    conv2(pool1_buffer, conv2d_1_W, conv2d_1_b, conv2_buffer);
    pool2(conv2_buffer, pool2_buffer);
    dense1((float *)pool2_buffer, dense_W, dense_b, dense1_buffer);
    linear(dense1_buffer, dense_1_W, dense_1_b, dense2_buffer);
    softmax(dense2_buffer, 10);  //final result is in dense2_buffer
    return argmax(dense2_buffer, 10); // return final index
}


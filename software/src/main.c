#include "stdio.h"
#include "cm3_mcu.h"
#include "LED.h"
#include "gpio_1.h"
#include "adc.h"
#include "uart_util.h"
#include "fft.h"
#include "cm3_calculate.h"
#include "buffer.h"
#include "weight.h"
#include "cnn.h"
#include "sys_tick.h"
void led_flow(void);


uint32_t i;
uint8_t led = 0x0f;
uint8_t led_go = 1;
int main(void)
{
  uint8_t index, valide;
  LED_Initialize();
  gpio_1_out_Initialize();
  uart_config(SystemCoreClock / 115200);
  fft_init(FFT_NEED, SCALE, 1);
  SysTick_Config(SystemCoreClock / 1000); 
  adc_init_start(SystemCoreClock/8000 - 1, 1); //4khz int, double transfer

  //test code
  //the parameter is number of ticks between interruption 
  // 1KHz Ticks
  // conv1(test_array, conv2d_W, conv2d_b, conv1_buffer);
  // pool1(conv1_buffer, pool1_buffer);
  // conv2(pool1_buffer, conv2d_1_W, conv2d_1_b, conv2_buffer);
  // pool2(conv2_buffer, pool2_buffer);
  // dense1((float *)pool2_buffer, dense_W, dense_b, dense1_buffer);
  // linear(dense1_buffer, dense_1_W, dense_1_b, dense2_buffer);
  // softmax(dense2_buffer, 10);
  //  printf("[");
  //  for ( i = 0; i < 13; i++)
  //  {
  //    printf("[");
  //    for (j = 0; j < 1; j++)
  //    {
  //      printf("[");
  //      for (k = 0; k < 8; k++)
  //      {
  //        printf("%f,", pool2_buffer[i][j][k]);
  //      }
  //      printf("],\n");
  //    }
  //    printf("],\n");
  //  }
  //  printf("]");

  // printf("%d\n", cnn(test_array));

  // for (i = 0; i < 10; i++)
  // {
  //   printf("%f,", dense2_buffer[i]);
  // }
  while (1)
  {
		//led flash
		led_flow();
    //wait data to come
    wait_and_trans_mfccs_to_cnn_buffer();
    //perform cnn
    index = cnn(cnn_input_buffer);
    // confidence threshold 
    if (index == 6 || index == 0) //stop or five
    {
      if(dense2_buffer[index] > 0.9)
      {
					led_go = index == 6? 0 : led_go;
          printf("%s, %2.1f\n", label[index], dense2_buffer[index]);
      } else
      {
        printf(". \n");
      }
    }
    else if(dense2_buffer[index] > 0.7)// other
    {
				led_go = index == 2? 1 : led_go;
        printf("%s, %2.1f\n", label[index], dense2_buffer[index]);
    } else
    {
        printf(". \n");
    }

    cnn_buffer_shift();

		//test code 

  }
}

//for led flash
void led_flow(void)
{
	if(led_go==0) return ;
	CM3MCU_GPIO0 -> DATAOUT = led;
	if(led & 0x1<<7)
	{
		led++;
	}
	led = led << 1;
}


// void mfcc_test(void)
// {
// 	uint32_t i;
//   fft_init(FFT_NEED, SCALE, 1);
//   for (i = 0; i < 256; i++)
//   {
//     fft_write(sinwave[i]);
//   }
//   while (!mfccs_buffer.index)
//   {
//   }
//   printf("--------------MFCCs---------------\n");
//   for (i = 0; i < N_MFFCCS; i++)
//   {
//     printf("%f,\n", mfccs_buffer.buffer[0][i]);
//   }
// }

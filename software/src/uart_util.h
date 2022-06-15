#ifndef UART_UTIL_H
#define UART_UTIL_H


#include "cm3_mcu.h"
void uart_config(uint32_t div);
void uart_putc(char c);
char uart_getc(void);
//int stdout_putchar (int ch);



#endif


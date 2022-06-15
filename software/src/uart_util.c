/*
*Simple UART functions to configure the UART and basic UART transmit and receive function. 
*This is used for supporting message display during simulation.
*/


#include "uart_util.h"

void uart_config(uint32_t div)
{
    CM3MCU_UART0->BAUDDIV = div;
    CM3MCU_UART0->CTRL = 1; // Enable TX
    return;
}
void uart_putc(char c)
{
    while (CM3MCU_UART0->STATE & 1); // wait if TX FIFO full
    CM3MCU_UART0->TXD = (uint32_t) c;
    return;
}
char uart_getc(void)
{
    while ((CM3MCU_UART0->STATE & 2)==0); // wait if RX FIFO empty
    return ((char) CM3MCU_UART0->RXD);
}
// Function used by retarget_io.c
int stdout_putchar (int ch)
{
    uart_putc(ch);
    return (ch);
}

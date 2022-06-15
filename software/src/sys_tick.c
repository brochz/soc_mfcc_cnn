#include "sys_tick.h"

//gloabal  tick counter
volatile uint32_t SysTickCntr = 0;

void TickDelay(int32_t tnum)
{
  uint32_t LastTick = 0, NewTick = 0, DivideCntr = 0;

  LastTick = SysTickCntr; //
  NewTick = LastTick;

  DivideCntr = tnum;

  while (DivideCntr > 0)
  {
    NewTick = SysTickCntr;
    if (NewTick != LastTick)
    { // SysTickCntr changed wait one 1ms
      LastTick = NewTick;
      DivideCntr--;
    }
  }
  return;
}

void SysTick_Handler(void)
{ // Trigger at 1KHz
  //increase by 1ms
  SysTickCntr++;

  return;
}

/* 
*Device-specific header based on CMSIS-CORE. This contains the peripheral register definitions and
*interrupt assignments
*by Chuanghao Zhang
*This file refers to the example code of 
*System-on-Chip Design with Arm(R) Cortex(R)-M by Joseph Yiu, 2019 
*/

/*
  *This is include guard
  *ifndef or ifdef must followed by a endif 
*/
#ifndef CM3MCU_CM3_H
#define CM3MCU_CM3_H

#ifdef __cplusplus
 extern "C" {
#endif 

/** @addtogroup CM3MCU_Definitions CM3MCU_CM3 Definitions
  This file defines all structures and symbols for CM3MCU:
    - registers and bitfields
    - peripheral base address
    - peripheral ID
    - Peripheral definitions
  @{
*/


/******************************************************************************/
/*                Processor and Core Peripherals                              */
/******************************************************************************/
/** @addtogroup CM3MCU_CMSIS Device CMSIS Definitions
  Configuration of the Cortex-M3 Processor and Core Peripherals
  @{
*/

/*
 * ==========================================================================
 * ---------- Interrupt Number Definition -----------------------------------
 * ==========================================================================
 */
//
typedef enum IRQn
{
/******  Cortex-M3 Processor Exceptions Numbers ***************************************************/
  NonMaskableInt_IRQn           = -14,    /*!<  2 Cortex-M3 Non Maskable Interrupt                 */
  HardFault_IRQn                = -13,    /*!<  3 Cortex-M3 Hard Fault Interrupt                   */
  MemoryManagement_IRQn         = -12,    /*!<  4 Cortex-M3 Memory Management Interrupt            */
  BusFault_IRQn                 = -11,    /*!<  5 Cortex-M3 Bus Fault Interrupt                    */
  UsageFault_IRQn               = -10,    /*!<  6 Cortex-M3 Usage Fault Interrupt                  */
  SVCall_IRQn                   = -5,     /*!< 11 Cortex-M3 SV Call Interrupt                      */
  DebugMonitor_IRQn             = -4,     /*!< 12 Cortex-M3 Debug Monitor Interrupt                */
  PendSV_IRQn                   = -2,     /*!< 14 Cortex-M3 Pend SV Interrupt                      */
  SysTick_IRQn                  = -1,     /*!< 15 Cortex-M3 System Tick Interrupt                  */

/******  CM3MCU Specific Interrupt Numbers *******************************************************/
  GPIO0_IRQn                    = 0,       /*!< Port 0 combined Interrupt                        */
  GPIO1_IRQn                    = 1,       /*!< Port 0 combined Interrupt                        */
  TIMER0_IRQn                   = 2,       /*!< TIMER 0 Interrupt                                */
  TIMER1_IRQn                   = 3,       /*!< TIMER 1 Interrupt                                */
  UARTTX0_IRQn                  = 4,       /*!< UART 0 TX Interrupt                              */
  UARTRX0_IRQn                  = 5,       /*!< UART 0 RX Interrupt                              */
	ADC_IRQn											= 6,			/*!< ADC Conversion done Interrupt                     */
	FFT_IRQn											= 7,			/*!< ADC Conversion done Interrupt                     */
} IRQn_Type;


/*
 * ==========================================================================
 * ----------- Processor and Core Peripheral Section ------------------------
 * ==========================================================================
 */

/* Configuration of the Cortex-M3 Processor and Core Peripherals */
#define __CM3_REV                 0x0201    /*!< Core Revision r2p1                             */
#define __NVIC_PRIO_BITS          3         /*!< Number of Bits used for Priority Levels        */
#define __Vendor_SysTickConfig    0         /*!< Set to 1 if different SysTick Config is used   */
#define __MPU_PRESENT             0         /*!< MPU present or not                             */

/*@}*/ /* end of group CM3MCU_CMSIS */

//CMSIS Cortex-M3 Core Peripheral Access Layer Header File
#include "core_cm3.h"                     /* Cortex-M3 processor and core peripherals           */
#include "system_cm3_mcu.h"               /* CM3 MCU example System include file                 */



/******************************************************************************/
/*                Device Specific Peripheral registers structures             */
/******************************************************************************/
/** @addtogroup CM3MCU_Peripherals CM3MCU_CM3 Peripherals
  CM3MCU_CM3 Device Specific Peripheral registers structures
  @{
*/

#if defined ( __CC_ARM   )
#pragma anon_unions
#endif

/*------------- General Purpose Input/Output (GPIO) -----------*/
/** @addtogroup GPIO
  memory mapped structure for GPIO
  @{
*/

//!annotation
/*
*__I & __IO are Macros
* #define   __I     volatile const
* #define   __IO    volatile 
*/
typedef struct
{
  __I    uint32_t  DATAIN;        /*!< Offset: 0x000 DataIn Register  (R/ ) */
  __IO   uint32_t  DATAOUT;       /*!< Offset: 0x004 DataOut Register (R/W) */
  __IO   uint32_t  OUTEN;         /*!< Offset: 0x008 Output Enable Register  (R/W) */
  __IO   uint32_t  IRQEN;         /*!< Offset: 0x00C Interrupt Enable Register  (R/W) */
  __IO   uint32_t  IRQTYPE;       /*!< Offset: 0x010 Interrupt Type Register  (R/W) */
  __IO   uint32_t  IRQPOLARITY;   /*!< Offset: 0x014 Interrupt Polarity Register  (R/W) */
  __IO   uint32_t  IRQSTATE;      /*!< Offset: 0x018 Interrupt Status Register  (R/Wc) */
} CM3MCU_GPIO_TypeDef;

/* CM3MCU_GPIO DATA Register Definitions */

#define CM3MCU_GPIO_DATAIN_Pos       0                                      /*!< CM3MCU_GPIO_DATAIN_Pos: DATAIN Position */
#define CM3MCU_GPIO_DATAIN_Msk       (0xFFul << CM3MCU_GPIO_DATAIN_Pos)     /*!< CM3MCU_GPIO DATAIN : DATAIN Mask */
#define CM3MCU_GPIO_DATAOUT_Pos      0                                      /*!< CM3MCU_GPIO_DATAOUT_Pos: DATAOUT Position */
#define CM3MCU_GPIO_DATAOUT_Msk      (0xFFul << CM3MCU_GPIO_DATAOUT_Pos)    /*!< CM3MCU_GPIO DATAOUT : DATAOUT Mask */
#define CM3MCU_GPIO_OUTEN_Pos        0                                      /*!< CM3MCU_GPIO_OUTEN_Pos: OUTEN Position */
#define CM3MCU_GPIO_OUTEN_Msk        (0xFFul << CM3MCU_GPIO_OUTEN_Pos)      /*!< CM3MCU_GPIO OUTEN : Output Enable Mask */
#define CM3MCU_GPIO_IRQEN_Pos        0                                      /*!< CM3MCU_GPIO_IRQEN_Pos: IRQEN Position */
#define CM3MCU_GPIO_IRQEN_Msk        (0xFFul << CM3MCU_GPIO_IRQEN_Pos)      /*!< CM3MCU_GPIO IRQEN : Interrupt Enable Mask */
#define CM3MCU_GPIO_IRQTYPE_Pos      0                                      /*!< CM3MCU_GPIO_IRQTYPE_Pos: IRQTYPE Position */
#define CM3MCU_GPIO_IRQTYPE_Msk      (0xFFul << CM3MCU_GPIO_IRQTYPE_Pos)    /*!< CM3MCU_GPIO IRQTYPE : Interrupt Type Mask */
#define CM3MCU_GPIO_IRQPOLARITY_Pos  0                                      /*!< CM3MCU_GPIO_IRQPOLARITY_Pos: IRQPOLARITY Position */
#define CM3MCU_GPIO_IRQPOLARITY_Msk  (0xFFul << CM3MCU_GPIO_IRQPOLARITY_Pos)/*!< CM3MCU_GPIO IRQPOLARITY : Interrupt Polarity Mask */
#define CM3MCU_GPIO_IRQSTATE_Pos     0                                      /*!< CM3MCU_GPIO_IRQSTATE_Pos: IRQSTATE Position */
#define CM3MCU_GPIO_IRQSTATE_Msk     (0xFFul << CM3MCU_GPIO_IRQSTATE_Pos)   /*!< CM3MCU_GPIO IRQSTATE : Interrupt Status Mask */


/*@}*/ /* end of group GPIO */

/*------------- Timer (Timer) -----------*/
/** @addtogroup Timer
  memory mapped structure for Timer
  @{
*/
typedef struct
{
  __IO   uint32_t  CTRL;          /*!< Offset: 0x000 Control Register  (R/ ) */
  __IO   uint32_t  CURRVAL;       /*!< Offset: 0x004 Current Value Register (R/W) */
  __IO   uint32_t  RELOAD;        /*!< Offset: 0x008 Reload Value Register  (R/W) */
  __IO   uint32_t  IRQSTATE;      /*!< Offset: 0x00C Interrupt State Register  (R/Wc) */
} CM3MCU_TIMER_TypeDef;

#define CM3MCU_TIMER_CTRL_EN_pos        0                                         /*!< CM3MCU_TIMER_CTRL_EN_Pos: Enable Position */
#define CM3MCU_TIMER_CTRL_EN_Msk        (0x1ul << CM3MCU_TIMER_CTRL_EN_pos)       /*!< CM3MCU_TIMER ENABLE : Timer Enable Mask */
#define CM3MCU_TIMER_CTRL_ExtENSel_pos  1                                         /*!< CM3MCU_TIMER_CTRL_ExtENSel_Pos: Ext Enable Sel Position */
#define CM3MCU_TIMER_CTRL_ExtENSel_Msk  (0x1ul << CM3MCU_TIMER_CTRL_ExtENSel_pos) /*!< CM3MCU_TIMER ExtENSel : Timer Ext Enable Sel Mask */
#define CM3MCU_TIMER_CTRL_ExtClkSel_pos 2                                         /*!< CM3MCU_TIMER_CTRL_ExtClkSel_Pos: Ext Ckock select Position */
#define CM3MCU_TIMER_CTRL_ExtClkSel_Msk (0x1ul << CM3MCU_TIMER_CTRL_EN_pos)       /*!< CM3MCU_TIMER ExtClkSel : Timer Ext Ckock select Mask */
#define CM3MCU_TIMER_CTRL_IRQEN_pos     3                                         /*!< CM3MCU_TIMER_CTRL_IRQEN_Pos: IRQ Enable Position */
#define CM3MCU_TIMER_CTRL_IRQEN_Msk     (0x1ul << CM3MCU_TIMER_CTRL_IRQEN_pos)    /*!< CM3MCU_TIMER ENABLE : Timer IRQ Enable Mask */
#define CM3MCU_TIMER_CURRVAL_pos        0                                         /*!< CM3MCU_TIMER_CURRVAL_pos: Current Value Position */
#define CM3MCU_TIMER_CURRVAL_Msk        (0xFFFFFFFFul << CM3MCU_TIMER_CURRVAL_pos)/*!< CM3MCU_TIMER CURRVAL : Current Value Mask */
#define CM3MCU_TIMER_RELOAD_pos         0                                         /*!< CM3MCU_TIMER_RELOAD_pos: Reload Value Position */
#define CM3MCU_TIMER_RELOAD_Msk         (0xFFFFFFFFul << CM3MCU_TIMER_RELOAD_pos) /*!< CM3MCU_TIMER RELOAD : Reload Value Mask */
#define CM3MCU_TIMER_IRQSTATE_pos       0                                         /*!< CM3MCU_TIMER_IRQSTATE_pos: IRQSTATE Position */
#define CM3MCU_TIMER_IRQSTATE_Msk       (0x1ul << CM3MCU_TIMER_IRQSTATE_pos)      /*!< CM3MCU_TIMER IRQSTATE : IRQ Status Mask */

/*@}*/ /* end of group  Timer */

/*------------- UART (UART) -----------*/
/** @addtogroup UART
  memory mapped structure for UART
  @{
*/
typedef struct
{
  __IO   uint32_t  CTRL;          /*!< Offset: 0x000 Control Register  (R/ ) */
  __IO   uint32_t  STATE;         /*!< Offset: 0x004 Status Register (R/W) */
  __IO   uint32_t  TXD;           /*!< Offset: 0x008 TXDATA/Status Register  (R/W) */
  __I    uint32_t  RXD;           /*!< Offset: 0x00C RXDATA Register  (R/W) */
  __IO   uint32_t  BAUDDIV;       /*!< Offset: 0x010 Baudrate Divider Register  (R/W) */
  __IO   uint32_t  IRQSTATE;      /*!< Offset: 0x014 Interrupt State Register  (R/Wc) */
} CM3MCU_UART_TypeDef;

#define CM3MCU_UART_CTRL_TXEN_pos      0                                         /*!< CM3MCU_UART_CTRL_TXEN_Pos: TXEN Position */
#define CM3MCU_UART_CTRL_TXEN_Msk      (0x1ul << CM3MCU_UART_CTRL_TXEN_pos)      /*!< CM3MCU_UART TXEN: UART TX Enable Mask */
#define CM3MCU_UART_CTRL_RXEN_pos      1                                         /*!< CM3MCU_UART_CTRL_RXEN_Pos: RXEN Position */
#define CM3MCU_UART_CTRL_RXEN_Msk      (0x1ul << CM3MCU_UART_CTRL_RXEN_pos)      /*!< CM3MCU_UART RXEN: UART RX Enable Mask */
#define CM3MCU_UART_CTRL_TXIRQEN_pos   2                                         /*!< CM3MCU_UART_CTRL_TXIRQEN_Pos: TXIRQEN Position */
#define CM3MCU_UART_CTRL_TXIRQEN_Msk   (0x1ul << CM3MCU_UART_CTRL_TXIRQEN_pos)   /*!< CM3MCU_UART TXIRQEN: UART TX IRQ Enable Mask */
#define CM3MCU_UART_CTRL_RXIRQEN_pos   3                                         /*!< CM3MCU_UART_CTRL_RXIRQEN_Pos: RXIRQEN Position */
#define CM3MCU_UART_CTRL_RXIRQEN_Msk   (0x1ul << CM3MCU_UART_CTRL_RXIRQEN_pos)   /*!< CM3MCU_UART RXIRQEN: UART RX IRQ Enable Mask */
#define CM3MCU_UART_STATE_TXFULL_pos   0                                        /*!< CM3MCU_UART_CTRL_TXFULL_Pos: TXFULL Position */
#define CM3MCU_UART_STATE_TXFULL_Msk   (0x1ul << CM3MCU_UART_STATE_TXFULL_pos)   /*!< CM3MCU_UART TXFULL: UART TX FULL Mask */
#define CM3MCU_UART_STATE_RXFULL_pos   1                                        /*!< CM3MCU_UART_CTRL_RXFULL_Pos: RXFULL Position */
#define CM3MCU_UART_STATE_RXFULL_Msk   (0x1ul << CM3MCU_UART_STATE_RXFULL_pos)   /*!< CM3MCU_UART RXFULL: UART RX FULL Mask */
#define CM3MCU_UART_STATE_TXOVR_pos    2                                        /*!< CM3MCU_UART_CTRL_TXOVR_Pos: TXOVR Position */
#define CM3MCU_UART_STATE_TXOVR_Msk    (0x1ul << CM3MCU_UART_STATE_TXOVR_pos)    /*!< CM3MCU_UART TXOVR: UART TX Overrun Mask */
#define CM3MCU_UART_STATE_RXOVR_pos    3                                        /*!< CM3MCU_UART_CTRL_RXOVR_Pos: RXOVR Position */
#define CM3MCU_UART_STATE_RXOVR_Msk    (0x1ul << CM3MCU_UART_STATE_RXOVR_pos)    /*!< CM3MCU_UART RXOVR: UART RX Overrun Mask */
#define CM3MCU_UART_TXD_pos            0                                         /*!< CM3MCU_UART_TXD_pos: TXD Position */
#define CM3MCU_UART_TXD_Msk            (0xFFul << CM3MCU_UART_TXD_pos)           /*!< CM3MCU_UART TXD : TX data Mask */
#define CM3MCU_UART_RXD_pos            0                                         /*!< CM3MCU_UART_RXD_pos: RXD Position */
#define CM3MCU_UART_RXD_Msk            (0xFFul << CM3MCU_UART_RXD_pos)           /*!< CM3MCU_UART RXD : RX data Mask */
#define CM3MCU_UART_BAUDDIV_pos        0                                         /*!< CM3MCU_UART_BAUDDIV_pos: BAUDDIV Position */
#define CM3MCU_UART_BAUDDIV_Msk        (0xFFFFFul << CM3MCU_UART_BAUDDIV_pos)    /*!< CM3MCU_UART BAUDDIV : Baud rate divider Mask */
#define CM3MCU_UART_IRQSTATE_RX_pos    0                                         /*!< CM3MCU_UART_IRQSTATE_RX_pos: IRQSTATE.RX Position */
#define CM3MCU_UART_IRQSTATE_RX_Msk    (0x1ul << CM3MCU_UART_IRQSTATE_RX_pos)    /*!< CM3MCU_UART IRQSTATE_RX : RX IRQ Status Mask */
#define CM3MCU_UART_IRQSTATE_TX_pos    1                                         /*!< CM3MCU_UART_IRQSTATE_TX_pos: IRQSTATE.TX Position */
#define CM3MCU_UART_IRQSTATE_TX_Msk    (0x1ul << CM3MCU_UART_IRQSTATE_TX_pos)    /*!< CM3MCU_UART IRQSTATE_TX : TX IRQ Status Mask */

/*@}*/ /* end of group  UART */

//{ADC @Chuanghao Zhang
typedef struct
{
  __IO   uint32_t  CFG;         /*!< Offset: 0x000 (R/W) */
  __IO   uint32_t  DIV;         /*!< Offset: 0x004 (R/W) */
  __I    uint32_t  DAT;         /*!< Offset: 0x008  (RO) */
  __IO   uint32_t  INT;         /*!< Offset: 0x00C Interrupt State Register  (R/Wc) */
} CM3MCU_ADC_TypeDef;
//}

//{f2f - window - FFT - abs - power} @Chuanghao Zhang
typedef struct
{
  __IO   uint32_t  CFG;         /*!< Offset: 0x000 (R/W) */
  __IO   uint32_t  CTL;         /*!< Offset: 0x004 (R/W) */
  __IO   int  DIN;         /*!< Offset: 0x008  (WO) */
  __I    float  DOUT;         /*!< Offset: 0x00C Interrupt State Register  (RO) */
} CM3MCU_FFT_TypeDef;
//}

//{MAC} @Chuanghao Zhang
typedef struct
{
  __O   float  DATINA;         /*!< Offset: 0x000 (WO) */
  __O   float  DATINB;         /*!< Offset: 0x004 (WO) */
  __I   float  DOUT;           /*!< Offset: 0x008  (RO) */
} CM3MCU_MAC_TypeDef;
//}

//{LOG} @Chuanghao Zhang
typedef struct
{
  __O   float  DATIN;         /*!< Offset: 0x000 (WO) */
  __I   float  DOUT;          /*!< Offset: 0x004 (RO) */
} CM3MCU_LOG_TypeDef;
//}


#if defined ( __CC_ARM   )
#pragma no_anon_unions
#endif

/*@}*/ /* end of group CM3MCU_Peripherals */


/******************************************************************************/
/*                         Peripheral memory map                              */
/******************************************************************************/
/** @addtogroup CM3MCU_MemoryMap CM3MCU Memory Mapping
  @{
*/

/* Peripheral and SRAM base address */
#define CM3MCU_FLASH_BASE        (0x00000000UL)  /*!< (FLASH     ) Base Address */
#define CM3MCU_SRAM_BASE         (0x20000000UL)  /*!< (SRAM      ) Base Address */
#define CM3MCU_PERIPH_BASE       (0x40000000UL)  /*!< (Peripheral) Base Address */
#define CM3MCU_RAM_BASE          (0x20000000UL)

/* APB peripherals                                                           */
#define CM3MCU_GPIO0_BASE        (CM3MCU_PERIPH_BASE + 0x0000UL)
#define CM3MCU_GPIO1_BASE        (CM3MCU_PERIPH_BASE + 0x1000UL)
#define CM3MCU_TIMER0_BASE       (CM3MCU_PERIPH_BASE + 0x2000UL)
#define CM3MCU_TIMER1_BASE       (CM3MCU_PERIPH_BASE + 0x3000UL)
#define CM3MCU_UART0_BASE        (CM3MCU_PERIPH_BASE + 0x4000UL)

//{   @Chuanghao Zhang 
#define CM3MCU_ADC_BASE       					 (0x40010000UL)
#define CM3MCU_FFT_BASE       					 (0x40020000UL)
#define CM3MCU_MAC0_BASE       					 (0x40030000UL)
#define CM3MCU_MAC1_BASE       					 (0x40040000UL)
#define CM3MCU_LOG_BASE       					 (0x40050000UL)
//}


/*@}*/ /* end of group CM3MCU_MemoryMap */


/******************************************************************************/
/*                         Peripheral declaration                             */
/******************************************************************************/
/** @addtogroup CM3MCU_PeripheralDecl CM3MCU_CM3 Peripheral Declaration
  @{
*/

#define CM3MCU_GPIO0             ((CM3MCU_GPIO_TypeDef   *) CM3MCU_GPIO0_BASE )
#define CM3MCU_GPIO1             ((CM3MCU_GPIO_TypeDef   *) CM3MCU_GPIO1_BASE )
#define CM3MCU_TIMER0            ((CM3MCU_TIMER_TypeDef  *) CM3MCU_TIMER0_BASE )
#define CM3MCU_TIMER1            ((CM3MCU_TIMER_TypeDef  *) CM3MCU_TIMER1_BASE )
//{ @Chuanghao Zhang
#define CM3MCU_UART0             ((CM3MCU_UART_TypeDef   *) CM3MCU_UART0_BASE )
//}
#define CM3MCU_ADC	             ((CM3MCU_ADC_TypeDef    *) CM3MCU_ADC_BASE )
#define CM3MCU_FFT	             ((CM3MCU_FFT_TypeDef    *) CM3MCU_FFT_BASE )
#define CM3MCU_MAC0	             ((CM3MCU_MAC_TypeDef    *) CM3MCU_MAC0_BASE )
#define CM3MCU_MAC1	             ((CM3MCU_MAC_TypeDef    *) CM3MCU_MAC1_BASE )
#define CM3MCU_LOG	             ((CM3MCU_LOG_TypeDef    *) CM3MCU_LOG_BASE )
/*@}*/ /* end of group CM3MCU_PeripheralDecl */

/*@}*/ /* end of group CM3MCU_Definitions */

#ifdef __cplusplus
}
#endif

#endif  /* CM3MCU_CM3_H */

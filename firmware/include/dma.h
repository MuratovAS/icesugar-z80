#ifndef __DMA_H
#define __DMA_H

#include <stdint.h>
#include <stdbool.h>

typedef enum
{
    CONF_IOA    = 0b00000001,
    CONF_IOB    = 0b00000010,
    CONF_LOOP   = 0b00000100,
    CONF_FLAG   = 0b00001000,
    CONF_EN     = 0b00010000,
    CONF_RST    = 0b00100000
}CONF_BIT;

typedef enum
{
    MEM   = 0,
    IO    = 1
}TYPE_BUS;

bool dma_read(CONF_BIT addr);
void dma_cmd(CONF_BIT cmd, bool state);
void dma_confA(TYPE_BUS bus, uint16_t addr, uint8_t len);
void dma_confB(TYPE_BUS bus, uint16_t addr, uint8_t len);

#endif

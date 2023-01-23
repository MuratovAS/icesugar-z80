#include "icez0mb1e.h"
#include "dma.h"

bool dma_read(CONF_BIT addr)
{
    return dma_conf & addr;
}

void dma_cmd(CONF_BIT cmd, bool state)
{
    if (state == true)
        dma_conf |= cmd; //установить бит
    else
        dma_conf &= ~cmd; //сбростить бит
}

void dma_confA(TYPE_BUS bus, uint16_t addr, uint8_t len)
{
    if (bus == IO)
        dma_conf |= CONF_IOA;
    else
        dma_conf &= ~CONF_IOA;

    dma_lenA = len;

    dma_addAL = addr;
    dma_addAH = addr>>8;
}

void dma_confB(TYPE_BUS bus, uint16_t addr, uint8_t len)
{
    if (bus == IO)
        dma_conf |= CONF_IOB;
    else
        dma_conf &= ~CONF_IOB;

    dma_lenB = len;

    dma_addBL = addr;
    dma_addBH = addr>>8;
}

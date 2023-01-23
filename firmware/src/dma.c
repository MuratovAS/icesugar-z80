//
// icesugar-z80 for TV80 SoC for Lattice iCE40
//
// Copyright (c) 2022 Aleksej Muratov
//
// Permission is hereby granted, free of charge, to any person obtaining a 
// copy of this software and associated documentation files (the "Software"), 
// to deal in the Software without restriction, including without limitation 
// the rights to use, copy, modify, merge, publish, distribute, sublicense, 
// and/or sell copies of the Software, and to permit persons to whom the 
// Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included 
// in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, 
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
// IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY 
// CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, 
// TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE 
// SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#include "main.h"
#include "dma.h"

bool dma_read(CONF_BIT addr)
{
    return dma_conf & addr;
}

void dma_cmd(CONF_BIT cmd, bool state)
{
    if (state == true)
        dma_conf |= cmd; //set the bit
    else
        dma_conf &= ~cmd; //reset the bit
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

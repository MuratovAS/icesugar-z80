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

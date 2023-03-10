//
// iceZ0mb1e - FPGA 8-Bit TV80 SoC for Lattice iCE40
// with complete open-source toolchain flow using yosys and SDCC
//
// Copyright (c) 2018 Franz Neumann (netinside2000@gmx.de)
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

#include <stdint.h>
#include "cpu.h"

void cpu_reset()
{
__asm
    jp 0x0000
__endasm;
}

void cpu_nop()
{
__asm
    nop
__endasm;
}

void cpu_ei()
{
__asm
    ei
__endasm;
}

void cpu_di()
{
__asm
    di
__endasm;
}

void cpu_im(uint8_t p)
{
    switch (p) {
    case 0:
        __asm
            im 0
        __endasm;
        break;
    case 1:
        __asm
            im 1
        __endasm;
        break;
    case 2:
        __asm
            im 2
        __endasm;
        break;
    default:
        __asm
            im 1
        __endasm;
    }
}


void delay(uint16_t t)
{
    uint16_t i;
    for(i = 0; i < t; i++)
    {
        __asm
            nop
        __endasm;
    }
}
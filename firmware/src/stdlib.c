//
// stdlib for TV80 SoC for Lattice iCE40
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
#include "uart.h"

void printBits(unsigned int size, unsigned int ptr)
{
    unsigned int *b = &ptr;
    unsigned int byte;
    int i, j;
    
    snprintf(strbuf, sizeof(strbuf), "0b", byte);
    uart_write(strbuf);

    for (i = size-1; i >= 0; i--) {
        for (j = 7; j >= 0; j--) {
            byte = (b[i] >> j) & 1;
            snprintf(strbuf, sizeof(strbuf), "%u", byte);
            uart_write(strbuf);
        }
    }
}

void viewMemory(uint8_t *mem, uint16_t len)
{
    uint16_t x;

    for(x = 0; x < len; x++)
    {
        if((x%16) == 0)
        {
            snprintf(strbuf, sizeof(strbuf), "\r\n%04X: ", x);
            uart_write(strbuf);
        }
        snprintf(strbuf, sizeof(strbuf), "%02X", mem[x]);
        uart_write(strbuf);
    }

    snprintf(strbuf, sizeof(strbuf), "\r\n");
    uart_write(strbuf);
}
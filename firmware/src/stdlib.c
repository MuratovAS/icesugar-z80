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

void View_Memory(uint8_t *mem, uint16_t len)
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
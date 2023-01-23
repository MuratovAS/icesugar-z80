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

module simpleirq (
    input clk,
    input m1_n,
    input en_n,
    output int_n,
    output[7:0] data_out,
    input[7:0] irq
);
    reg[7:0] vector;

    assign int_n = !(irq[0] | irq[1] | irq[2] | irq[3] | irq[5] | irq[6] | irq[7]);
    assign data_out = (!en_n) ? vector : 8'h0;

    always @(irq)
	begin
        casex(irq)
            // rst 0x00 .. 0x30
            8'b1xxxxxxx : vector <= 8'b11111111; //irq0 low priority
            8'bx1xxxxxx : vector <= 8'b11110111; //irq1
            8'bxx1xxxxx : vector <= 8'b11101111; //irq2
            8'bxxx1xxxx : vector <= 8'b11100111; //irq3
            8'bxxxx1xxx : vector <= 8'b11011111; //irq4
            8'bxxxxx1xx : vector <= 8'b11010111; //irq5
            8'bxxxxxx1x : vector <= 8'b11001111; //irq6
            8'bxxxxxxx1 : vector <= 8'b11000111; //irq7 top priority
            default : vector <= 8'hFF;
        endcase
	end

endmodule

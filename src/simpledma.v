//
// simpledma for TV80 SoC for Lattice iCE40
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

module simpledma (
    input clk,
    input cs_n,
    input reset_n,
    
    input busak_n,
    output busrq_n,
    
    input[7:0] data_in,
    output[7:0] data_out,
    output[15:0] addr_out,

    output iorq_n,
    output mreq_n,
    output rd_n,
    output wr_n,
    output[7:0] debug
);
    reg[7:0] data;
    reg[15:0] addr;

    reg iorq = 1'b1;
    reg mreq = 1'b1;
    reg rd   = 1'b1;
    reg wr   = 1'b1;
    
    assign busrq_n  = ~(!cs_n);

    //assign debug  = addr_out;

    wire permission;
    assign permission = !cs_n && !busak_n;

    assign iorq_n   = permission ? iorq : 1'b1;
    assign mreq_n   = permission ? mreq : 1'b1;
    assign rd_n     = permission ? rd : 1'b1;
    assign wr_n     = permission ? wr : 1'b1;
    
    assign data_out = permission ? data : 8'h0;
    assign addr_out = permission ? addr : 16'h0;

    reg[7:0] tmp;
    reg[7:0] n;
        always @(posedge clk)
	begin
        if(permission)
        begin
            mreq <= 1'b1;
            case(n)
            0: data <= 16'h0201;
            1: addr <= 16'h0201;

            3: data <= 16'h0200;
            4: addr <= 16'h0200;
            
             /*0 : addr <= 16'h0201;
             10 : rd <= 1'b1; 
             20 : tmp <= data_in;
             30 : rd <= 1'b0;
             40 : addr <= 16'h01F0;
             50 : data <= tmp;
             60 : wr <= 1'b1;*/
            endcase
            n <= n + 1;
        end
	end

    /*assign debug  = n;
 
    assign busrq_n  = ~(!cs_n);
    assign permission = !busrq_n && !busak_n && reset_n;
    
    assign iorq_n   = permission ? iorq : 1'b1;
    assign mreq_n   = permission ? mreq : 1'b1;
    assign rd_n     = permission ? rd : 1'b1;
    assign wr_n     = permission ? wr : 1'b1;

    assign data_out = permission ? data : 8'h0;
    assign addr_out = permission ? addr : 16'h0;

    reg [7:0] n = 8'b0;
    always @(posedge clk)
	begin
        if(permission)
        begin
            //mreq <= 1'b1;
            // case(n)
            // 0 : addr <= 16'h0200;
            // 10 : rd <= 1'b1; 
            // 20 : tmp <= data_in;
            // 30 : rd <= 1'b0;
            // 40 : addr <= 16'h01F0;
            // 50 : data <= tmp;
            // 60 : wr <= 1'b1;
            // endcase
            n <= n + 1;
        end
	end
*/
endmodule

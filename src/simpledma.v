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
    input reset_n,
    //input en_n,
    //output[7:0] data_cfg_out,
    //input[7:0] data_cfg_in,
    
    input busak_n,
    output busrq_n,
    

    input en_n,
    output[7:0] data_out,
    input[7:0] data_in,
    output[15:0] addr_out,

    output iorq_n,
    output mreq_n,
    output rd_n,
    output wr_n,
    output[7:0] debug
);
    reg[7:0] data;
    reg[15:0] addr;

    reg iorq = 1'b0;
    reg mreq = 1'b0;
    reg rd   = 1'b0;
    reg wr   = 1'b0;
    
    //FIXME:
    assign busrq_n  = ~(!en_n);
    assign debug = tmp;

    wire permission;
    assign permission = !en_n && !busak_n;

    assign iorq_n   = permission ? ~iorq : 1'b1;
    assign mreq_n   = permission ? ~mreq : 1'b1;
    assign rd_n     = permission ? ~rd : 1'b1;
    assign wr_n     = permission ? ~wr : 1'b1;
    
    assign data_out = permission && rd_n && !wr_n ? data : 8'h0;
    assign addr_out = permission && (!rd_n || !wr_n) ? addr : 16'h0;

    reg[7:0] tmp;
    reg[7:0] n;
        always @(posedge clk)
	begin
        if(permission)
        begin
            case(n)
             0 : iorq <= 1'b1;
             1 : addr <= 16'b0000000001000000;
             2 : data <= 8'h02;
             3 : wr <= 1'b1;
             4 : wr <= 1'b0;
             5 : iorq <= 1'b0;
            endcase
            n <= n + 1;
        end
	end

endmodule

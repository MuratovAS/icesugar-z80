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
    //input cs_n,
    //output[7:0] data_cfg_out,
    //input[7:0] data_cfg_in,
    
    input busak_n,
    output busrq_n,
    output flag_n,
    

    input trig_n,
    output[7:0] data_out,
    input[7:0] data_in,
    output[15:0] addr_out,

    output iorq_n,
    output mreq_n,
    output rd_n,
    output wr_n,
    output[7:0] debug
);
    `define TRUE 1'b1
    `define FALSE 1'b0

    reg flag_n = `TRUE;
    reg[7:0] data;
    reg[15:0] addr;

    reg iorq = `FALSE;
    reg mreq = `FALSE;
    reg rd   = `FALSE;
    reg wr   = `FALSE;

    reg mutex = `FALSE;

    assign busrq_n  = ~(!trig_n || mutex);
    assign debug = flag_n;

    wire permission;
    assign permission = !busrq_n && !busak_n;

    assign iorq_n   = permission ? ~iorq : `TRUE;
    assign mreq_n   = permission ? ~mreq : `TRUE;
    assign rd_n     = permission ? ~rd : `TRUE;
    assign wr_n     = permission ? ~wr : `TRUE;
    
    assign data_out = permission && rd_n && !wr_n ? data : 8'h0;
    assign addr_out = permission && (!rd_n || !wr_n) ? addr : 16'h0;

    //// Configuration - Status - Command
    reg[7:0] conf = 8'b00011000; //0dKGFEDCBA
    `define CONF_IOA    conf[0]
    `define CONF_IOB    conf[1]
    `define CONF_LOOP   conf[2]
    `define CONF_FLAG   conf[3]
    `define CONF_EN     conf[4]
    `define CONF_RST    conf[5]
    // conf[A] - 0 - RW - (0)mreq/(1)iorq for Port A
    // conf[B] - 1 - RW - (0)mreq/(1)iorq for Port B
    // conf[C] - 2 - RW - (0)single/(1)loop
    // conf[E] - 3 - WR  - (0)disable/(1)enable flag
    // conf[D] - 4 - RW - (0)disable/(1)enable dma
    // conf[E] - 5 - W  - reset

    reg[7:0] lenA = 8'd0; //+1
    reg[7:0] lenB = 8'd0; //+1
    // lenA[] - length for Port A (byte)
    // lenB[] - length for Port B (byte)

    reg[15:0] addA = 16'h8010;
    reg[15:0] addB = 16'h8100;
    // addA[][] - address for Port A
    // addB[][] - address for Port B

    //// Sys private
    reg[7:0] buff;
    reg[7:0] i = 8'd0;
    reg[7:0] incrementA = 8'd0;
    reg[7:0] incrementB = 8'd0;

    always @(posedge clk)
	begin
        if (`CONF_RST)
        begin 
            `CONF_EN <= `FALSE;
            `CONF_RST <= `FALSE;
            if (!`CONF_EN)
                flag_n = `TRUE;
            i <= 8'd0;
            incrementA <= 8'd0;
            incrementB <= 8'd0;
        end

        if(permission)
        begin
            if(`CONF_EN)
            begin
                if (`CONF_FLAG)
                    flag_n <= `TRUE;

                case(i)
                8'd0 : mutex <= `TRUE;
                /////// Read A
                8'd1 : begin 
                        if (`CONF_IOA == `TRUE)
                            iorq <= `TRUE;
                        else
                            mreq <= `TRUE;
                        end
                8'd2 : addr <= addA + incrementA;
                8'd3 : rd <= `TRUE;
                //8'd4 :
                8'd5 : buff <= data_in;
                6: rd <= `FALSE;
                8'd7 : begin 
                        if (`CONF_IOA == `TRUE)
                            iorq <= `FALSE;
                        else
                            mreq <= `FALSE;
                        end
                /////// Write B
                8'd10 : begin 
                        if (`CONF_IOB == `TRUE)
                            iorq <= `TRUE;
                        else
                            mreq <= `TRUE;
                        end
                8'd11 : addr <= addB + incrementB;
                8'd12 : data <= buff;
                8'd13 : wr <= `TRUE;
                8'd14 : wr <= `FALSE;
                8'd15 : begin 
                        if (`CONF_IOB == `TRUE)
                            iorq <= `FALSE;
                        else
                            mreq <= `FALSE;
                        end
                8'd16 :  mutex <= `FALSE;
                endcase
                /////// iterator
                if (i < 8'd16)
                    i <= i + 8'd1;
                else
                begin
                    i <= 8'd0;

                    // increments
                    if (incrementA < lenA)
                        incrementA <= incrementA + 8'd1;
                    else
                        incrementA <= 8'd0;

                    if (incrementB < lenB)
                        incrementB <= incrementB + 8'd1;
                    else
                        incrementB <= 8'd0;

                    // single/loop
                    if (lenA == lenB)
                    begin
                        if (incrementA == lenA)
                            exit_i();
                    end
                    else
                        if (lenA > lenB)
                        begin
                            if (!(incrementA < lenA)) //loop check
                                exit_i();
                        end
                        else
                        begin
                            if (!(incrementB < lenB))//loop check
                                exit_i();
                        end
                end
            end
        end
	end

    task exit_i;
    begin
        if (`CONF_FLAG)
            flag_n <= `FALSE;
        if (`CONF_LOOP == `FALSE)
        begin
            `CONF_RST <= `TRUE;
            `CONF_EN <= `FALSE;
        end
    end
    endtask

endmodule

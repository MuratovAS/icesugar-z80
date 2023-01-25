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

module simplewdt (
    input clk,
    input reset_n,
    input pause_n,
    output[7:0] data_out,
    input[7:0] data_in,
    input cs_n,
    input rd_n,
    input wr_n,
    input[1:0] addr,
    output reset
);
    reg reset;

    reg[7:0] comparator;
    reg[7:0] divider;
    reg[7:0] counter;
    reg[7:0] counter_divider;

    wire write_sel = !cs_n & rd_n & !wr_n;
    //wire read_sel = !cs_n & !rd_n & wr_n;
    
    //reg[7:0] read_data;
	//assign data_out = (read_sel) ? read_data : 8'b0;
	assign data_out = 8'h00;

    /*always @(*)
	begin
		case(addr)
			2'b00 : read_data <= comparator;
			2'b01 : read_data <= divider;
			2'b10 : read_data <= counter;
			default : read_data <= 8'h00;
		endcase
	end*/

    always @(posedge clk)
    begin
        if (write_sel) begin
            case(addr)
                2'b00 : comparator <= data_in;
                2'b01 : divider <= data_in;
                2'b10 : counter <= data_in;
            endcase
        end
        else
        begin
            if (!reset_n)
            begin
                reset <= 1'b0;
                counter  <= 8'b0;
                comparator <= 8'h0;
                counter_divider  <= 8'b1;
            end
            else
                if (pause_n && comparator != 1'b0)
                    if (counter_divider < divider)
                        counter_divider <= counter_divider + 1'b1;
                    else
                    begin
                        counter_divider <= 8'b1;
                        counter <= counter + 1'b1;
                        if (counter >= comparator)
                        begin
                            reset <= 1'b1;
                            counter <= 8'h0;
                            comparator <= 8'h0;
                        end
                    end
        end
    end
endmodule

module reg_file(clk, write_en, read_addr1, read_addr2, write_data, write_addr, reg1, reg2);

parameter depth = 32; // # of addressable locations in memory 
parameter width = 32; // word size, note: depth * width = capacity = 32b x 32b
parameter addr_bits = 5;

input [addr_bits-1:0] read_addr1, read_addr2, write_addr; // 5-bit addresses for 32 registers 
input [width-1:0] write_data; // one write port on RV32I register file 
input write_en, clk; // write enable and clock signal for synchronous write 
output [width-1:0] reg1, reg2; // two read ports on RV32I register file 

reg [width-1:0] reg_filex [depth-1:0];

integer i;
initial begin
    for (i = 0; i < depth; i = i + 1)
        reg_filex[i] = 0;
end

always @(posedge clk) // positive-edge triggered 
begin 
    if(write_en && write_addr != 0) // RISC-V architecture states x0 is hardwired to 0
        begin
        reg_filex[write_addr] <= write_data;
        end
end

assign reg1 = reg_filex[read_addr1]; 
assign reg2 = reg_filex[read_addr2];

endmodule 

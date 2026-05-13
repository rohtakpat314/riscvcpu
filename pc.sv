module pc(pc_in, pc_out, clk, rst);

parameter addr_length = 32; // 32-bit address

input [addr_length-1:0] pc_in; 
output reg [addr_length-1:0] pc_out;

always @(posedge clk) begin
    if (rst) 
        pc_out <= 32'h00000000; // if reset, reset PC to x0000 
    else 
        pc_out <= pc_in; // program counter out = program counter in at end of cycle
end

endmodule

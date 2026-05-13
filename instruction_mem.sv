module instruction_mem(clk, pc, instruction);

parameter instr_length = 32;
parameter pc_length = 32;

input [pc_length-1:0] pc; 
output [instr_length-1:0] instruction; 

reg [31:0] memory [0:1023]; // memory is 32x32 = 1024

initial begin
    $readmemh("program.hex", memory); // read a hex file and load it into memory 
end

assign instr = memory[pc[11:2]]; // since depth = 1024, 2^10 = 1024, so [11:2] is sufficient 

endmodule 

module alu(a, b, ALU_control, result, zero, overflow, lt, cout);

parameter data_width = 32; 

input [data_width-1:0] a, b; 
output reg [data_width-1:0] result; 
input [3:0] ALU_control;
output zero, overflow, lt, cout; // either 1 or 0 (true or false) for each 
reg carry; 


// use the funct3 for bits [2:0], eliminating the need for a second decoding stage for ALU operation selection 

localparam ADD = 4'b0000;
localparam SUB = 4'b1000;
localparam SLL = 4'b0001;
localparam SLT = 4'b0010;
localparam SLTU = 4'b0011;
localparam XOR = 4'b0100;
localparam SRL = 4'b0101;
localparam SRA = 4'b1101;
localparam OR = 4'b0110;
localparam AND = 4'b0111;


always @(*) begin
    result = 0;
    carry = 0;
    case(ALU_control) 
        ADD: {carry, result} = {1'b0, a} + {1'b0, b}; // zero-extend the a & b values to support 33-bit addition & make use of the carry bit 
        SUB: result = a - b;
        OR: result = a | b;
        AND: result = a & b; 
        XOR: result = a ^ b;
        SLL: result = a << b[4:0]; // << point to the left indicate SL 
        SRL: result = a >> b[4:0];
        SRA: result = $signed(a) >>> b[4:0];
        SLTU: result = (a < b) ? 32'b1 : 32'b0;
        SLT: result = ($signed(a) < $signed(b)) ? 32'b1 : 32'b0; // returns true or false 
        default: result = 32'b0;
    endcase
end

assign zero = (result == 0); 
assign lt = ($signed(a) < $signed(b));
assign cout = carry; 


/* explaining my overflow logic 
 * 
 * take a[31] and b[31], which are the MSB of a and b and responsible for 
 * determining the sign of a and b. 
 * if a[31] == 0, then a is positive, else it's negative
 * if b[31] == 0, then b is positive, else it's negative
 * if a[31] == b[31], then that means that both a and b have the same sign
 * overflow occurs when adding/subtracting two numbers but being unable to 
 * express the correct result appropriately in the bitwidth provided, which
 * can occur here when adding two positive numbers and getting a negative value
 * fix: check if the MSB of the result is equal to the MSB of one of the data inputs
 * why?
 * case 1: add two positive numbers, get negative --> overflow 
 * case 2: add two negative numbers, get positive --> overflow 
 */ 

// 5/25/26 : updated overflow logic for SUB so that the SUB case was taken care of, which is pos - (neg) and neg - (pos) 
assign overflow = ((ALU_control == ADD) &&
    (a[31] == b[31]) &&
    (result[31] != a[31])) || ((ALU_control == SUB) && (a[31] != b[31]) && (result[31] != a[31]));

endmodule 

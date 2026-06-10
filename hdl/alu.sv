module alu(a, b, ALU_control, result, zero, overflow, lt, cout);

parameter data_width = 32; 

input [data_width-1:0] a, b; 
output reg [data_width-1:0] result;
input [4:0] ALU_control;
output zero, overflow, lt, cout; // either 1 or 0 (true or false) for each
reg carry;
// Multiply results. Operands are kept at their NATIVE 32-bit width and the
// product is widened by the assignment context (LHS width). This lets Quartus
// recognize a 32x32->64 multiply and map it onto hardware DSP blocks, instead
// of building a 64x64 multiplier in soft logic (the previous code sign-extended
// the operands to 64 bits first, which inferred 0 DSPs).
reg [63:0] mul64;   // signed*signed and unsigned*unsigned 32x32 products
reg [65:0] mul_su;  // signed*unsigned: 33x33 signed product (MULHSU)


// use the funct3 for bits [2:0], eliminating the need for a second decoding stage for ALU operation selection 

localparam ADD    = 5'b00000;
localparam SUB    = 5'b01000;
localparam SLL    = 5'b00001;
localparam SLT    = 5'b00010;
localparam SLTU   = 5'b00011;
localparam XOR    = 5'b00100;
localparam SRL    = 5'b00101;
localparam SRA    = 5'b01101;
localparam OR     = 5'b00110;
localparam AND    = 5'b00111;
localparam MUL    = 5'b10000;
localparam MULH   = 5'b10001;
localparam MULHSU = 5'b10010;
localparam MULHU  = 5'b10011;
localparam DIV    = 5'b10100;
localparam DIVU   = 5'b10101;
localparam REM    = 5'b10110;
localparam REMU   = 5'b10111;


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
        MUL:    begin mul64  = $signed(a)        * $signed(b);          result = mul64[31:0];  end // signed x signed, low word
        MULH:   begin mul64  = $signed(a)        * $signed(b);          result = mul64[63:32]; end // signed x signed, high word
        MULHSU: begin mul_su = $signed({a[31],a}) * $signed({1'b0, b}); result = mul_su[63:32]; end // signed x unsigned, high word
        MULHU:  begin mul64  = a * b;                                   result = mul64[63:32]; end // unsigned x unsigned, high word
        DIV:    result = (b==0) ? 32'hFFFFFFFF : $signed(a) / $signed(b);
        DIVU:   result = (b==0) ? 32'hFFFFFFFF : a / b;
        REM:    result = (b==0) ? a : $signed(a) % $signed(b);
        REMU:   result = (b==0) ? a : a % b;
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
assign overflow = ((ALU_control == ADD) && (a[31] == b[31]) && (result[31] != a[31])) ||
                  ((ALU_control == SUB) && (a[31] != b[31]) && (result[31] != a[31]));

endmodule 

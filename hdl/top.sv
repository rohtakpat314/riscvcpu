module top(clk, rst, result);

input  logic        clk;
input  logic        rst;
output logic [31:0] result;

// PC signals
logic [31:0] pc_out, pc_in, pc_plus4;

// instruction and fields
logic [31:0] instruction;
logic [6:0] opcode;
logic [2:0] funct3;
logic [6:0] funct7;
logic [4:0] rs1, rs2, rd;

// immediate
logic [31:0] imm;
logic [2:0] fmt;

// control signals
logic reg_write;
logic [4:0] alu_control;
logic alu_src;
logic alu_a_pc;
logic lui;
logic mem_read;
logic mem_write;
logic [1:0] mem_to_reg;
logic branch;
logic jal;
logic jalr;
logic [2:0] funct3_out;

// datapath
logic [31:0] rs1_data, rs2_data, write_data;
logic [31:0] alu_a, alu_b, alu_result;
logic alu_zero, alu_overflow, alu_lt, alu_cout;
logic [31:0] mem_read_data;
logic branch_taken;

// instruction field extraction
assign opcode = instruction[6:0];
assign funct3 = instruction[14:12];
assign funct7 = instruction[31:25];
assign rs1 = instruction[19:15];
assign rs2 = instruction[24:20];
assign rd = instruction[11:7];

// PC next logic
assign pc_plus4 = pc_out + 32'd4;
assign branch_taken = branch && (funct3_out[2] ? (alu_result[0] ^ funct3_out[0])
                                               : (alu_zero ^ funct3_out[0]));
assign pc_in = jalr         ? {alu_result[31:1], 1'b0}
             : jal          ? pc_out + imm
             : branch_taken ? pc_out + imm
             :                pc_plus4;

// ALU operand muxes
assign alu_a = alu_a_pc ? pc_out : rs1_data;
assign alu_b = alu_src  ? imm    : rs2_data;

// writeback mux
assign write_data = lui            ? imm
                  : mem_to_reg[1] ? pc_plus4
                  : mem_to_reg[0] ? mem_read_data
                  :                 alu_result;

// module instantiations
pc u_pc (
    .clk(clk), .rst(rst),
    .pc_in(pc_in), .pc_out(pc_out)
);
instruction_mem u_imem (
    .clk(clk), .pc(pc_out), .instruction(instruction)
);
imm_gen u_immgen (
    .instruction(instruction), .imm(imm), .fmt(fmt)
);
control_unit u_ctrl (
    .opcode(opcode), .funct3(funct3), .funct7(funct7),
    .reg_write(reg_write), .alu_control(alu_control),
    .alu_src(alu_src), .alu_a_pc(alu_a_pc), .lui(lui),
    .mem_read(mem_read), .mem_write(mem_write), .mem_to_reg(mem_to_reg),
    .branch(branch), .jal(jal), .jalr(jalr), .funct3_out(funct3_out)
);
reg_file u_regfile (
    .clk(clk), .write_en(reg_write),
    .read_addr1(rs1), .read_addr2(rs2),
    .write_addr(rd), .write_data(write_data),
    .reg1(rs1_data), .reg2(rs2_data)
);
alu u_alu (
    .a(alu_a), .b(alu_b), .ALU_control(alu_control),
    .result(alu_result), .zero(alu_zero),
    .overflow(alu_overflow), .lt(alu_lt), .cout(alu_cout)
);
data_mem u_dmem (
    .clk(clk), .mem_write(mem_write), .mem_read(mem_read),
    .addr(alu_result), .write_data(rs2_data),
    .funct3(funct3_out), .read_data(mem_read_data)
);
assign result = alu_result;

endmodule

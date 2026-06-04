// Please refer to RISCV_CARD.pdf on my GitHub for more information about the instruction type formats

module control_unit (opcode, funct3, funct7, reg_write, alu_control, alu_src, alu_a_pc, lui, mem_read, mem_write, mem_to_reg, branch, jal, jalr, funct3_out);

input  logic [6:0] opcode;
input  logic [2:0] funct3;
input  logic [6:0] funct7;

output logic       reg_write;   // enable write to rd
output logic [4:0] alu_control; // operation select
output logic       alu_src;     // ALU B operand
output logic       alu_a_pc;    // ALU A operand
output logic       lui;         // LUI: bypass ALU, write imm directly to rd
output logic       mem_read;    // data memory read enable (loads)
output logic       mem_write;   // data memory write enable (stores)
output logic [1:0] mem_to_reg;  // writeback mux: 00=ALU result, 01=mem data, 10=PC+4
output logic       branch;      // B-type: datapath resolves condition using funct3_out + ALU flags
output logic       jal;         // JAL:  rd=PC+4, PC=PC+imm
output logic       jalr;        // JALR: rd=PC+4, PC=rs1+imm
output logic [2:0] funct3_out;  // passed to datapath for branch condition and memory access width

localparam [4:0] ALU_ADD  = 5'b00000;
localparam [4:0] ALU_SUB  = 5'b01000;
localparam [4:0] ALU_SLT  = 5'b00010;
localparam [4:0] ALU_SLTU = 5'b00011;
localparam [6:0] FUNCT7_M = 7'b0000001;

// RV32I opcodes 
localparam [6:0] OP       = 7'b0110011; // R: ADD SUB XOR OR AND SLL SRL SRA SLT SLTU
localparam [6:0] OP_IMM   = 7'b0010011; // I: ADDI XORI ORI ANDI SLLI SRLI SRAI SLTI SLTIU
localparam [6:0] LOAD     = 7'b0000011; // I: LB LH LW LBU LHU
localparam [6:0] JALR_OP  = 7'b1100111; // I: JALR
localparam [6:0] SYSTEM   = 7'b1110011; // I: ECALL EBREAK
localparam [6:0] STORE    = 7'b0100011; // S: SB SH SW
localparam [6:0] BRANCH   = 7'b1100011; // B: BEQ BNE BLT BGE BLTU BGEU
localparam [6:0] LUI_OP   = 7'b0110111; // U: LUI
localparam [6:0] AUIPC_OP = 7'b0010111; // U: AUIPC
localparam [6:0] JAL_OP   = 7'b1101111; // J: JAL

// Branch -> ALU comparison mapping 
function automatic [4:0] branch_alu_ctrl(input logic [2:0] f3);
    case (f3)
        3'b000, 3'b001: branch_alu_ctrl = ALU_SUB;  // BEQ, BNE
        3'b100, 3'b101: branch_alu_ctrl = ALU_SLT;  // BLT, BGE
        3'b110, 3'b111: branch_alu_ctrl = ALU_SLTU; // BLTU, BGEU
        default:        branch_alu_ctrl = ALU_SUB;
    endcase
endfunction

// Control signal selection 
always @(*) begin
    // Safe defaults: no-op, no memory access, no writeback
    reg_write   = 1'b0;
    alu_control = ALU_ADD;
    alu_src     = 1'b0;
    alu_a_pc    = 1'b0;
    lui         = 1'b0;
    mem_read    = 1'b0;
    mem_write   = 1'b0;
    mem_to_reg  = 2'b00;
    branch      = 1'b0;
    jal         = 1'b0;
    jalr        = 1'b0;
    funct3_out  = funct3;

    case (opcode)

        OP: begin // R-type
            reg_write = 1'b1;
            if (funct7 == FUNCT7_M)
                alu_control = {1'b1, 1'b0, funct3}; // M-extension: 5'b10_funct3
            else
                alu_control = {1'b0, funct7[5], funct3}; // RV32I: 5'b0_{funct7[5]}_funct3
        end

        OP_IMM: begin // I-type arithmetic
            reg_write = 1'b1;
            alu_src = 1'b1;
            // inst[30] (funct7[5]) is an immediate bit for all I-type except SRLI/SRAI (funct3=101)
            // only gate it through for the shift-right case to avoid treating a negative
            // immediate as a SUB or SRA incorrectly
            alu_control = {1'b0, funct7[5] & (funct3 == 3'b101), funct3};
        end

        LOAD: begin                 // I-type load (LB LH LW LBU LHU)
            reg_write = 1'b1;
            alu_src = 1'b1;
            mem_read = 1'b1;
            mem_to_reg = 2'b01;   // write back data read from memory
            alu_control = ALU_ADD; // effective address = rs1 + imm
        end

        STORE: begin                // S-type (SB SH SW)
            alu_src = 1'b1;
            mem_write = 1'b1;
            alu_control = ALU_ADD; // effective address = rs1 + imm
        end

        BRANCH: begin               // B-type (BEQ BNE BLT BGE BLTU BGEU)
            branch = 1'b1;
            alu_control = branch_alu_ctrl(funct3);
        end

        JAL_OP: begin               // J-type
            reg_write = 1'b1;
            jal = 1'b1;
            mem_to_reg = 2'b10;    // rd = PC+4 (return address)
        end

        JALR_OP: begin              // I-type (JALR)
            reg_write = 1'b1;
            alu_src = 1'b1;
            jalr = 1'b1;
            mem_to_reg = 2'b10;   // rd = PC+4 (return address)
            alu_control = ALU_ADD; // jump target = rs1 + imm (LSB cleared by datapath)
        end

        LUI_OP: begin               // U-type
            reg_write = 1'b1;
            lui = 1'b1;      // imm_gen already produced u_imm; write directly to rd
        end

        AUIPC_OP: begin             // U-type
            reg_write = 1'b1;
            alu_src = 1'b1;
            alu_a_pc = 1'b1;    // A = PC, B = u_imm → rd = PC + u_imm
            alu_control = ALU_ADD;
        end

        SYSTEM: begin               // ECALL EBREAK — trap handling deferred
        end

        default: begin end          // illegal instruction — all signals remain 0

    endcase
end

endmodule


// Please refer to RISCV_CARD.pdf on my GitHub for more information about the instruction type formats

module imm_gen (instruction, imm, fmt);

input  logic [31:0] instruction;
output logic [31:0] imm; // immediate value output
output logic [2:0]  fmt; // fmt is used to determine format, 6 formats, so you need 3 bits to essentially choose between them

wire [6:0] opcode = instruction[6:0];
wire sign   = instruction[31];   // sign bit is always inst[31] across all formats

// Immediate assembly (before sign extension), 12b can only reach 2KB, for anything beyond that you need a full 32-bit value. 
// LUI and AUIPC each load the upper 20 bits, and you pair them with an I-type instruction to fill in the lower 12, giving any 32-bit value in two instructions. 

//  I type: 
wire [11:0] i_imm = instruction[31:20];

//  S type: 
wire [11:0] s_imm = {instruction[31:25], instruction[11:7]};

//  B type: 
wire [12:0] b_imm = {instruction[31], instruction[7], instruction[30:25], instruction[11:8], 1'b0};

//  U type:
wire [31:0] u_imm = {instruction[31:12], 12'b0};

//  J type: 
wire [20:0] j_imm = {instruction[31], instruction[19:12], instruction[20], instruction[30:21], 1'b0};

// Format encoding (passed to control unit) 
localparam [2:0] FMT_R = 3'b000;
localparam [2:0] FMT_I = 3'b001;
localparam [2:0] FMT_S = 3'b010;
localparam [2:0] FMT_B = 3'b011;
localparam [2:0] FMT_U = 3'b100;
localparam [2:0] FMT_J = 3'b101;

// opcodes
localparam [6:0] OP = 7'b0110011;  // R: ADD SUB XOR OR AND SLL SRL SRA SLT SLTU
localparam [6:0] OP_IMM = 7'b0010011;  // I: ADDI XORI ORI ANDI SLLI SRLI SRAI SLTI SLTIU
localparam [6:0] LOAD = 7'b0000011;  // I: LB LH LW LBU LHU
localparam [6:0] JALR = 7'b1100111;  // I: JALR
localparam [6:0] SYSTEM = 7'b1110011;  // I: ECALL EBREAK
localparam [6:0] STORE = 7'b0100011;  // S: SB SH SW
localparam [6:0] BRANCH = 7'b1100011;  // B: BEQ BNE BLT BGE BLTU BGEU
localparam [6:0] LUI = 7'b0110111;  // U: LUI
localparam [6:0] AUIPC = 7'b0010111;  // U: AUIPC
localparam [6:0] JAL = 7'b1101111;  // J: JAL

// ── Immediate decode ─────────────────────────────────────────────────────────
always_comb begin
    imm = 32'b0;
    fmt = FMT_R;

    case (opcode)
        OP: begin                            // R-type no immediate
            fmt = FMT_R;
            imm = 32'b0;
        end

        OP_IMM, LOAD, JALR, SYSTEM: begin   // I-type 12-bit sign-extended
            fmt = FMT_I;
            imm = {{20{sign}}, i_imm};
        end

        STORE: begin                         // S-type 12-bit sign-extended
            fmt = FMT_S;
            imm = {{20{sign}}, s_imm};
        end

        BRANCH: begin                        // B-type 13-bit sign-extended
            fmt = FMT_B;
            imm = {{19{sign}}, b_imm};
        end

        LUI, AUIPC: begin                   // U-type 20-bit upper, no sign extension needed
            fmt = FMT_U;
            imm = u_imm;
        end

        JAL: begin                           // J-type 21-bit sign-extended
            fmt = FMT_J;
            imm = {{11{sign}}, j_imm};
        end

        default: begin
            fmt = FMT_R;
            imm = 32'b0;
        end
    endcase
end

endmodule
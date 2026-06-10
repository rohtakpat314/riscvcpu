`timescale 1ns/1ps
// Directed unit test for the M-extension multiply variants in alu.sv.
// Drives the ALU combinationally and checks MUL / MULH / MULHSU / MULHU
// against hand-computed golden values, including signed/unsigned corners.
//   iverilog -g2012 -o sim_mul.vvp alu.sv tb_mul.sv ; vvp sim_mul.vvp
module tb_mul;
    logic [31:0] a, b;
    logic [4:0]  ctrl;
    logic [31:0] result;
    logic        zero, overflow, lt, cout;
    integer      errors = 0;

    localparam [4:0] MUL    = 5'b10000;
    localparam [4:0] MULH   = 5'b10001;
    localparam [4:0] MULHSU = 5'b10010;
    localparam [4:0] MULHU  = 5'b10011;

    alu dut (.a(a), .b(b), .ALU_control(ctrl), .result(result),
             .zero(zero), .overflow(overflow), .lt(lt), .cout(cout));

    task check(input [4:0] c, input [31:0] av, input [31:0] bv,
               input [31:0] exp, input string name);
        begin
            a = av; b = bv; ctrl = c; #1;
            if (result !== exp) begin
                errors = errors + 1;
                $display("  FAIL  %-14s %08h op %08h = %08h (exp %08h)",
                         name, av, bv, result, exp);
            end else begin
                $display("  PASS  %-14s = %08h", name, result);
            end
        end
    endtask

    initial begin
        $display("=== MULTIPLY UNIT TEST (DSP-inference rewrite) ===");
        // MUL : low 32 bits, signed*signed
        check(MUL,    32'd7,        32'd6,        32'd42,       "MUL pos");
        check(MUL,    32'hFFFFFFFD, 32'd5,        32'hFFFFFFF1, "MUL neg");   // -3 * 5 = -15
        check(MUL,    32'h00010000, 32'h00010000, 32'h00000000, "MUL ovf-low");
        // MULH : high 32 bits, signed*signed
        check(MULH,   32'hFFFFFFFD, 32'd5,        32'hFFFFFFFF, "MULH neg");  // -15 high word
        check(MULH,   32'h40000000, 32'h40000000, 32'h10000000, "MULH pos");
        check(MULH,   32'h80000000, 32'h80000000, 32'h40000000, "MULH neg*neg");
        // MULHU : high 32 bits, unsigned*unsigned
        check(MULHU,  32'hFFFFFFFF, 32'hFFFFFFFF, 32'hFFFFFFFE, "MULHU max");
        // MULHSU : high 32 bits, signed(rs1) * unsigned(rs2)
        check(MULHSU, 32'hFFFFFFFF, 32'd2,        32'hFFFFFFFF, "MULHSU -1*2");
        check(MULHSU, 32'h80000000, 32'hFFFFFFFF, 32'h80000000, "MULHSU min*max");
        check(MULHSU, 32'd5,        32'hFFFFFFFF, 32'h00000004, "MULHSU 5*max");

        if (errors == 0)
            $display("RESULT: PASS (all multiply variants correct)");
        else
            $display("RESULT: FAIL (%0d errors)", errors);
        $finish;
    end
endmodule

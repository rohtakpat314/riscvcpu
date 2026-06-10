// tb_selfcheck.sv — self-checking testbench for the RV32IM matmul program.
//
// Unlike tb_top.sv (which only traces), this testbench VERIFIES correctness:
//   * Waits for the program to reach its halt loop (beq x0,x0,0 == 32'h00000063).
//   * Reads matrices A and B straight out of data memory.
//   * Recomputes the expected C = A * B in the testbench (golden reference).
//   * Compares it word-for-word against the C your CPU wrote.
//   * Prints a clear PASS / FAIL summary.
//
// Memory layout produced by program.hex (row-major 4x4, 32-bit words):
//   A : data_mem words  0..15  (base byte addr 0x00, x1)
//   B : data_mem words 16..31  (base byte addr 0x40, x2)
//   C : data_mem words 32..47  (base byte addr 0x80, x3)
//
// Run:
//   iverilog -g2012 -o sim_check.vvp instruction_mem.sv data_mem.sv reg_file.sv \
//       alu.sv pc.sv control_unit.sv imm_gen.sv top.sv tb_selfcheck.sv
//   vvp sim_check.vvp

`timescale 1ns/1ps

module tb_selfcheck;

reg clk;
reg rst;
wire [31:0] result;

top dut (
    .clk(clk),
    .rst(rst),
    .result(result)
);

initial clk = 0;
always #5 clk = ~clk;

localparam [31:0] HALT_INSTR = 32'h00000063; // beq x0, x0, 0  -> spin in place

integer cyc;
initial cyc = 0;
always @(posedge clk) begin
    #1;
    cyc = cyc + 1;
end

// Read a word out of the CPU's data memory by word index.
function [31:0] dmem;
    input integer word_idx;
    begin
        dmem = dut.u_dmem.memory[word_idx];
    end
endfunction

integer i, j, k;
integer errors;
reg [31:0] a_val, b_val, expected, got;
reg done;

initial begin
    rst  = 1;
    done = 0;
    repeat (2) @(posedge clk);
    #1 rst = 0;

    // Wait until the program reaches its halt loop, with a safety timeout.
    fork
        begin : wait_halt
            while (dut.instruction !== HALT_INSTR) @(posedge clk);
            // give the final store a cycle to settle
            @(posedge clk); #1;
            done = 1;
        end
        begin : timeout
            repeat (5000) @(posedge clk);
            if (!done) begin
                $display("");
                $display("[FAIL] TIMEOUT: program never reached halt loop in 5000 cycles");
                $display("       (last PC=%08h instr=%08h)", dut.pc_out, dut.instruction);
                $finish;
            end
        end
    join_any
    disable timeout;

    // ---- Golden check: C = A * B ----
    errors = 0;
    $display("");
    $display("=== RV32IM SELF-CHECK: 4x4 matmul (C = A*B) ===");
    $display("reached halt loop at cycle %0d", cyc);
    $display("");

    for (i = 0; i < 4; i = i + 1) begin
        for (j = 0; j < 4; j = j + 1) begin
            expected = 32'd0;
            for (k = 0; k < 4; k = k + 1) begin
                a_val    = dmem(i*4 + k);        // A[i][k], words 0..15
                b_val    = dmem(16 + k*4 + j);   // B[k][j], words 16..31
                expected = expected + a_val * b_val;
            end
            got = dmem(32 + i*4 + j);            // C[i][j], words 32..47
            if (got !== expected) begin
                errors = errors + 1;
                $display("  MISMATCH C[%0d][%0d]: got %0d, expected %0d", i, j, got, expected);
            end
        end
    end

    $display("");
    if (errors == 0)
        $display("RESULT: PASS  (all 16 elements correct)");
    else
        $display("RESULT: FAIL  (%0d / 16 elements wrong)", errors);
    $display("===============================================");

    $finish;
end

endmodule

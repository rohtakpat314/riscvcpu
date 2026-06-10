`timescale 1ns/1ps
// Directed self-checking testbench for the LUI instruction.
// Load with:  vvp sim_lui.vvp +HEX=lui_test.hex
module tb_lui;
    logic        clk = 0;
    logic        rst;
    logic [31:0] result;
    integer      errors = 0;

    top dut (.clk(clk), .rst(rst), .result(result));

    always #5 clk = ~clk;

    task check(input [4:0] r, input [31:0] exp);
        if (dut.u_regfile.reg_filex[r] !== exp) begin
            errors = errors + 1;
            $display("  FAIL  x%0d = %08h, expected %08h",
                     r, dut.u_regfile.reg_filex[r], exp);
        end else begin
            $display("  PASS  x%0d = %08h", r, dut.u_regfile.reg_filex[r]);
        end
    endtask

    initial begin
        rst = 1'b1;
        repeat (2) @(posedge clk);
        rst = 1'b0;
        repeat (20) @(posedge clk);

        $display("=== LUI DIRECTED TEST ===");
        check(5'd20, 32'h10000000);  // basic upper immediate
        check(5'd5,  32'hDEADB000);  // arbitrary pattern
        check(5'd6,  32'hFFFFF000);  // all-ones upper, no sign extension
        check(5'd7,  32'h12345678);  // LUI + ADDI 32-bit constant
        check(5'd8,  32'h80000000);  // MSB set, no sign extension

        if (errors == 0)
            $display("RESULT: PASS (LUI correct across all cases)");
        else
            $display("RESULT: FAIL (%0d errors)", errors);
        $finish;
    end
endmodule

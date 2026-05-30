// Testbench for single-cycle RV32I CPU
// Test program: fibonacci sequence, result fib(8) = 21 ends up in x2

`timescale 1ns/1ps

module tb_top;

reg clk;
reg rst;

top dut (
    .clk(clk),
    .rst(rst)
);

initial clk = 0;
always #5 clk = ~clk;

initial begin
    rst = 1;
    repeat(2) @(posedge clk);
    #1 rst = 0;

    repeat(45) @(posedge clk);

    // x1 = fib(7) = 13, x2 = fib(8) = 21
    if (dut.u_regfile.reg_filex[1] !== 32'd13)
        $display("FAIL x1: got %0d, expected 13", dut.u_regfile.reg_filex[1]);
    if (dut.u_regfile.reg_filex[2] !== 32'd21)
        $display("FAIL x2: got %0d, expected 21", dut.u_regfile.reg_filex[2]);

    $display("simulation done. x1=%0d x2=%0d", dut.u_regfile.reg_filex[1], dut.u_regfile.reg_filex[2]);
    $finish;
end

initial begin
    $dumpfile("tb_top.vcd");
    $dumpvars(0, tb_top);
end

integer cyc;
initial cyc = 0;

always @(posedge clk) begin
    #1;
    cyc = cyc + 1;
    $display("cyc %2d | PC=%08h instr=%08h | x1=%2d x2=%2d x3=%2d x4=%2d",
        cyc,
        dut.pc_out,
        dut.instruction,
        dut.u_regfile.reg_filex[1],
        dut.u_regfile.reg_filex[2],
        dut.u_regfile.reg_filex[3],
        dut.u_regfile.reg_filex[4]
    );
end

endmodule

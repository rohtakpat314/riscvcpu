// Testbench for single-cycle RV32I CPU, Fibonacci sequence

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

    repeat(25) @(posedge clk);

    // x6-x10 should be 1-5 (loaded from memory), x11 should be 15 (sum)
    if (dut.u_regfile.reg_filex[11] !== 32'd15)
        $display("FAIL x11: got %0d, expected 15", dut.u_regfile.reg_filex[11]);

    $display("simulation done. x1=%0d x2=%0d x3=%0d x4=%0d x5=%0d | x6=%0d x7=%0d x8=%0d x9=%0d x10=%0d | sum x11=%0d",
        dut.u_regfile.reg_filex[1],  dut.u_regfile.reg_filex[2],
        dut.u_regfile.reg_filex[3],  dut.u_regfile.reg_filex[4],
        dut.u_regfile.reg_filex[5],  dut.u_regfile.reg_filex[6],
        dut.u_regfile.reg_filex[7],  dut.u_regfile.reg_filex[8],
        dut.u_regfile.reg_filex[9],  dut.u_regfile.reg_filex[10],
        dut.u_regfile.reg_filex[11]);
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
    $display("cyc %2d | PC=%08h instr=%08h | x1=%2d x2=%2d x3=%2d x4=%2d x5=%2d | x6=%2d x7=%2d x8=%2d x9=%2d x10=%2d | x11=%2d",
        cyc,
        dut.pc_out,
        dut.instruction,
        dut.u_regfile.reg_filex[1],
        dut.u_regfile.reg_filex[2],
        dut.u_regfile.reg_filex[3],
        dut.u_regfile.reg_filex[4],
        dut.u_regfile.reg_filex[5],
        dut.u_regfile.reg_filex[6],
        dut.u_regfile.reg_filex[7],
        dut.u_regfile.reg_filex[8],
        dut.u_regfile.reg_filex[9],
        dut.u_regfile.reg_filex[10],
        dut.u_regfile.reg_filex[11]
    );
end

endmodule

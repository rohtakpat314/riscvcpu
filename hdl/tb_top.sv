// Testbench for RV32IM CPU - tests M-extension (MUL, DIV, REM)

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

    repeat(20) @(posedge clk);

    // x3 = mul(6,7)  = 42
    if (dut.u_regfile.reg_filex[3] !== 32'd42)
        $display("FAIL x3 (MUL 6*7): got %0d, expected 42", dut.u_regfile.reg_filex[3]);

    // x7 = div(6,7)  = 0
    if (dut.u_regfile.reg_filex[7] !== 32'd0)
        $display("FAIL x7 (DIV 6/7): got %0d, expected 0", dut.u_regfile.reg_filex[7]);

    // x9 = div(20,7) = 2
    if (dut.u_regfile.reg_filex[9] !== 32'd2)
        $display("FAIL x9 (DIV 20/7): got %0d, expected 2", dut.u_regfile.reg_filex[9]);

    // x10 = rem(20,7) = 6
    if (dut.u_regfile.reg_filex[10] !== 32'd6)
        $display("FAIL x10 (REM 20%%7): got %0d, expected 6", dut.u_regfile.reg_filex[10]);

    // x11 = div(6,0) = 0xFFFFFFFF (divide by zero)
    if (dut.u_regfile.reg_filex[11] !== 32'hFFFFFFFF)
        $display("FAIL x11 (DIV by zero): got %08h, expected ffffffff", dut.u_regfile.reg_filex[11]);

    $display("simulation done.");
    $display("x3=MUL(6,7)=%0d  x5=MUL(-1,7)=%08h  x6=MULH(-1,7)=%08h",
        dut.u_regfile.reg_filex[3],
        dut.u_regfile.reg_filex[5],
        dut.u_regfile.reg_filex[6]);
    $display("x7=DIV(6,7)=%0d  x9=DIV(20,7)=%0d  x10=REM(20,7)=%0d  x11=DIV(6,0)=%08h",
        dut.u_regfile.reg_filex[7],
        dut.u_regfile.reg_filex[9],
        dut.u_regfile.reg_filex[10],
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
    $display("cyc %2d | PC=%08h instr=%08h | x3=%3d x5=%08h x6=%08h x7=%0d x9=%0d x10=%0d x11=%08h",
        cyc,
        dut.pc_out,
        dut.instruction,
        dut.u_regfile.reg_filex[3],
        dut.u_regfile.reg_filex[5],
        dut.u_regfile.reg_filex[6],
        dut.u_regfile.reg_filex[7],
        dut.u_regfile.reg_filex[9],
        dut.u_regfile.reg_filex[10],
        dut.u_regfile.reg_filex[11]
    );
end

endmodule

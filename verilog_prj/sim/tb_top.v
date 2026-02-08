`timescale 1ns/1ps

module tb_top;

    reg clk;
    reg rst_n;
    wire led;

    top dut (
        .clk   (clk),
        .rst_n (rst_n),
        .led   (led)
    );

    // Clock: 10ns period
    always #5 clk = ~clk;

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_top);

        clk   = 0;
        rst_n = 0;

        repeat (5) @(posedge clk);
        rst_n = 1;

        repeat (50) @(posedge clk);

        $display("LED = %b", led);
        $finish;
    end

endmodule

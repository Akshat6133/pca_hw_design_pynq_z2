
module top (
    input  wire clk,
    input  wire rst_n,
    output reg  led
);

    reg [3:0] counter;

    always @(posedge clk) begin
        if (!rst_n) begin
            counter <= 4'd0;
            led     <= 1'b0;
        end else begin
            counter <= counter + 1'b1;

            if (counter == 4'd9)
                led <= ~led;
        end
    end

endmodule

`include "pca_params.svh"

module pca_top #(
    parameter int D = 4,
    parameter int K = 2,
    parameter int IN_W = 16,
    parameter int COEF_W = 16,
    parameter int OUT_W = 16,
    parameter int FRAC = 12,
    parameter int ACC_W = 40
) (
    input  logic clk,
    input  logic rst_n,
    input  logic in_valid,
    input  logic signed [D*IN_W-1:0] x_flat,
    output logic out_valid,
    output logic signed [K*OUT_W-1:0] y_flat
);

    typedef logic signed [ACC_W-1:0] acc_t;

    logic signed [IN_W-1:0] x_vec [0:D-1];
    acc_t y_comb [0:K-1];
    logic signed [OUT_W-1:0] y_q [0:K-1];
    // function automatic logic signed [COEF_W-1:0] mu_coef(input int idx);
        // begin
    //         // Mean values from Iris-style offline training, Q4.12 format.
    //         case (idx)
    //             0: mu_coef = 16'sd23934;
    //             1: mu_coef = 16'sd12524;
    //             2: mu_coef = 16'sd15393;
    //             3: mu_coef = 16'sd4912;
    //             default: mu_coef = '0;
    //         endcase
    //     end
    // endfunction
    
//PCA weight matrix (W)
    // function automatic logic signed [COEF_W-1:0] w_coef(input int comp, input int feat);
    //     begin
    //         // Principal vectors from offline training, Q1.15-ish stored in Q4.12 scale.
    //         case (comp)
    //             0: begin
    //                 case (feat)
    //                     0: w_coef = 16'sd1480;
    //                     1: w_coef = -16'sd346;
    //                     2: w_coef = 16'sd3509;
    //                     3: w_coef = 16'sd1468;
    //                     default: w_coef = '0;
    //                 endcase
    //             end
    //             1: begin
    //                 case (feat)
    //                     0: w_coef = 16'sd2689;
    //                     1: w_coef = 16'sd2991;
    //                     2: w_coef = -16'sd710;
    //                     3: w_coef = -16'sd309;
    //                     default: w_coef = '0;
    //                 endcase
    //             end
    //             default: w_coef = '0;
    //         endcase
    //     end
    // endfunction


    // -------- Fixed-point rounding ----------
    function automatic logic signed [OUT_W-1:0] sat_round_q(
        input logic signed [ACC_W-1:0] acc
    );
        logic signed [ACC_W-1:0] shifted;
        logic signed [ACC_W-1:0] rounded;
        logic signed [ACC_W-1:0] maxv;
        logic signed [ACC_W-1:0] minv;
        begin
            shifted = acc + (1 <<< (FRAC - 1));
            rounded = shifted >>> FRAC;
            maxv = (1 <<< (OUT_W - 1)) - 1;
            minv = -(1 <<< (OUT_W - 1));

            if (rounded > maxv)
                sat_round_q = maxv[OUT_W-1:0];
            else if (rounded < minv)
                sat_round_q = minv[OUT_W-1:0];
            else
                sat_round_q = rounded[OUT_W-1:0];
        end
    endfunction

    // -------- Unpack input ----------
    always_comb begin
        for (int d = 0; d < D; d = d + 1)
            x_vec[d] = x_flat[d*IN_W +: IN_W];
    end
 
    // -------- PCA MAC ----------
    always_comb begin
        logic signed [IN_W:0] centered;
        logic signed [IN_W+COEF_W:0] mult;
        for (int k = 0; k < K; k = k + 1) begin
            y_comb[k] = '0;
            for (int d = 0; d < D; d = d + 1) begin
                centered = x_vec[d] - mu_coef(d);
                mult = centered * w_coef(k, d);
                y_comb[k] = y_comb[k] + acc_t'(mult);
            end
            y_q[k] = sat_round_q(y_comb[k]);
        end
    end

    // -------- Output register ----------
    always_ff @(posedge clk) begin
        if (!rst_n) begin
            out_valid <= 1'b0;
            y_flat <= '0;
        end else begin
            out_valid <= in_valid;
            if (in_valid) begin
                for (int k = 0; k < K; k = k + 1)
                    y_flat[k*OUT_W +: OUT_W] <= y_q[k];
            end
        end
    end

endmodule

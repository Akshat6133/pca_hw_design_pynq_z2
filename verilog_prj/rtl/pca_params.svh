// AUTO-GENERATED PCA PARAMETERS

function automatic logic signed [15:0] mu_coef(input int idx);
  case (idx)
    0: mu_coef = 16'sd23934;
    1: mu_coef = 16'sd12523;
    2: mu_coef = 16'sd15393;
    3: mu_coef = 16'sd4912;
    default: mu_coef = '0;
  endcase
endfunction

function automatic logic signed [15:0] w_coef(input int comp, input int feat);
  case (comp)
    0: begin
      case (feat)
        0: w_coef = 16'sd1480;
        1: w_coef = -16'sd346;
        2: w_coef = 16'sd3509;
        3: w_coef = 16'sd1468;
        default: w_coef = '0;
      endcase
    end
    1: begin
      case (feat)
        0: w_coef = 16'sd2689;
        1: w_coef = 16'sd2991;
        2: w_coef = -16'sd710;
        3: w_coef = -16'sd309;
        default: w_coef = '0;
      endcase
    end
    default: w_coef = '0;
  endcase
endfunction

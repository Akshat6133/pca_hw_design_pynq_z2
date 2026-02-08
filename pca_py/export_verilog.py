def sv_signed(width, value):
    if value < 0:
        return f"-{width}'sd{abs(value)}"
    else:
        return f"{width}'sd{value}"


def export_verilog(mu_q, W_q, path):
    with open(path, "w") as f:
        f.write("// AUTO-GENERATED PCA PARAMETERS\n\n")

        f.write("function automatic logic signed [15:0] mu_coef(input int idx);\n")
        f.write("  case (idx)\n")
        for i, v in enumerate(mu_q):
            f.write(f"    {i}: mu_coef = 16'sd{v};\n")
        f.write("    default: mu_coef = '0;\n")
        f.write("  endcase\nendfunction\n\n")

        f.write("function automatic logic signed [15:0] w_coef(input int comp, input int feat);\n")
        f.write("  case (comp)\n")
        for k, row in enumerate(W_q):
            f.write(f"    {k}: begin\n")
            f.write("      case (feat)\n")
            for d, v in enumerate(row):
                f.write(f"        {d}: w_coef = {sv_signed(16, v)};\n")
            f.write("        default: w_coef = '0;\n")
            f.write("      endcase\n    end\n")
        f.write("    default: w_coef = '0;\n")
        f.write("  endcase\nendfunction\n")

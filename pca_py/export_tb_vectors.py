def export_cpp_vectors(X_q, Y_q, path):
    with open(path, "w") as f:
        f.write("#pragma once\n\n")
        f.write("static const int NUM_VECTORS = %d;\n" % len(X_q))
        f.write("static const int D = %d;\n" % len(X_q[0]))
        f.write("static const int K = %d;\n\n" % len(Y_q[0]))

        f.write("static const int x_vec[NUM_VECTORS][D] = {\n")
        for x in X_q:
            f.write("  {" + ", ".join(map(str, x)) + "},\n")
        f.write("};\n\n")

        f.write("static const int y_ref[NUM_VECTORS][K] = {\n")
        for y in Y_q:
            f.write("  {" + ", ".join(map(str, y)) + "},\n")
        f.write("};\n")

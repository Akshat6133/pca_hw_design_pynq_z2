import numpy as np
from sklearn.decomposition import PCA
from sklearn.datasets import load_iris

from fixed_point import float_to_fixed
from pca_math import pca_fixed_infer
from export_verilog import export_verilog
from export_tb_vectors import export_cpp_vectors

FRAC = 12
D = 4
K = 2
NUM_TEST = 20

# Load data
X, _ = load_iris(return_X_y=True)
X = X[:, :D]

# Train PCA (floating)
mu = X.mean(axis=0)
pca = PCA(n_components=K)
pca.fit(X)
W = pca.components_

# Quantize
mu_q = [float_to_fixed(v, FRAC) for v in mu]
W_q  = [[float_to_fixed(v, FRAC) for v in row] for row in W]

# Prepare test vectors
X_test = X[:NUM_TEST]
X_q = [[float_to_fixed(v, FRAC) for v in x] for x in X_test]

# Software reference outputs
Y_q = [pca_fixed_infer(x, mu_q, W_q, FRAC) for x in X_q]

# Export
export_verilog(mu_q, W_q, "./../verilog_prj/rtl/pca_params.svh")
export_cpp_vectors(X_q, Y_q, "./../verilog_prj/sim/pca_vectors.h")

print("✔ PCA trained")
print("✔ Fixed-point parameters exported")
print("✔ Test vectors generated")

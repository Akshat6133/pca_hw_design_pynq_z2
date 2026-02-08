import numpy as np

FRAC = 12

def sat_round(acc, out_w=16):
    acc += 1 << (FRAC - 1)
    acc >>= FRAC
    maxv = (1 << (out_w - 1)) - 1
    minv = -(1 << (out_w - 1))
    return max(min(acc, maxv), minv)

def pca_fixed(x, mu_q, W_q):
    y = []
    for k in range(len(W_q)):
        acc = 0
        for d in range(len(x)):
            centered = x[d] - mu_q[d]
            acc += centered * W_q[k][d]
        y.append(sat_round(acc))
    return y

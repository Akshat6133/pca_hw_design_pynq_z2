import numpy as np

def float_to_fixed(x, frac=12):
    return int(np.round(x * (1 << frac)))

def fixed_to_float(x, frac=12):
    return x / float(1 << frac)

def sat_round(acc, frac=12, out_w=16):
    acc += 1 << (frac - 1)
    acc >>= frac
    maxv = (1 << (out_w - 1)) - 1
    minv = -(1 << (out_w - 1))
    return max(min(acc, maxv), minv)

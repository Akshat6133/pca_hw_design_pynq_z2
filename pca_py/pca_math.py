from fixed_point import sat_round

def pca_fixed_infer(x_q, mu_q, W_q, frac=12):
    """
    x_q  : input vector in fixed-point
    mu_q : mean vector in fixed-point
    W_q  : PCA matrix in fixed-point
    """
    y = []
    for k in range(len(W_q)):
        acc = 0
        for d in range(len(x_q)):
            centered = x_q[d] - mu_q[d]
            acc += centered * W_q[k][d]
        y.append(sat_round(acc, frac))
    return y

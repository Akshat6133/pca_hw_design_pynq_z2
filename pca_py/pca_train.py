import numpy as np
from sklearn.decomposition import PCA
from sklearn.datasets import load_iris

D = 4   # features
K = 2   # principal components

# Load dataset
X, _ = load_iris(return_X_y=True)
X = X[:, :D]

# Mean
mu = X.mean(axis=0)

# PCA
pca = PCA(n_components=K)
pca.fit(X)

W = pca.components_   # shape (K, D)

print("Mean vector:")
print(mu)
print("\nPrincipal components:")
print(W)

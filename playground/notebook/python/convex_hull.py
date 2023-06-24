# %% [markdown]
# 凸包(Convex Hull)の計算
#
# https://docs.scipy.org/doc/scipy/reference/generated/scipy.spatial.ConvexHull.html

# %%
from scipy.spatial import ConvexHull
import juliapkg
import juliacall
import matplotlib.pyplot as plt

# %%
jl = juliacall.Main
jl.seval("using Random")

# %%
points = jl.rand(jl.Xoshiro(0), 30, 2).to_numpy()
hull = ConvexHull(points)

# %%
plt.plot(points[:, 0], points[:, 1], "o")
for simplex in hull.simplices:
    plt.plot(points[simplex, 0], points[simplex, 1], "k-")

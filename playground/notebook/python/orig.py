# %% [markdown]
# 下記のコマンドをリポジトリのルート(即ち `Project.toml`, `README.md` が存在するディレクトリ) で実行する。
#
# ```console
# $ PYTHON_JULIAPKG_PROJECT=`pwd` jupyter lab
# ```

# %%
from scipy.spatial import ConvexHull
import juliapkg
import juliacall
import matplotlib.pyplot as plt

# %%
juliapkg.project()

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

# -*- coding: utf-8 -*-
# %%
versioninfo()

# %%
using Random
using PythonCall
using OffsetArrays: Origin
using Images
using PythonPlot: pyplot as plt

# %%
# どの Python をみているか？
Base.Filesystem.contractuser(PythonCall.C.CTX.exe_path)

# %%
ConvexHull = PythonCall.pyimport("scipy.spatial").ConvexHull

# %%
rng = Xoshiro(0)
points = Py(rand(rng, 30, 2)).to_numpy()
hull = ConvexHull(points)

# %% [markdown]
# `points[:, 0]` だと NumPy ユーザにとって意図しない結果が得られる. `points[pybuiltin.slice(pybuiltin.None), 0]` を使う

# %%
rm("result.png", force=true)

fig, ax = plt.subplots()
ax.plot(points[pybuiltins.slice(pybuiltins.None), 0], points[pybuiltins.slice(pybuiltins.None), 1], "ro")
for simplex in hull.simplices
    ax.plot(points[simplex, 0], points[simplex, 1], "k-")
end

fig.savefig("result.png")

# %%
Images.load("result.png")

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
points = Origin(0,0)(rand(rng, 30, 2))
hull = ConvexHull(points)

# %%
rm("result.png", force=true)

fig, ax = plt.subplots()
ax.plot(points[:, 0], points[:, 1], "ro")
for pysimplex in hull.simplices
    # Py -> PyArray
    simplex = PyArray(pysimplex)
    ax.plot(points[simplex, 0], points[simplex, 1], "k-")
end

fig.savefig("result.png")

# %%
Images.load("result.png")

# %%

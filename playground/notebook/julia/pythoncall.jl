# -*- coding: utf-8 -*-
versioninfo()

# +
using Random
using PythonCall

using Images
using PythonPlot: pyplot as plt
# -

# どの Python をみているか？
Base.Filesystem.contractuser(PythonCall.C.CTX.exe_path)

ConvexHull = PythonCall.pyimport("scipy.spatial").ConvexHull

rng = Xoshiro(0)
points = PyArray(rand(rng, 30, 2))
hull = ConvexHull(points)

#

# +
rm("result.png", force=true)

fig, ax = plt.subplots()
ax.plot(points[:,begin + 0], points[:, begin + 1], "ro")
for simplex in hull.simplices
    simplex = pyconvert(Array, simplex)
    ax.plot(points[begin .+ simplex, begin + 0], points[begin .+ simplex, begin + 1], "k-")
end

fig.savefig("result.png")
# -

Images.load("result.png")

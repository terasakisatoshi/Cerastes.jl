# %%
versioninfo()

# %%
# using PythonCall; ENV["PYTHON"]=PythonCall.C.CTX.exe_path; using Pkg; Pkg.build("PyCall")

# %%
using Random

using Images
using OffsetArrays: OffsetArrays, Origin
using PythonPlot: pyplot as plt
using SciPy

# %%
Base.Filesystem.contractuser(SciPy.PyCall.pyprogramname)

# %%
rng = MersenneTwister(0)
points = Origin(0,0)(rand(rng, 30, 2))
hull = SciPy.spatial.ConvexHull(points)

# %%
rm("hull.png", force=true)
fig, ax = plt.subplots()
ax.plot(points[:,0], points[:,1], "o")
for simplex in eachrow(hull.simplices)
    ax.plot(points[simplex, 0], points[simplex, 1], "k-")
end
fig.savefig("hull.png")

# %%
img = load("hull.png")
img

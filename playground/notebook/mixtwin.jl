# ---
# jupyter:
#   jupytext:
#     text_representation:
#       extension: .jl
#       format_name: light
#       format_version: '1.5'
#       jupytext_version: 1.14.6
#   kernelspec:
#     display_name: Julia 1.9.1
#     language: julia
#     name: julia-1.9
# ---

versioninfo()

using PythonCall; ENV["PYTHON"]=PythonCall.C.CTX.exe_path; using Pkg; Pkg.build("PyCall")

# +
using Random

using Images
using PythonPlot: pyplot as plt
using SciPy
# -

points = rand(30, 2)
hull = SciPy.spatial.ConvexHull(points)

rm("hull.png", force=true)
fig, ax = plt.subplots()
ax.plot(points[:,1], points[:,2], "ro")
for simplex in eachrow(hull.simplices)
    ax.plot(points[begin .+ simplex, begin + 0], points[begin .+ simplex, begin + 1], "k-")
end
fig.savefig("hull.png")

img = load("hull.png")
img

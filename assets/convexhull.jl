using Random
using PythonCall
using OffsetArrays: Origin
using PythonPlot: pyplot as plt

ConvexHull = PythonCall.pyimport("scipy.spatial").ConvexHull
points = Origin(0, 0)(rand(Xoshiro(0), 30, 2))
hull = ConvexHull(points)
fig, ax = plt.subplots()
ax.plot(points[:, 0], points[:, 1], "ro")
for pysimplex in hull.simplices
    # Py -> PyArray 
    simplex = PyArray(pysimplex)
    ax.plot(points[simplex, 0], points[simplex, 1], "k-")
end
fig.savefig("plot1.png")
nothing

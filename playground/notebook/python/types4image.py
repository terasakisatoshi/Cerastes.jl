# %%
import juliacall
import numpy as np

jl = juliacall.Main
jl.Pkg.activate(jl.Base.current_project())
jl.Pkg.instantiate()

jl.seval("using Images")

# %%
H, W = 2 ** 4, 2 ** 4
pyimg = np.array(range(0, 256)).astype(np.uint8).reshape(H, W).T

jlimg = jl.reinterpret(jl.N0f8, jl.reshape(jl.seval("UInt8(0):UInt8(255) |> collect"), H, W))

assert np.all(pyimg / 255 == jlimg)

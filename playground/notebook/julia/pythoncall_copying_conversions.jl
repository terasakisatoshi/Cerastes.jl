# %%
using PythonCall

pyimport("sys").path.append(@__DIR__)

mylib = pyimport("mylib")

pyx = mylib.getx()
pyx[0] = -999
isequal = mylib.x[0] == -999
isequal |> typeof == Py
@assert Bool(isequal)

# %%
using PyCall

# %%
py"""
import numpy as np
x = np.array([1,2,3])
def getx():
    global x
    return x
"""

pyx = py"getx"()
@assert pyx[1] == 1

pyx[1] = -999
py"getx"()[1] == 1

# %%
jlx = pycall(py"getx", PyArray)
jlx[1] = -999
py"getx"()

# %%
using PyCall

py"""
import numpy as np
x = np.array([1,2,3])
def getx():
    global x
    return x
"""

pyx = py"getx"()
@assert pyx[1] == 1

pyx[1] = -999
@assert py"getx"()[1] == 1

jlx = pycall(py"getx", PyArray)
jlx[1] = -999
@assert py"getx"()[1] == -999

# %%

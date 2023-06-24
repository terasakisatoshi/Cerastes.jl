# %%
import juliacall

# %%
jl = juliacall.Main
jl.seval("using Pkg")
jl.Pkg.activate(jl.Base.current_project())
jl.Pkg.instantiate()

# %%
jl.seval("using Cerastes")
assert jl.Cerastes.hello() == "ごまごま"

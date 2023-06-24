class: middle, center

# PythonCall.jl 周りの話

```@example today
using Dates # hide
println("更新日: $(Dates.now())") # hide
```

---

# PythonCall.jl について 

- Julia から Python を呼ぶパッケージ
- [2022/02](https://discourse.julialang.org/t/ann-pythoncall-and-juliacall/76778) ごろにアナウンス
- Non-copying conversions
- Python の環境を Julia のプロジェクト毎に管理できる
- CondaPkg.jl で Python の依存関係を管理

### 双対概念として

- Python から Julia を呼びたい場合 `juliacall` を使える
- `juliapkg` で Python 環境毎に Julia の環境を管理できる（らしい）

---

# Installation

### Julia から Python を呼びたい

```julia-repl
julia> using Pkg; Pkg.add("PythonCall")
```

### Python から Julia を呼びたい

```console
$ pip3 install juliacall
$ python
>>> import juliacall
>>> jl = juliacall.Main
>>> juliacall.Pkg.add("Example")
>>> jl.seval("using Example")
>>> jl.Example.hello("Azarashi")
'Hello, Azarashi'
```

---

# 注意: `using PythonCall` を行う前に

- 環境変数 `JULIA_PYTHONCALL_EXE` を指定することで連携したい Python を指定することができる．[詳しくはこちら](https://cjdoris.github.io/PythonCall.jl/stable/pythoncall/#pythoncall-config)

```julia-repl
julia> ENV["JULIA_PYTHONCALL_EXE"]="path/to/python.exe"
```

#### [PyCall.jl](https://github.com/JuliaPy/PyCall.jl) に慣れている場合

読者が [PyCall.jl](https://github.com/JuliaPy/PyCall.jl) エコシステムを理解しており PyCall.jl と同じ Python を使用したい場合は下記のようにする:

```julia-repl
julia> ENV["JULIA_PYTHONCALL_EXE"]="@PyCall"
```

こちらでも良い

```julia-repl
using PythonCall; ENV["PYTHON"]=PythonCall.C.CTX.exe_path; using Pkg; Pkg.build("PyCall")
```

#### デフォルトの挙動

アクティベートしている Julia パッケージ直下に `.CondaPkg` が作られ [micromamba](https://mamba.readthedocs.io/en/latest/user_guide/micromamba.html) によって Python が導入される．

---

# どの Python を用いているかを確認する

## PyCall.jl の場合

```julia-repl
julia> using PyCall
julia> Base.Filesystem.contractuser(PyCall.pyprogramname)
```

[SciPy.jl の `print_configurations()`](https://github.com/AtsushiSakai/SciPy.jl/blob/83606f65414814ec0650493f53c654a11ab48b36/src/SciPy.jl#L330-L344) がわかりやすい．

## PythonCall.jl

```julia-repl
julia> using PythonCall
julia> Base.Filesystem.contractuser(PythonCall.C.CTX.exe_path)
"~/work/Cerastes.jl/.CondaPkg/env/bin/python"
```

---

# [CondaPkg.jl](https://github.com/cjdoris/CondaPkg.jl)

PyCall.jl は [Conda.jl](https://github.com/JuliaPy/Conda.jl) によって Python の依存関係を制御することができていた．

[CondaPkg.jl](https://github.com/cjdoris/CondaPkg.jl) は PythonCall.jl における Conda.jl みたいなもの

Julia のプロジェクト毎に依存関係を管理できる

```console
$ cat CondaPkg.toml

[pip.deps]
matplotlib = ""
scipy = ""
```

```julia
julia> using CondaPkg; CondaPkg.add_pip("sympy")
```

```console
$ cat CondaPkg.toml
[pip.deps]
matplotlib = ""
sympy = "" # <-- ここが増えている
scipy = ""
```

---

# 気になること


### 運用例はあるか？

- 結論: ある∃. [PyPlot.jl](https://github.com/JuliaPy/PyPlot.jl) のバックエンドを PythonCall.jl にした[PythonPlot.jl](https://github.com/JuliaPy/PythonPlot.jl)


### 互換性について

- PyCall.jl ベースで作られているライブラリと連携できるか？ 🧐
  - 結論: できる∃! (後述する)
- PyCall.jl に依存している部分を PythonCall.jl で置き換えられるか？
  - 挙動が異なる部分があるので注意.

---

class: middle, center

# 例: 凸包の計算する機能を呼び出す

[scipy.spatial.ConvexHull](https://docs.scipy.org/doc/scipy/reference/generated/scipy.spatial.ConvexHull.html)

```@example plot1
using Random # hide
using PythonCall # hide
using OffsetArrays: Origin # hide
using PythonPlot: pyplot as plt # hide

points = Origin(0, 0)(rand(Xoshiro(0), 30, 2)) # hide
ConvexHull = PythonCall.pyimport("scipy.spatial").ConvexHull # hide
hull = ConvexHull(points) # hide

fig, ax = plt.subplots() # hide
ax.plot(points[:, 0], points[:, 1], "ro") # hide
for pysimplex in hull.simplices # hide
    # Py -> PyArray  # hide
    simplex = PyArray(pysimplex) # hide
    ax.plot(points[simplex, 0], points[simplex, 1], "k-") #hide
end #hide
fig.savefig("plot1.png") #hide
nothing #hide
```

![](plot1.png)

---

# Python 版

```python
from scipy.spatial import ConvexHull
import matplotlib.pyplot as plt
import numpy as np

rng = np.random.default_rng()
points = rng.random((30, 2))   # 30 random points in 2-D
hull = ConvexHull(points)
plt.plot(points[:, 0], points[:, 1], "o")
for simplex in hull.simplices:
    plt.plot(points[simplex, 0], points[simplex, 1], "k-")
```

これの Julia 版を考える

---

# PythonCall.jl + pyimport("scipy")

```julia
using Random
using PythonCall
using OffsetArrays: Origin
using PythonPlot: pyplot as plt

# ゼロ始まりの配列を作る
points = Origin(0, 0)(rand(Xoshiro(0), 30, 2))

ConvexHull = PythonCall.pyimport("scipy.spatial").ConvexHull
hull = ConvexHull(points)

fig, ax = plt.subplots()
ax.plot(points[:, 0], points[:, 1], "ro")

for pysimplex in hull.simplices
    # pysimplex は Python オブジェクトとして見えている
    # Py -> PyArray # AbstractArray のサブタイプとしてみなす
    simplex = PyArray(pysimplex)
    # このようにしないと Indexing でエラーが起きるため
    ax.plot(points[simplex, 0], points[simplex, 1], "k-")
end

fig.savefig("plot1.png")
```

---

# PythonPlot.jl / SciPy.jl

- [SciPy.jl](https://github.com/AtsushiSakai/SciPy.jl) のバックエンドは PyCall.jl である.

```julia
using Random

using Images
using OffsetArrays: OffsetArrays, Origin
using PythonPlot: pyplot as plt
using SciPy

points = Origin(0,0)(rand(Xoshiro(0), 30, 2))
hull = SciPy.spatial.ConvexHull(points)

fig, ax = plt.subplots()
ax.plot(points[:,0], points[:,1], "o")
for simplex in eachrow(hull.simplices) # 注意
    ax.plot(points[simplex, 0], points[simplex, 1], "k-")
end
```

- SciPy.jl/PyCall.jl では `hull.simplices` の戻り値は `Matrix{Int32}` として処理される. Python 実装をリスペクトする場合は `eachrow(hull.simplices)` を回す必要がある.
- 次のページも見よ．

---

### 補足(バックエンドの差異)

```julia
 using Random, SciPy; SciPy.spatial.ConvexHull(rand(Xoshiro(0), 30, 2)).simplices |> collect
10×2 Matrix{Int32}:
 23   6
  7  17
  7   6
 13   4
 13  23
 26   5
 21  17
 21   5
 19   4
 19  26
```

```julia
julia> using Random, PythonCall
julia> ConvexHull = PythonCall.pyimport("scipy.spatial").ConvexHull
julia> ConvexHull(rand(Xoshiro(0), 30, 2)).simplices |> collect
10-element Vector{Py}:
 array([23,  6], dtype=int32)
 array([ 7, 17], dtype=int32)
 array([7, 6], dtype=int32)
 array([13,  4], dtype=int32)
 array([13, 23], dtype=int32)
 array([26,  5], dtype=int32)
 array([21, 17], dtype=int32)
 array([21,  5], dtype=int32)
 array([19,  4], dtype=int32)
 array([19, 26], dtype=int32)
```

---

# 現時点でわかってること

機械的に Python と連携するバックエンド(PyCall.jl や PythonCall.jl のこと) を置き換えるのはヤバそう.

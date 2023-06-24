class: middle, center

# PythonCall.jl 周りの話

```@example today
using Dates # hide
println("更新日: $(Dates.now())") # hide
```

{{ name }}

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
```

---

# 注意: `using PythonCall` を行う前に

- 環境変数 `JULIA_PYTHONCALL_EXE` を指定することで連携したい Python を指定することができる．
- [詳しくはこちら](https://cjdoris.github.io/PythonCall.jl/stable/pythoncall/#pythoncall-config)

```julia-repl
julia> ENV["JULIA_PYTHONCALL_EXE"]="path/to/python.exe"
```

#### PyCall.jl に慣れている場合

読者が PyCall.jl エコシステムを理解しており PyCall.jl と同じ Python を使用したい場合は下記のようにする:

```julia-repl
julia> ENV["JULIA_PYTHONCALL_EXE"]="@PyCall"
```

#### デフォルトの挙動

アクティベートしている Julia パッケージ直下に `.CondaPkg` が作られ [micromamba](https://mamba.readthedocs.io/en/latest/user_guide/micromamba.html) によって Python が導入される．




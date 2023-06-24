FROM julia:1.9.1

# create user with a home directory
ARG NB_USER=jovyan
ARG NB_UID=1000
ENV USER ${NB_USER}
ENV HOME /home/${NB_USER}

RUN adduser --disabled-password \
    --gecos "Default user" \
    --uid ${NB_UID} \
    ${NB_USER}

USER root

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    build-essential \
    python3 \
    python3-dev \
    python3-distutils \
    curl \
    ca-certificates \
    git \
    wget \
    zip \
    && \
    apt-get clean && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/* # clean up

# Dependencies for development
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    htop \
    nano \
    openssh-server \
    tig \
    tree \
    && \
    apt-get clean && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/* # clean up

# install NodeJS
RUN apt-get update && \
    curl -sL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    apt-get clean && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/* # clean up

# We need install jupyterlab with sudo user, NOT ${USER}
RUN curl -kL https://bootstrap.pypa.io/get-pip.py | python3 && \
    pip3 install \
    jupyter \
    "jupyterlab>=3,<4" \
    jupytext \
    ipywidgets \
    jupyter-contrib-nbextensions \
    jupyter-nbextensions-configurator \
    jupyter-server-proxy \
    nbconvert \
    ipykernel \
    git+https://github.com/IllumiDesk/jupyter-pluto-proxy.git \
    jupyterlab_sublime \
    jupyterlab_code_formatter autopep8 isort black \
    webio_jupyter_extension \
    webio-jupyterlab-provider \
    && \
    echo Done

WORKDIR ${HOME}
USER ${USER}

USER root
RUN mkdir -p ${HOME}/.local ${HOME}/.jupyter

RUN mkdir -p ${HOME}/.jupyter/lab/user-settings/@jupyterlab/notebook-extension && \
    echo '{"codeCellConfig": {"lineNumbers": true, "fontFamily": "JuliaMono"}}' \
    >> ${HOME}/.jupyter/lab/user-settings/@jupyterlab/notebook-extension/tracker.jupyterlab-settings

RUN mkdir -p ${HOME}/.jupyter/lab/user-settings/@jupyterlab/shortcuts-extension && \
    echo '{"shortcuts": [{"command": "runmenu:restart-and-run-all", "keys": ["Alt R"], "selector": "[data-jp-code-runner]"}]}' \
    >> ${HOME}/.jupyter/lab/user-settings/@jupyterlab/shortcuts-extension/shortcuts.jupyterlab-settings

# Modify defaultViewers
RUN wget https://raw.githubusercontent.com/mwouts/jupytext/main/binder/labconfig/default_setting_overrides.json -P  ~/.jupyter/labconfig/

RUN chown -R ${NB_UID} ${HOME}
USER ${NB_USER}

RUN mkdir -p ${HOME}/.julia/config && \
    echo '\
    # set environment variables\n\
    ENV["PYTHON"]=Sys.which("python3")\n\
    ENV["JUPYTER"]=Sys.which("jupyter")\n\
    ENV["JULIA_PYTHONCALL_EXE"] = "@PyCall"\n\
    ' >> ${HOME}/.julia/config/startup.jl && cat ${HOME}/.julia/config/startup.jl

RUN julia -e 'using Pkg; Pkg.add(["PyCall", "PythonCall"])' && \
    julia -e 'using Pkg; Pkg.add(["Revise", "LiveServer", "Pluto", "PlutoUI", "WebIO"])' && \
    julia -e 'using Pkg; Pkg.add(["BenchmarkTools", "ProfileSVG", "JET", "Cthulhu", "JuliaFormatter"])'

RUN pip3 install numpy scipy matplotlib
# Launch Revise automatically within IJulia
# https://timholy.github.io/Revise.jl/stable/config/#Using-Revise-automatically-within-Jupyter/IJulia-1
RUN mkdir -p ${HOME}/.julia/config && \
    echo '\
    try; @eval using Revise; catch e; @warn "Error initializing Revise" exception=(e, catch_backtrace()); end \n\
    ' >> ${HOME}/.julia/config/startup_ijulia.jl && cat ${HOME}/.julia/config/startup_ijulia.jl

RUN julia --threads auto -e '\
    using Pkg; \
    using Base.Threads; \
    Pkg.add("IJulia"); \
    using IJulia; \
    installkernel("Julia", "--project=@.");\
    installkernel("Julia-$(nthreads())-threads", "--project=@.", env=Dict("JULIA_NUM_THREADS"=>"$(nthreads())")); \
    ' && \
    echo "Done"

ENV JULIA_PROJECT "@."
WORKDIR /workspace/Cerastes.jl

USER root
RUN chown -R ${NB_UID} /workspace/Cerastes.jl
USER ${USER}

RUN mkdir -p /workspace/Cerastes.jl/src && echo "module Cerastes end" > /workspace/Cerastes.jl/src/Cerastes.jl
COPY ./Project.toml /workspace/Cerastes.jl

ENV PATH=${PATH}:${HOME}/.local/bin

USER root
RUN chown -R ${NB_UID} /workspace/Cerastes.jl
USER ${USER}

RUN rm -f Manifest.toml && julia -e 'using Pkg; \
    Pkg.instantiate(); \
    Pkg.precompile()' && \
    # Check Julia version \
    julia -e 'using InteractiveUtils; versioninfo()'

USER ${USER}
EXPOSE 8000
EXPOSE 8888
EXPOSE 1234

CMD ["julia"]

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

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    build-essential \
    git \
    unzip \
    wget \
    && \
    apt-get clean && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/* # clean up

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    htop \
    nano \
    openssh-server \
    tig \
    tree \
    && \
    apt-get clean && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/* # clean up

USER ${USER}

WORKDIR /workspace/Cerastes.jl

RUN julia -e 'using Pkg; Pkg.add(["Revise", "LiveServer", "Pluto", "PlutoUI"])' && \
    julia -e 'using Pkg; Pkg.add(["BenchmarkTools", "ProfileSVG", "JET", "Cthulhu", "JuliaFormatter"])'


ENV JULIA_PROJECT "@."

COPY ./src /workspace/Cerastes.jl/src
COPY ./docs/Project.toml /workspace/Cerastes.jl/docs
COPY ./Project.toml /workspace/Cerastes.jl

USER root
RUN chown -R ${NB_UID} /workspace/Cerastes.jl
USER ${USER}

RUN rm -f Manifest.toml && julia -e 'using Pkg; \
    Pkg.instantiate(); \
    Pkg.precompile()' && \
    # Check Julia version \
    julia -e 'using InteractiveUtils; versioninfo()'

WORKDIR ${HOME}
USER ${USER}
EXPOSE 8000

CMD ["julia"]

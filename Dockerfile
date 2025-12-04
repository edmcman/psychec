# Dockerfile generated from .devcontainer/devcontainer.json
FROM mcr.microsoft.com/devcontainers/base:focal

# Noninteractive frontend for apt
ENV DEBIAN_FRONTEND=noninteractive

# Install the packages configured in devcontainer.json features
# (build-essential, cmake, haskell-stack, python-is-python2)
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    haskell-stack \
    python-is-python2 \
    ca-certificates \
 && rm -rf /var/lib/apt/lists/*

# Set working directory to the repository root inside the container
WORKDIR /workspace/psychec

RUN chown -R vscode:vscode /workspace/psychec

USER vscode

# Copy minimal resolver files for cached setup of stack/GHC
# Copying only `solver/stack.yaml` and the cabal file means we can run
# `stack setup` earlier and take advantage of Docker layer caching so the
# expensive GHC download is not repeated when unrelated files change.
COPY --chown=vscode solver/stack.yaml /workspace/psychec/solver/stack.yaml
COPY --chown=vscode solver/psychecsolver.cabal /workspace/psychec/solver/psychecsolver.cabal

# Run stack setup (cached by Docker layer while `solver/stack.yaml` unchanged)
RUN cd /workspace/psychec/solver && stack setup

# Copy the rest of the project sources
COPY --chown=vscode . /workspace/psychec

# Ensure reconstruct.py is executable and run build steps similar to postCreateCommand
RUN chmod +x ./reconstruct.py \
 && cd solver && stack build && cd .. \
 && cmake . && make -j4

# Default working directory and entrypoint
WORKDIR /workspace/psychec
ENTRYPOINT ["/workspace/psychec/reconstruct.py"]

# Allow passing a file to reconstruct (example: `docker run image file.c`)
CMD ["/workspace/psychec/test.c"]

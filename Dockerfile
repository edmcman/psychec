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

# Copy the project sources
COPY . /workspace/psychec

# Ensure reconstruct.py is executable and run build steps similar to postCreateCommand
RUN chmod +x ./reconstruct.py \
 && cd solver && stack setup && stack build && cd .. \
 && cmake . && make -j4

# Default working directory and entrypoint
WORKDIR /workspace/psychec
ENTRYPOINT ["/workspace/psychec/reconstruct.py"]

# Allow passing a file to reconstruct (example: `docker run image file.c`)
CMD ["/workspace/psychec/test.c"]

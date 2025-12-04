![](https://github.com/ltcmelo/psychec/workflows/generator-build/badge.svg)
![](https://github.com/ltcmelo/psychec/workflows/solver-build/badge.svg)
![](https://github.com/ltcmelo/psychec/workflows/parser-tests/badge.svg)
![](https://github.com/ltcmelo/psychec/workflows/inference-tests/badge.svg)
![](https://github.com/ltcmelo/psychec/workflows/compilability-tests/badge.svg)


# NOTE

Psyche-C is being developed on the master branch. This branch, _original_, is inactive (it won't receive updates or fixes) and only exists because the type inference functionality of Psyche-C isn't yet available on master.

## About this fork: Docker image for using type inference

This fork includes a GitHub Actions workflow that builds a Docker image and publishes it to GitHub Container Registry (GHCR). The purpose of the Docker image is to make it easy for users and CI to exercise Psyche-C's type inference on the `original` branch (or a fork's copy of `original`) without requiring complicated Haskell environment setup.

Why the Docker image exists:
- The `original` branch depends on older Haskell tooling and system libraries that are difficult to install on modern systems.
- Building the project on a maintained developer machine can be time-consuming and error-prone.
- The Docker image packages a reproducible environment with Stack, dependencies, and the binaries built, so you can run the tools directly inside a container.

Important: The `original` branch is not actively maintained; the Docker image provides a practical workaround to use the branch's type inference features.

## Pulling and running the published image

Images are published to GHCR as `ghcr.io/<owner>/psychec:<tag>` (the workflow tags images using branch or tag names). For example, to pull the image published by the repository owner:

```
docker pull ghcr.io/edmcman/psychec-typeinference-docker:original
```

If you have your own fork, replace `edmcman` with the appropriate owner. The image is tagged by the branch name (e.g., `original`) or the tag name (e.g., `v1.2.3`) when the workflow runs on a push or release tag.

If you are maintaining a fork and want to publish images to GHCR under your account, simply enable GitHub Actions for your fork and the included workflow will authenticate using `GITHUB_TOKEN` and publish images under `ghcr.io/<your-username>/psychec` for push and tag events. You can control package visibility for your images from your GitHub package settings if you need public or private images.

To run the default `reconstruct.py` entrypoint in a container, prefer not to mount your repository root on top of the image's `/workspace/psychec` path — doing so will hide the image's prebuilt binaries and libraries and can cause runtime failures such as missing shared libraries (e.g., `libpsychecfe.so`).

Recommended usage patterns:

- Mount only specific files you want to test, instead of the entire repo (keeps image artifacts intact):

```
docker run --rm -v "$PWD/test.c":/workspace/psychec/test.c ghcr.io/edmcman/psychec-typeinference-docker:original /workspace/psychec/test.c
```

- If you must mount the full repo for local development, mount it into a different path and pass the input file path to the image so the prebuilt binaries in `/workspace/psychec` remain accessible. Example:

```
docker run --rm -v "$PWD":/host-project ghcr.io/edmcman/psychec-typeinference-docker:original /workspace/psychec/reconstruct.py /host-project/test.c
```

Note: If you mount the full project into the container and run `stack` inside the mount, you may run into permissions issues caused by mismatched UID/GID between the host user and the container build user. See the Troubleshooting section below for ways to avoid or fix that.


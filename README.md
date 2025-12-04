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
docker pull ghcr.io/edmcman/psychec:original
```

If you have your own fork, replace `edmcman` with the appropriate owner. The image is tagged by the branch name (e.g., `original`) or the tag name (e.g., `v1.2.3`) when the workflow runs on a push or release tag.

If you are maintaining a fork and want to publish images to GHCR under your account, simply enable GitHub Actions for your fork and the included workflow will authenticate using `GITHUB_TOKEN` and publish images under `ghcr.io/<your-username>/psychec` for push and tag events. You can control package visibility for your images from your GitHub package settings if you need public or private images.

To run the default `reconstruct.py` entrypoint in a container, mount a directory containing your C file and run:

```
docker run --rm -v "$PWD":/workspace/psychec ghcr.io/edmcman/psychec:original /workspace/psychec/myfile.c
```

This runs the `reconstruct.py` script inside the container with `/workspace/psychec/myfile.c` as the input file. As a convenience, the image uses `/workspace/psychec` as the repository path inside the container, so files are accessible there when mounted via `-v`.

## Advanced usage and tips

- If you need to inspect or modify the environment interactively, run a shell in the container:

```
docker run --rm -it -v "$PWD":/workspace/psychec ghcr.io/edmcman/psychec:original bash
```

- To create a reproducible CI step that uses this image, use `docker pull` then run commands against the image in your workflow.

- Multi-arch and caching: the workflow supports adding platforms and layer cache settings. If you'd like multi-arch builds (e.g., `linux/amd64,linux/arm64`), we can add that to the GitHub Actions workflow.

- Tagging policy: push tags with `vX.Y.Z` to publish versioned images. The workflow also publishes images when changes are pushed to the defined branches.

If you need help or have a preferred tag/visibility or publishing policy, tell me and I will update the workflow and README accordingly.

To infer the types of an incomplete C program (or program fragment):

<img width="473" alt="Screen Shot 2022-02-20 at 09 43 12" src="https://user-images.githubusercontent.com/2905588/154843011-ea519d92-0c72-41f9-87e2-e4f6f3cc6214.png">

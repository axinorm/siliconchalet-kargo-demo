# Silicon Chalet - Kargo demo

## Prerequisites

* **Docker** or another **container runtime**: To run containers
* **kind**: To quickly bootstrap a Kubernetes cluster

## Setup demo

### Download Kargo binary

The Kargo binary is required for the demo in order to deploy configuration such as ``Stage``.

You can download it with the following commands:

```sh
KARGO_VERSION=1.0.3
ARCH=$(uname -m)
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
[ "$ARCH" = "x86_64" ] && ARCH=amd64
curl -L -o ./bin/kargo https://github.com/akuity/kargo/releases/download/v${KARGO_VERSION}/kargo-${OS}-${ARCH}
chmod +x ./bin/kargo
```

Don't forget to add the ``./bin`` path in your global **PATH** variable. For example: ``export PATH=$PATH:$PWD/bin``.

### Helm demo

The Helm demo must be pushed into a **new** Git repository where you can generate a token with write access.

To do so, you need to create a Git repository with the following commands for the Helm application:

```sh
cd ./helm
rm -rf .git

git init --initial-branch=main

git config user.name "" # To be completed
git config user.email "" # To be completed

git add .
git commit -m <COMMIT MESSAGE> # To be completed

git remote add origin <REPOSITORY> # To be completed
git push origin main

cd -
```

And add these variables to the ``.envrc`` file or in your shell environment, and generate a token (with **read** and **write** repository access) to let Kargo write changes to Git:

```sh
export REPOSITORY_URL= # To be completed: The URL of the Helm code repository
export GITHUB_USERNAME= # To be completed: Git repository username
export GITHUB_PAT= # To be completed: The Personal Access Token
```

For the token, especially in GitHub, you can use a fine-grained token restricted to your repository with the following permissions:

* Contents: Read and write
* Metadata: Read-only
* Pull requests: Read and write

### Run Kargo demo

Some scripts are available to run Kargo demo:

```sh
# Create Kubernetes cluster
kind create cluster --config ./kind/kind-cluster.yaml --name siliconchalet-kargo
# Install Argo CD, Kargo and their dependencies
./install-cluster.sh
# Run demo
./kargo-demo.sh
```

If you want to clean the demo, you can execute the ``clean-demo.sh`` script and ``kind delete cluster --name siliconchalet-kargo`` to delete the Kubernetes cluster.

## Blog posts

Don't hesitate to read the following blog posts to find out more about Kargo:

* [Kargo, deploy from one environment to another with GitOps](https://blog.filador.fr/en/posts/kargo-deploy-from-one-environment-to-another-with-gitops/) - English version
* [Kargo, déployez d'un environnement à l'autre en mode GitOps](https://blog.filador.fr/posts/kargo-deployez-dun-environnement-a-lautre-en-mode-gitops/) - French version

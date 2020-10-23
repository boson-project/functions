# Boson Functions: A Step By Step Tutorial

This document will walk you step by step through the process of creating,
editing, and deploying a Boson Function project.

## Prerequisites

In order to follow along with this tutorial, you will need to have a few tools
installed.

* [oc][oc] or [kubectl][kubectl] CLI
* [kn][kn] CLI
* [Docker][docker] 

[docker]: https://docs.docker.com/install/
[oc]: https://docs.openshift.com/container-platform/4.2/cli_reference/openshift_cli/getting-started-cli.html#cli-installing-cli_cli-developer-commands
[kubectl]: https://kubernetes.io/docs/tasks/tools/install-kubectl/
[kn]: https://knative.dev/docs/install/install-kn/

## Cluster Setup

To use Boson Functions, you'll need a Kubernetes cluster with Knative Serving
and Eventing installed. If you have a recent version of OpenShift, you can
simply install the Serverless Operator. If you don't have a cluster already,
you can create a simple cluster with [kind](https://kind.sigs.k8s.io/). Follow
these [step by step instructions](kind-setup.md) to install on your local
machine.

## Boson Tooling

The primary interface for Boson project is the `faas` CLI.
[Download][faas-download] the most recent version and install it some place
within your `$PATH`.

[faas-download]: https://github.com/boson-project/faas/releases

```sh
# Be sure to download the correct binary for your operating system
curl -L -o - faas.gz https://github.com/boson-project/faas/releases/download/v0.8.0/faas_linux_amd64.gz | gunzip > faas && chmod 755 faas
sudo mv faas /usr/local/bin
```
## Configuring a Container Repository

The unit of deployment in Boson Functions is an [OCI](https://opencontainers.org/)
container image, typically referred to as a Docker container image.

In order for the `faas` CLI to manage these containers, you'll need to be
logged in to a container registry. For example, `docker.io/lanceball`


```bash
# Typically, this will log you in to docker hub if you
# omit <repository.url>. If you are using a repository
# other than Docker hub, provide that for <repository.url>
docker login -u lanceball -p [redacted] <repository.url>
```

> Note: many of the `faas` CLI commands take a `--repository` argument.
> Set the `FAAS_REPOSITORY` environment variable in order to omit this
> parameter when using the CLI.

```bash
# This should be set to a repository that you have write permission
# on and you have logged into in the previous step.
export FAAS_REPOSITORY=docker.io/lanceball
```

## Creating a Project

With your Knative enabled cluster up and running, you can now create a new
Function Project. Let's start by creating a project directory. Function names
in `faas` correspond to URLs at the moment, and there are some finicky cases
at the moment. To ensure that everything works as it should, create a project
directory consisting of three URL parts. Here is a good one.

```bash
mkdir fn.example.io
cd fn.example.io
```

Now, with one command we will create the project files, build a container, and
deploy the function as a Knative service.


```bash
faas create -l node
```

This will create a Node.js Function project in the current directory accepting
all of the defaults inferred from your environment, for example`$FAAS_REPOSITORY`.
When the command has completed, you can see the deployed function.

```bash
kn service list
NAME            URL                                          LATEST                  AGE   CONDITIONS   READY   REASON
fn-example-io   http://fn-example-io.faas.127.0.0.1.nip.io   fn-example-io-ngswh-1   24s   3 OK / 3     True
```

Clicking on the URL will take you to the running function in your cluster. You
should see a simple response.

```json
{"query": {}}
```

You can add query parameters to the request to see those echoed in return.

```console
curl "http://fn-example-io.faas.127.0.0.1.nip.io?name=tiger"
{"query":{"name":"tiger"},"name":"tiger"}
```

## Local Development
The `faas create` command also results in a docker container that can be run
locally with container ports mapped to localhost.

```bash
faas run
```

For day to day development of the function, you can also run it locally outside
of a container. For this project, using Node.js, you have the following commands
available. Note that to run this function locally, you will need Node.js 12.x or
higher, and the corresponding npm.

```bash
npm install # Installs all dependencies
npm test # Runs unit and integration test suites
npm run local # Execute the function on the local host
```

## Deploying to a Cluster - Step by Step

With `faas create` you have already deployed to a cluster! But there was a lot
of magic in that one command. Let's break it down step by step using the
`faas` CLI to take each step in turn.

First, let's delete the project we just created.

```bash
faas delete
```

You might see a message such as this.

```bash
Error: remover failed to delete the service: timeout: service 'fn-example-io' not ready after 30 seconds.
```

If you do, just run `kn service list` to see if the function is still deployed.
It might just take a little time for it to be removed.

Now, let's clean up the current directory.

```bash
rm -rf *
```

### `faas init`

To create a new project structure without building a container or deploying to a
cluster, use the `init` command.

```bash
faas init -l node -t http
```

You can also create a Quarkus or a Golang project by providing `quarkus` or `go`
respectively to the `-l` flag. To create a project with a template for
CloudEvents, provide `events` to the `-t` flag.

### `faas build`

To build the OCI container image for your function project, you can use the
`build` command.

```bash
faas build
```

This creates a runnable container image that listens on port 8080 for incoming
HTTP requests.

### `faas deploy`

To deploy the image to your cluster, use the `deploy` command. You can also use
this command to update a Function deployment after making changes locally.

```bash
faas deploy
```

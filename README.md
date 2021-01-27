# Boson Project

Boson Project is a collection of tooling that enables developers to create and
run Functions on Kubernetes as a Knative service. Boson exposes Function
templates capable of responding to CloudEvents produced by Knative Eventing, or
simple HTTP functions.

This repository is a directory of information and resources for the project.

## Quick links

* [Frequently asked questions](FAQ.md)
* [Tutorial](tutorial.md)
* [Kind cluster setup](kind-setup.md)
* [CLI Download](https://github.com/boson-project/func/releases)

## Using Boson Functions

To get started using Boson Functions follow the
[step by step tutorial](tutorial.md). For OpenShift Serverless Functions Test
Day, please follow the [Test Day Guide](testing.md).

### Feedback

If you encounter a bug, usability issue, or have other feedback to provide,
please feel free to
[create an issue](https://github.com/boson-project/functions/issues).

## Components

The major components of the Boson Project are:

* Function
  [runtime templates](https://github.com/boson-project/func/tree/main/templates)
  for Go, Node.js and Quarkus. The runtime is responsible for managing incoming
  CloudEvents or HTTP connections, and invoking the user function.
* [Buildpacks](https://github.com/boson-project/buildpacks) for Go, Node.js and
  Quarkus. The buildpacks are based on the CNCF Buildpack specification and
  automate the process of converting a user's function from source code into a
  runnable OCI image.
* A [CLI](https://github.com/boson-project/func) for creating and managing
  functions as a Knative Service. The CLI may be run standalone in
  vanilla Kubernetes environments, and it is also available as a compiled plugin
  for `kn` in the OpenShift Serverless Functions product.
* A Kubernetes cluster with Knative Serving and Eventing installed

## Provisioning a Cluster

If you don't already have an OpenShift cluster with Serverless installed, or a
Kubernetes cluster with Knative Serving and Eventing, you can follow our
[Getting Started with Kubernetes Guide](https://github.com/boson-project/func/blob/main/docs/getting_started_kubernetes.md)
to provision a cluster for function deployment. Or for a quick and easy set up,
follow our instructions for setting up a [kind cluster](kind-setup.md) on your
local system.

## Support

Boson Project are project from Red Hat that creates Functions based on Knative.


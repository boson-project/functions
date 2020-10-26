# Test Day

The CLI may be used either as a plugin for `kn`, as distributed in OpenShift
Serverless Functions, or on its own by downloading a binary for either Linux,
OSX or Windows from the
[project repository](https://github.com/boson-project/faas/releases/). For Test
Day, please use the `kn` binary that was recently
[created by Warren](http://download.eng.bos.redhat.com/staging-cds/developer/openshift-serverless-clients/0.17.2-1/signed/).
This document is written assuming that you are using the `kn` CLI with Functions
capabilities as provided by OpenShift Serverless. To follow along in this
document using the `boson-project/faas` distribution, simply execute the
commands _without_ the preceding `kn`. For example the following command which
initializes a new Node.js Function project that responds to CloudEvents looks
almost exactly the same.

***OpenShift Serverless Functions***
```
kn faas init -l node -t events
```

***Boson Project***
```
faas init -l node -t events
```

## Prerequisites

In order to use the CLI, the following prerequisites must be met.

* You must have access to a Kubernetes cluster with Knative Serving and Eventing
  installed. Ideally, this should be an instance of OpenShift version 4.6.x. The
  easiest way to do this is to use `clusterbot` on Slack. It is beyond the scope
  of this document to document enabling Knative Serving and Eventing in a given
  Kubernetes `namespace`. Please see the
  [OpenShift documentation](https://srvke-486--ocpdocs.netlify.app/openshift-enterprise/latest/serverless/installing_serverless/installing-openshift-serverless.html)
  for additional resources.
* You must have access to an image registry such as docker.io. Function project
  images are pushed to a repository at this registry when they are created. If
  you are using quay.io, you need to be sure to make the repository public the
  first time you build time project.
* You must have a Docker API compatible daemon running on your local system. See
  the Docker ["Get Started"](https://www.docker.com/get-started) guide if you
  need additional help.

## Scenarios

Please try to complete each of the following scenarios, noting where you ran
into trouble (if at all). In most cases, the step by step commands are not
listed because we would like to understand how easy it is to get started with
Serverless Functions by simply using the CLI and reading the help text.


### Create a function that responds to HTTP and deploy it

The first scenario should get you comfortable with creating a Function project
and deploying it to an OpenShift cluster. Using the `kn` CLI, create a new
project with `faas init`. You can choose between Node.js, Quarkus and Go for
your project using the `-l` flag.

#### Steps

1. Initialize the function project using the `kn` CLI
   (`kn faas init -l <node|quarkus>`)
1. Build the function using the `kn` CLI (`kn faas build`)
1. Run the function locally (`kn faas run`)
1. Visit http://localhost:8080 to ensure the function is working
1. Deploy the function to OpenShift using the `kn` CLI (`kn faas deploy`)

#### Validation

Once the function has been deployed, obtain the URL using the `kn service list`
and visit the function in your browser. Ensure there are no errors.
# Test Day

The CLI may be used either as a plugin for `kn`, as distributed in OpenShift
Serverless Functions, or on its own by downloading a binary for either Linux,
OSX or Windows from the
[project repository](https://github.com/boson-project/faas/releases/). For Test
Day, please use the `kn` binary provided with OpenShift 4.6.x. This document is
written assuming that you are using the `kn` CLI with Functions capabilities as
provided by OpenShift Serverless. To follow along in this document using the
`boson-project/faas` distribution, simply execute the commands _without_ the
preceding `kn`. For example the following command which initializes a new
Node.js Function project that responds to CloudEvents looks almost exactly the
same.

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
  installed. Ideally, this should be an instance of OpenShift version 4.6.x. It
  is beyond the scope of this document to document enabling Knative Serving and
  Eventing in a given Kubernetes `namespace`. Please see the
  [OpenShift documentation](https://srvke-486--ocpdocs.netlify.app/openshift-enterprise/latest/serverless/installing_serverless/installing-openshift-serverless.html)
  for additional resources.
* You must have access to an image registry such as docker.io. Function project
  images are pushed to a repository at this registry when they are created. If
  you are using quay.io, you need to be sure to make the repository public the
  first time you build time project.
* You must have a Docker API compatible daemon running on your local system. See
  the Docker ["Get Started"](https://www.docker.com/get-started) guide if you
  need additional help.
  
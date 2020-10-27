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


### Create a function that responds to HTTP

The first scenario should get you comfortable with creating a Function project.
Using the `kn` CLI, create a new project with `kn faas init`. You can choose
between Node.js, Quarkus and Go for your project using the `-l` flag.

For more details on the `faas init` command, check the
[documentation](https://github.com/boson-project/faas/blob/main/docs/commands.md#init)
or try `kn faas help init`.

#### Steps

1. Create a project directory and `cd` into it.
   ```
   mkdir myfunc
   cd myfunc
   ```
1. Initialize the function project using the `kn` CLI.
   ```
   kn faas init -l <node|quarkus>
   ```

#### Validation

After you have created the project, examine the contents of the project
directory. There should be typical project files for the kind of project you
created. For example, a `package.json` and `index.js` file for a Node.js
project. There will also be a `faas.yaml` file containing metadata about
the project.

You should be able to use local tooling to build and run the project.

### Build a Function project

In this scenario, you will build your Function project on the local system.
You will need to have a Docker daemon running on your local computer. Building
a Function project results in an OCI container image.

#### Steps

1. Initialize a Function project or re-use an existing project from the first
   scenario.
1. Build the project
   ```
   faas build
   ```
1. Provide a container registry location where you have permission to create
   images. This will typically be, for example, a personal Docker Hub or Quay.io
   account. You will be prompted for this value.  
   ```
   docker.io/<your username>
   ```

#### Validation

You can check for the image locally using the `docker` CLI.

```
docker image ls (grep image: faas.yaml | cut -d/ -f2-3)
```

### Edit a function locally with live reload

#### Steps

#### Validation

#### Cleanup

### Add tests to a function project

#### Steps

#### Validation

#### Cleanup

### Update a deployed function

#### Steps

#### Validation

#### Cleanup

### Add an external dependency to a function

#### Steps

#### Validation

#### Cleanup

### List deployed functions

#### Steps

#### Validation

#### Cleanup

### Check liveness and readiness paths for a function

#### Steps

#### Validation

#### Cleanup

### Create a function that responds to CloudEvents and deploy it

This scenario is different than the one above in that you will now create a
Function project that can receive and respond with CloudEvents. To create a new
project that can respond to events, use the `-t` flag. For example,
`kn faas init -l node -t events` will create a new Function project in Node.js
that can respond to CloudEvents. You can choose between Node.js, Quarkus and Go
for your project using the `-l` flag.

For more details on the `faas init` command, check the
[documentation](https://github.com/boson-project/faas/blob/main/docs/commands.md#init)
or try `kn faas help init`.

#### Steps

1. Initialize the function project using the `kn` CLI
   (`kn faas init -l <node|quarkus> -t events`)
1. Build the function using the `kn` CLI (`kn faas build`)
1. Run the function locally (`kn faas run`)
1. Visit http://localhost:8080 to ensure the function is working
1. Deploy the function to OpenShift using the `kn` CLI (`kn faas deploy`)

#### Validation

Once the function has been deployed, obtain the URL using the `kn service list`
and visit the function in your browser. Ensure there are no errors.

#### Clean up

When you have finished this scenario, you can remove the deployed function using
`kn faas delete` from the Function project directory. You may also choose to
keep this deployment around for some of the next scenarios.

### Connect a Knative event source to a deployed function

For this scenario, you will need to have a Function that responds to CloudEvents
already deployed. You may follow the previous scenario to achieve this if you
have not already. You will be connecting a Knative event source to your deployed
function using the Dev Console.


#### Steps


#### Validation


#### Clean up



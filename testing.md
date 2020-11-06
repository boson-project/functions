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
creates a new Node.js Function project that responds to CloudEvents looks
almost exactly the same.

***OpenShift Serverless Functions***
```
kn faas create -l node -t events
```

***Boson Project***
```
faas create -l node -t events
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
* Finally, the namespace you are using must have the Knative default broker and
  an event source. If these are not already there (you can check the Topology
  screen from the Developer perspective), use the following commands, or download
  a [small script](namespace-setup.sh) to run locally that will do this for you.
  ```
  oc new-project <yournamespace>
  kn broker create default
  kn source ping create my-ping --data '{ "name": "PingSource" }' --sink broker:default
  ```

## Scenarios

Please try to complete each of the following scenarios, noting where you ran
into trouble (if at all).

For more details on the CLI commands, check the
[documentation](https://github.com/boson-project/faas/blob/main/docs/commands.md#create)
or try `kn faas help create`.

### Create a function that responds to HTTP

The first scenario should get you comfortable with creating a Function project.
Using the `kn` CLI, create a new project with `kn faas create`. You can choose
between Node.js, Quarkus and Go for your project using the `-l` flag.

#### Steps

1. Create a project directory and `cd` into it.
   ```
   mkdir myfunc
   cd myfunc
   ```
1. Create the function project using the `kn` CLI.
   ```
   kn faas create -l <node|quarkus>
   ```

#### Validation

After you have created the project, examine the contents of the project
directory. There should be typical project files for the kind of project you
created. For example, a `package.json` and `index.js` file for a Node.js
project. There will also be a `faas.yaml` file containing metadata about
the project.

You should be able to use local tooling to build and run the project.

---

### Run a Function project on your local system

In this scneario, you will run your Function project locally, installing
dependencies and listening on local network ports. You should be sure that you
don't have anything else currently listening to port 8080, and that you already
have the necessary developer tooling for the runtime you are using. For example,
a Node.js Function will require Node.js version 12 or greater, along with npm. A
Quarkus Function project will require Maven and a JDK.

#### Steps

1. Create a Function project or re-use an existing project from the first
   scenario.
1. (Node.js) Start the project
   ```
   npm run local
   ```
1. (Quarkus) Start the project
   ```
   ./mvnw quarkus:dev
   ```

#### Validation

**Node.js:** To validate this scenario, browse to http://localhost:8080. You should see the
server accept your request in the server logs, and the browser should display
some non-error text. 

**Quarkus** For a Quarkus function, you must send an HTTP POST request to the
function at the URL http://localhost:8080/echo.

```
URL=http://localhost:8080/echo
curl -v ${URL} \
  -H "Content-Type:application/json" \
  -d "{\"name\": \"$(whoami)\"}\""
```

---

### Test a Function project locally

In this scenario, you will run the provided tests for your Function project. The
templates include a small number of tests to help you get started writing your
own. As a first step, run the existing tests. For Node.js Function projects you
will first need to install some dependencies.

#### Steps

1. Create a Function project or re-use an existing project from the first
   scenario.
1. (Node) Install dependencies
   ```
   npm install
   ```
1. (Node) Run the tests
   ```
   npm test
   ```
1. (Quarkus) Run the tests
   ```
   ./mvnw test
   ```

#### Validation

The tests should complete without failure, error messages or warnings.

---

### Build a Function project

In this scenario, you will build your Function project as an OCI container image
which may eventually be deployed into a Kubernetes/OpenShift cluster. You will
need to have a Docker daemon running on your local computer.

#### Steps

1. Create a Function project or re-use an existing project from the first
   scenario.
2. Build the project
   ```
   kn faas create
   ```
3. Provide a container registry location where you have permission to create
   images. This will typically be, for example, a personal Docker Hub or Quay.io
   account. You will be prompted for this value or you can set it via
   `FAAS_REGISTRY` environment variable.
   ```
   docker.io/<your username>
   ```
   or
   ```
   export FAAS_REGISTRY=docker.io/<your username>
   ```
4. -Optional- Try jvm and native buiild for Quarkus 
   ```
   kn faas build --builder native 
   ```
   ```
   kn faas build --builder jvm
   ```


#### Validation

You can check for the image locally using the `docker` CLI.

```
docker image ls (grep image: faas.yaml | cut -d/ -f2-3)
```

---

### Edit a function locally with live reload

#### Steps

#### Validation

#### Cleanup

---

---
### Deploy the function to the OpenShift Cluster

#### Steps
1. Make sure you are logged onto the OpenShift Cluster from your local machine.
2. Create and build a new image for Functions or reuse the previously created function image. ( If you are using quay.io, make sure the repo is public before attempting this step)
3. Use the CLI to deploy the function as a knative service on the OpenShift Cluster. 
```
kn faas deploy
```

#### Validation
Use the following command to confirm the deployed functions. 
 ```
 kn faas list
 ```
 OR 
 ```
 kn service list
 ```

You can also see it on the Dev Console

#### Cleanup
When you have finished this scenario, you can remove the deployed function using
`kn faas delete` from the Function project directory. You may also choose to
keep this deployment around for some of the next scenarios.

### Create a function that responds to CloudEvents and deploy it

This scenario is different than the one above in that you will now create a
Function project that can receive and respond with CloudEvents. To create a new
project that can respond to events, use the `-t` flag. For example,
`kn faas create -l node -t events` will create a new Function project in Node.js
that can respond to CloudEvents. You can choose between Node.js and Quarkus for
your project using the `-l` flag.

#### Steps

1. Create the function project using the `kn` CLI.
   ```
   kn faas create -l <node|quarkus> -t events
   ```
1. Build the function using the `kn` CLI.
   ```
   kn faas build
   ```
1. Run the function locally using the `kn` CLI.
   ```
   kn faas run
   ```
1. Deploy the function to OpenShift using the `kn` CLI.
   ```
   kn faas deploy
   ```

#### Validation

Once the function has been deployed, check it's status with `kn service list`.
You should see no errors. Get the URL for the Knative Service from the output
and send a request using `curl`.

```
export URL=<URL from kn service list>
curl -X POST -d '{"name": "Tiger", "customerId": "0123456789"}' \
  -H'Content-type: application/json' \
  -H'Ce-id: 1' \
  -H'Ce-source: cloud-event-example' \
  -H'Ce-type: dev.knative.example' \
  -H'Ce-specversion: 1.0' \
  $URL
```

#### Clean up

When you have finished this scenario, you can remove the deployed function using
`kn faas delete` from the Function project directory. You may also choose to
keep this deployment around for some of the next scenarios.

---

### Modify and update a deployed function

In this scenario you will updat an already deployed function. If you do not
already have a function deployed to a cluster, please follow the immediately
preceding scenario to do so.

#### Steps

1. Modify the Function project locally. You can choose to make code changes,
   add a dependency, or any other kind of change you would typically make to 
   a project.
1. Deploy the updates to the cluster using the `kn` CLI. This will build a new
   container image and update your previously deployed function.
   ```
   faas deploy
   ```

#### Validation

Using `kn service list` obtain the URL for your service and invoke it using the
`curl` command in the previous scenario. Ensure that the changes you made were
applied

---

### List deployed functions

Now that you have one or more Function projects deployed, you can list the
deployed Functions using the `kn` CLI.

#### Steps

1. List the deployed functions with `kn`
   ```
   kn faas list
   ```

#### Validation

You should see all of your deployed functions listed. Other functions that you
may have created but not yet deployed should not be listed.

---

### Check liveness and readiness paths for a function

All Function projects expose liveness and readiness URLs for the deployed Service.
Ensure that these are active by visiting them in your browser.

#### Steps

1. Ensure that you already have a Function project deployed from one of the
   previous scenarios
1. Obtain the URL for the deployed Function using the `kn` CLI
   ```
   kn service list
   ```

#### Validation

1. Browse to the URL returned with the following paths appended:
   `/health/readiness` and `/health/liveness`. They should respond with
   `200 OK`.

---

### Connect a Knative event source to a deployed function

For this scenario, you will need to have a Function that responds to CloudEvents
already deployed. You may follow the previous scenario to achieve this if you
have not already. You will be connecting a Knative event source to your deployed
function using the Dev Console.

#### Steps

1. Open the Dev Console and navigate to the Developer Topology view
1. There should already be a PingSource event emitter in your Topology
1. Use click the small blue arrow that appears on the PingSource when you hover
   over it, and drag it to your Function service.

#### Validation

1. In the Dev Console, examine the logs of your Function service. You should see
   data from the PingSource once per minute appear in the logs.



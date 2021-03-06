Serverless Functions FAQ
========================

Serverless Functions frequently asked questions.


## What are Serverless Functions?

Serverless Functions are a collection of tools that enable developers to create
and run functions as a Knative Service on Kubernetes. The major components of
this project are listed here.

* Function runtimes for Go, Node.js, SpringBoot and Quarkus
* Buildpacks for Go, Node.js, SpringBoot and Quarkus
* A CLI for creating and managing functions as a Knative Service
* Knative Serving and Eventing as the platform on which it all runs

## How mature is the Serverless Functions Project?

OpenShift Serverless Functions are currently in Developer Preview.

## How does this project relate to Knative?

Knative is the target deployment platform for Serverless Functions.

## How do I Use Serverless Functions?

For Function projects, a developer uses the `kn func` CLI for project creation
and deployment.  Developers use this CLI to create new function projects and
deploy them to a Kubernetes cluster running Knative Serving and Eventing.
During deployment, the developer's function code is combined with a runtime
framework (for example Quarkus or Node.js) using the CNCF Buildpack APIs to
create a runnable OCI container.

To get started using Serverless Functions now, please follow the [step by step
tutorial](tutorial.md).

## How does a Function Project get built?

The `kn func` CLI uses the CNCF Buildpack API to create a container image. The
[buildpacks](https://github.com/boson-project/buildpacks/) are based on and
extend Red Hat UBI 8 and UBI 8 Minimal images.

![Boson Project Build](assets/init-build.png)

## How is a Function Project deployed?

Once a container image has been created, the CLI can deploy it as a Knative
service on the cluster currently active in the developer's Kubernetes
configuration.

## How are Serverless Functions invoked?

Serverless Functions are deployed as Knative Services, so they are invoked by
simple HTTP requests. These HTTP requests may be sent directly from external
sources via Kubernetes ingress, or they may be invoked from within the cluster
by the Knative Event Broker. All function runtimes currently expose a raw HTTP
invocation capability as well as a `CloudEvent` invocation signature.

## How do Serverless Functions subscribe to events?  

Events in the Knative platform are exposed to Serverless Functions via Knative
`Triggers`. A function project expresses its interest in events of a specific
type or from a specific source via a `Trigger`. Subsequently, the Knative event
Broker will route these events to a function, invoking it with an HTTP POST
request comprised of a `CloudEvent`.

## What does a Function look like?

Functions are simply that - functions. They are written in either Go,
Node.js or Java/Quarkus. The `kn func` CLI can create a Boson Function
project using a
[template](https://github.com/boson-project/func/tree/main/templates) which
provides the overall structure for your function. Here is a simple example
function, written in Node.js.

```js
function handleCustomer(customer, context) {
  if (!customer) {
    return new Error('No customer received');
  }
  context.log.debug(`Cloud event received: ${JSON.stringify(context.cloudevent)}`);
  // do something with `customer`
  const result = processCustomer(customer);

  return {
      customer,
      result
  }
};

module.exports = handleCustomer;
```

This function is expected to be invoked with data from a `CloudEvent` as the
first parameter. To access the raw HTTP request, there are properties on the
`context` object that is provided. For example,

```js
function invoke(context) {
  context.log.info(`Handling HTTP ${context.httpVersion} request`);
  if (context.method === 'POST') {
    return handlePost(context);
  } else if (context.method === 'GET') {
    return handleGet(context);
  } else {
    return { statusCode: 451, statusMessage: 'Unavailable for Legal Reasons' };
  }
}

function handlePost(context) {
  return {
    body: context.body,
    name: context.body.name
  }
};

function handleGet(context) {
  return {
    query: context.query,
    name: context.query.name,
  }
};
```

A Function project may contain more than a single function. Howver, only the
function exported from `index.js` will be invoked.

## Additional Examples

### Quarkus Example
  
```java
package com.example;
  
public class Functions {
  // To expose the function just add `@Funq` annotation.
  // The input/output type should be either primitive type or Java Bean.
  @Funq
  public String toLowerCase(String val) {
    return val.toLowerCase();
  }
}
```

### Go Raw HTTP Example
  
```go
package function

import (
  "context"
  "fmt"
  "net/http"
  "os"
)

// The function has to be named `Handle` and it has to be in the`function` package.
// Handle an HTTP Request.
// The `ctx` param is optional.
func Handle(ctx context.Context, res http.ResponseWriter, req *http.Request) {

  res.Header().Add("Content-Type", "text/plain")
  res.Header().Add("Content-Length", "3")
  res.WriteHeader(200)

  _, err := fmt.Fprintf(res, "OK\n")
  if err != nil {
    fmt.Fprintf(os.Stderr, "error or response write: %v", err)
  }
}
```
  
### Go CloudEvent Example
  
```go
package function

import (
  "context"
  "fmt"
  "os"

  cloudevents "github.com/cloudevents/sdk-go/v2"
)

// The function has to be named `Handle` and it has to be in the`function` package.
// Handle a CloudEvent.
// Valid fn signatures are:
// * func()
// * func() error
// * func(context.Context)
// * func(context.Context) protocol.Result
// * func(event.Event)
// * func(event.Event) protocol.Result
// * func(context.Context, event.Event)
// * func(context.Context, event.Event) protocol.Result
// * func(event.Event) *event.Event
// * func(event.Event) (*event.Event, protocol.Result)
// * func(context.Context, event.Event) *event.Event
// * func(context.Context, event.Event) (*event.Event, protocol.Result)
func Handle(ctx context.Context, event cloudevents.Event) error {
  if err := event.Validate(); err != nil {
    fmt.Fprintf(os.Stderr, "invalid event received. %v", err)
    return err
  }
  fmt.Printf("%v\n", event)
  return nil
}
```

## What are typical use cases for Functions?

There are varieties of application types and user stories that could be
acheived using Functions.  Even Driven is the pattern that is at heart of the
Functions and any Event Driven architecture could benefit from it.  Some
examples are:

* E-Commerce website:
- Function for Authentication that could show a personalized page.
- Function for cart management
- Function for payment management
- Function for Recommendation
- Cashless Payment System

* Media File Processing:
- Change the format of Files
- Generating thumbnails version of images
- Uploading thumbnails version of images to profile/dashboard

* Data Transformation
- Adding metadata to existing data
- Combining data from another source
- Converting the format of the data
- Restructuring the data
- Normalization of the data

* Scheduled Jobs
* ChatBot
* IoT backend
* Machine Learning data analytics
* Stream processing

## Can I write stateful functions?

Currently Serverless Functions are strictly stateless.

## What languages/framework can I use for my functions?

Serverless Functions are available Quarkus, SpringBoot, Node.js and Go.

## What events can trigger a function?

Serverless Functions may be invoked either by standard HTTP requests, or
invocation via [`CloudEvents`](https://cloudevents.io/) from a Knative event
source.


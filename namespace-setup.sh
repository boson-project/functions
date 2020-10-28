#!/bin/sh

echo "Hello, and thank you for agreeing to participate in Functions Test Day!
Please provide your Red Hat username, and a namespace will be created and configured for you."
echo -n "username: "

read username

echo "Creating namespace ${username}"
oc new-project ${username}

echo "Injecting default Knative broker"
oc label namespace ${username} eventing.knative.dev/injection=enabled

echo "Creating a PingSource for events"
kn source ping create my-ping --schedule "* * * * *" --data '{ "name": "PingSource" }' --sink broker:default

echo "Done! Your cluster is now ready for testing."

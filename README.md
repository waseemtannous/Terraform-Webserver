# Terraform Webserver

Create a webserver and a database and deploy them to GCP using Terraform.

## Database

For the database, we started by making a docker image that pulls the latest Postgres image
from docker and dumps an SQL file to initialize the database.
Using the docker and google providers in terraform, we built and pushed the image to the GCR
and created a new VM instance with a container-optimized os that pulls the image from GCR
and runs it.
The database listens on port 5432, so we attached a firewall that allows network traffic using
this port.

## Server

We used the python library flask to build the server. We built a docker image that accepts the
database IP as an environment variable. Like the database image, we built and pushed it to the
GCR using terraform.
Then, we created a VM instance template that runs a container-optimized os and pulls the
server image from the GCR.
Now, we declared a managed instance group that builds new VMs using this template. We also
attached an autoscaling policy to the instance group.
Then we updated the server code. In order to push the changes to the instance group, we
started by building and pushing the new server image to GCR, created a new server template
using this new image, and replaced the old instance template used by the instance group with
the new one.

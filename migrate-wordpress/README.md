# Migrating a Wordpress to Google Cloud Platform

In this webinar we will migrate a live Wordpress site to Google Cloud Platform
(GCP), without interruption of service to end users.

Our target site is [`http://www.eclipsecorner.org`][site], a one stop shop for
your eclipse needs:

![Site Screenshot](site.png)


## Setup (before migration)

- Wordpress is running on a machine outside GCP
- Wordpress database is hosted ourside the machine running the server

> The site DNS is already being served by Google Cloud DNS (for the sake of
> simplicity and time, avoiding update root DNS servers and replication).
>
> In the beginning of the process the DNS entry `www.eclipsecorner.org` is
> pointing to the original Wordpress instance hosted outside GCP.

- Puppet Enterprise is running on GCP and has address
  [`https://pe-demo.graphite.cloudnativeapp.com`][pe-demo]


## Artifacts

- [`bootstrap.sh`][bootstrap]: A small bash script that installs Stackdriver
  Logging Agent, Puppet CA certificate (as our demo does not have a public
  certificate), and defer to Puppet Enterprise setup script to configure the
  machine.
- [`wp-create.pp`][wp-create]: The single Puppet manifest responsible to creating
  the whole GCP infrastructure.
- [`control/modules/profile`][profile]: A Puppet profile for coordinating the
  migration between the source and target machines.
- [`control/Puppetfile`][puppetfile]: The module dependencies to be installed on
  the Puppet Master.


## Migration Plan

1. On Google Cloud Platform
    - Allocate a static IP address for Wordpress
    - Create a Cloud SQL instance to host Wordpress data
      > Lockdown the SQL instance to only allow access from the Wordpress server
    - Create a Google Compute Engine machine to host the 

2. On Puppet Enterprise


[site]: http://www.eclipsecorner.org
[pe-demo]: https://pe-demo.graphite.cloudnativeapp.com
[bootstrap]: bootstrap.sh
[wp-create]: wp-create.pp
[profile]: control/modules/profile
[puppetfile]: control/Puppetfile

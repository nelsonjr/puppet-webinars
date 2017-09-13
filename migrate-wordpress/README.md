# Migrating a Wordpress to Google Cloud Platform

In this webinar we will migrate a live Wordpress site to Google Cloud Platform
(GCP), without interruption of service to end users.

Our target site is [`http://www.eclipsecorner.org`][site], a one stop shop for
your eclipse needs:

![Site Screenshot](site.png)


## Setup (before migration)

- Wordpress is running on a machine not on GCP, e.g. on-premise or on another
  cloud provider
- Wordpress database is hosted outside the machine running the server and not on
  GCP
- DNS servers for `eclipsecorner.org` hosted by Google Cloud DNS

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

## Running `wp-create.pp`

### `staging` fact
> It is imperative that `wp-create` be run at all times with the fact
> `staging=1`, otherwise the DNS records for `www.eclipsecorner.org` will be
> migrated to GCP.

- Throughout the migration: `staging=1`

    FACTER_staging=1 ... puppet apply wp-create.pp

- After migration is complete (to flip DNS): remove staging fact

    ... puppet apply wp-create.pp

### `machine_name` fact
The Puppet manifest requires a fact named `machine_name`, which specifies the
name of the machine -- and database instance -- to be created and configured as
the target Wordpress on GCP.

Example (we chose to define the fact as environment variable):

    FACTER_staging=1 FACTER_machine_name=wordpress-1 puppet apply wp-create.pp

## Migration Plan

1. On Google Cloud Platform
    - `puppet apply wp-create.pp`:
      Allocate a static IP address for Wordpress
    - `puppet apply wp-create.pp`:
      Create a Cloud SQL instance to host Wordpress data
> Lockdown the SQL instance to only allow access from the Wordpress server
    - Create a Google Compute Engine machine to host the 

2. On Puppet Enterprise


[site]: http://www.eclipsecorner.org
[pe-demo]: https://pe-demo.graphite.cloudnativeapp.com
[bootstrap]: bootstrap.sh
[wp-create]: wp-create.pp
[profile]: control/modules/profile
[puppetfile]: control/Puppetfile

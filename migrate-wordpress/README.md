# Migrating a live Wordpress to Google Cloud Platform

In this webinar we will migrate a live Wordpress site to Google Cloud Platform
(GCP), without interruption of service to end users.

Our target site is [`http://www.eclipsecorner.org`][site], a one stop shop for
your eclipse needs:

![Site Screenshot](site.png)

## Contents

- [Links](#links)
- [Setup (before migration)](#setup-before-migration)
    * [Puppet Master Setup](#puppet-master-setup)
- [Artifacts](#artifacts)
- [Dependencies](#dependencies)
    * [Modules](#modules)
    * [Files](#files)
    * Instance
        - [Security Scopes](#security-scopes)
        - [Metadata](#metadata)
- [Running `wp-create.pp`](#running-wp-createpp)
- [Migration Plan](#migration-plan)

## Links

- [Webinar & Recorded Session][migrate-wordpress-webinar]

## Setup (before migration)

- Wordpress is running on a machine not on GCP, e.g. on-premise or on another
  cloud provider
- Wordpress database is hosted outside the machine running the server and not on
  GCP
- DNS servers for `eclipsecorner.org` hosted by Google Cloud DNS

> The site DNS is already being served by Google Cloud DNS, for the sake of
> simplicity and time, and avoiding the need to update root DNS servers and
> wait for replication.
>
> In the beginning of the process the DNS entry `www.eclipsecorner.org` is
> pointing to the original Wordpress instance hosted outside GCP.

- Puppet Enterprise is running on GCP and has address
  [`https://pe-demo.graphite.cloudnativeapp.com`][pe-demo]

### Puppet Master Setup

TODO(ody): Please document this.

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

## Dependencies

### Modules

- On Admin Workstation
    * [`google/gcompute`][google-gcompute]: Configures static IP, VM instance
    * [`google/gsql`][google-sql]: Configures Cloud SQL instance and user
    * [`google/gdns`][google-dns]: Configures Cloud DNS records
    * [`google/gauth`][google-gauth]: Authorize requests to GCP

> Optionally you can install the [`google/cloud`][google-cloud] module that
> bundles all supported Google Cloud Platform products together.

- On Puppet Master
    * Refer to [`control/Puppetfile`][puppetfile] for complete list.

- On Bootstrapper
    * [`google/glogging`][google-logging]: Installs Stackdriver Logging Agent to the WP instance

### Files

- `bootstrap.sh` be available in a Google Cloud Storage bucket, or other
  verifiable HTTPS or secure location
- `puppet-ca-cert.pem` be available in a Google Cloud Storage bucket (or
  other verifiable HTTPS or secure location

### Instance

#### Security Scopes

The migration requires the following scopes to be present on the machine:

- `https://www.googleapis.com/auth/devstorage.read_only`
   to enable Cloud Storage so we can access the bootstrap.sh startup script
- `https://www.googleapis.com/auth/logging.write`
   to enable Stackdriver Logging API access and write logs

#### Metadata

- `startup-script-url`: points to the secure location of `bootstrap.sh`
- `puppet-ca-cert`: points to the location of `puppet-ca-cert.pem`
- `puppet-agent-installer`: points to the `https://` location of the Puppet
  agent install script. _For Puppet Enterprise that address is usually
  `https://{fqdn-server-name}:8140/packages/current/install.bash`._
- `database-ip-address`: points to the IP Address of the Cloud SQL instance to
  host Wordpress data. _This value is managed by `wp-create.pp`._

## Running `wp-create.pp`

### `staging` fact
> It is imperative that `wp-create` be run at all times with the fact
> `staging=1`, otherwise the DNS records for `www.eclipsecorner.org` will be
> migrated to GCP.

- Throughout the migration: `staging=1`

    ```
    FACTER_staging=1 ... puppet apply wp-create.pp
    ```

- After migration is complete (to flip DNS): remove staging fact

    ```
    ... puppet apply wp-create.pp
    ```

### `machine_name` fact
The Puppet manifest requires a fact named `machine_name`, which specifies the
name of the machine -- and database instance -- to be created and configured as
the target Wordpress on GCP.

Example (we chose to define the fact as environment variable):

    FACTER_staging=1 FACTER_machine_name=wordpress-1 puppet apply wp-create.pp

## Migration Plan
 
> Remember to run all `puppet apply wp-create.pp` with the `staging=1` fact
> defined to avoid flipping the DNS records prematurely and cause service
> interruption.

1. On Google Cloud Platform
    - Run #1: `puppet apply wp-create.pp`:
      Allocate a static IP address for Wordpress
    - Run #2: `puppet apply wp-create.pp`:
      Create a Cloud SQL instance to host Wordpress data
      > ... and lockdown the SQL instance to only allow access from the Wordpress
      > server
    - Run #3: `puppet apply wp-create.pp`:
      Create a machine to host the Wordpress server

2. On Puppet Enterprise
   - Wait for new GCE instance to come online after GCP infrastructure **Run #3**
   - After checking that a fresh Wordpress is online, pin original source
     instance to the `Migrate` node group in the `Classification` section of
     the Puppet Enterprise Console
   - Still in the `Migrate` node group, select the "Matching nodes" tab and you'll
     see the source listed.  Go to the node's page by clicking on it, you'll see
     `Run Puppet...` at the top when it loads.  Expand the dropdown and press
     `Run`
   - Once the new site has been validated, go back to the `Classification`
     section and drill into `Wordpress GCE`.  Here you'll select the `Classes`
     tab, find `staged` and change the value to **false**
   - As with the source machine, go to `Matching nodes`, select our new target,
     expand `Run Puppet...`, press `Run`

3. On Google Cloud Platform
    - Run #4: `puppet apply wp-create.pp` _(**without** `staging=1`)_:
      Flips DNS record from old legacy site to new GCP Wordpress infrastructure


[site]: http://www.eclipsecorner.org
[pe-demo]: https://pe-demo.graphite.cloudnativeapp.com
[bootstrap]: bootstrap.sh
[wp-create]: wp-create.pp
[profile]: control/modules/profile
[puppetfile]: control/Puppetfile

[google-gauth]: https://forge.puppet.com/google/gauth
[google-gcompute]: https://forge.puppet.com/google/gcompute
[google-sql]: https://forge.puppet.com/google/gsql
[google-dns]: https://forge.puppet.com/google/gdns
[google-logging]: https://forge.puppet.com/google/glogging
[google-cloud]: https://forge.puppet.com/google/cloud

[migrate-wordpress-webinar]: https://www.brighttalk.com/webcast/10619/276851

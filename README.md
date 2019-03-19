# People-Docker

This repo contains tools/configuration to build a Docker container that runs
a MySQL server instance with data from a PeopleDB production backup. It also
contains a docker-compose.yml file for running the people-search web
application together with such a PeopleDB MySQL container.

The repo includes a CircleCI configuration for running nightly jobs to
create new database containers, which are stored in an Amazon Web Services'
Elastic Container Registry (AWS ECR) repository. The docker-compose
configuration automatically retrieves the latest database container image from
this repository (see **Running docker-compose**).

The people-search web application container is also stored in an AWS ECR
repository, which is also used by the `docker-compose` configuration. The
`NCAR/people-search` GitHub repo has its own CircleCI configuration, which is
used to automatically build and push a new Docker container whenever a new
version of people-search is released.

### AWS ECR

The name of the Docker registry containing the People database and webapp images is:

    536333801959.dkr.ecr.us-east-2.amazonaws.com

Contact SWEG staff for the AWS access key ID and secret access key needed to access this registry.

Before you can pull Docker containers from the ECR, you need to login to the ECR using
the `docker login` command with appropriate credentials. The `docker-login` script
will handle this for you, provided you have either set up your `$HOME/.aws` directory with
`credentials` and `config` files, or defined the `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`
environment variables. See
[Getting Started with Amazon ECR](https://docs.aws.amazon.com/AmazonECR/latest/userguide/ECR_GetStarted.html)
for more details.

After you run `docker-login`, you will be able to pull images from the ECR for 12 hours before
having to login again. However, since docker images are normally cached on your local machine,
you don't need to pull images every time you launch a container. 

## Running docker-compose 

#### Environment Variables

The `docker-compose.yml` file uses number of optional environment variables:

Variable|Description|Default
--------|-----------|-------
PEOPLE_DB_IMAGE|Database Docker image|*registry*/people-db
PEOPLE_DB_TAG|Database image tag|latest
PEOPLE_SEARCH_IMAGE|Webapp Docker image|*registry*/people-search
PEOPLE_SEARCH_TAG|Webapp image tag|latest
PEOPLE_SEARCH_PORT|Webapp port|9080
SECRETS_DIR|Secrets directory|./secrets

You can provide alternate values for these variables in a `.env` file, which must be in the same
directory as the `docker-compose.yml` file.

#### Secrets

The `SECRETS_DIR` environment variable identifies a directory that must contain the secrets used
by the webapp and database (default=`./secrets`). Specifically, you need to set up a `pdb.rc` file
and a `people-search.rc` file in this directory and define the following variables as appropriate:

Variable|File|Description
--------|----|-----------
HR_EXPORT_ENDPOINT|people-search.rc|HR export endpoint
HR_EXPORT_PASSWORD|people-search.rc|HR export password
PDB_HOST|pdb.rc|Name of the database host (should be `db`)
PDB_PORT|pdb.rc|Network port for database server (should be 3306)
PDB_ROOT_PASSWORD|pdb.rc|Database password for MySQL root user
SAM_HOST|people-search.rc|SAM host
SAM_LOGIN|people-search.rc|SAM login name
SAM_PASSWORD|people-search.rc|SAM password
TICKET_EMAIL|people-search.rc|Email destination address when creating tickets
TICKET_SENDER_EMAIL|people-search.rc|Email sender address when creating tickets
UCAR_AUTH_HOST|people-search.rc|UCAR auth host:port (should be nauth.api.ucar.edu:443)
UCAR_AUTH_LOGIN|people-search.rc|UCAR auth login name
UCAR_AUTH_PASSWORD|people-search.rc|UCAR auth password
UCAS_EMAIL|people-search.rc|Email address for requesting UCAS account
TOMCAT_ROLE_HR_PASSWORD|people-search.rc|Tomcat user role for hr api
TOMCAT_ROLE_ADMIN_PASSWORD|people-search.rc|Tomcat user role for admin api
TOMCAT_ROLE_PEOPLESYNC_PASSWORD|people-search.rc|Tomcat user role for peoplesync api
TOMCAT_ROLE_SEC_PASSWORD|people-search.rc|Tomcat user role for sec api
TOMCAT_ROLE_EMAIL_PASSWORD|people-search.rc|Tomcat user role for email api
TOMCAT_ROLE_SAM_PASSWORD|people-search.rc|Tomcat user role for sam api
TOMCAT_ROLE_FANDA_PASSWORD|people-search.rc|Tomcat user role for fanda api
TOMCAT_ROLE_APIPEOPLE*xx*_PASSWORD|people-search.rc|Tomcat user role for admin user *xx*

Note that not all variables need to be defined if you are not using all people-search features.

#### Container Image Tags

By default, the `docker-compose` configuration will use Docker images tagged with `latest`. The
MySQL images for PeopleDB are also tagged 
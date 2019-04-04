# People-Docker

This repo contains tools/configuration to build a Docker image that contains
a MySQL server instance with data from a PeopleDB backup file. It also
contains a docker-compose.yml file for running the people-search and
people-sync web applications together with one of these PeopleDB MySQL images.

The repo includes a CodeBuild *buildspec* file for creating new database containers
and storing them in an Amazon Web Services' Elastic Container Registry (AWS ECR)
repository. The docker-compose configuration automatically retrieves the latest database
container image from this repository (see **Running docker-compose**).

The people-search and people-sync Docker images are also stored in an AWS ECR
repository, which is also used by the `docker-compose` configuration. The
`NCAR/people-search` and `NCAR/people-sync` GitHub repos have their own CircleCI
configurations, which are used to automatically build and push new Docker images
whenever new version of people-search and people-sync are released.

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
by the webapps and the database (default=`./secrets`). Specifically, you need to set up a `pdb.env` file,
and various `people*.env` files in this directory. The variables you should define are documented in the
[NCAR/people-search README](https://github.com/NCAR/people-search/blob/master/README.md)
and [NCAR/people-sync README](https://github.com/NCAR/people-sync/blob/master/README.md)
file in the `/run/secrets` sections.


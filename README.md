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
environment variables. See **Environment Variables** below, and
[Getting Started with Amazon ECR](https://docs.aws.amazon.com/AmazonECR/latest/userguide/ECR_GetStarted.html)
for more details.

After you run `docker-login`, you will be able to pull images from the ECR for 12 hours before
having to login again. However, since docker images are normally cached on your local machine,
you don't need to pull images every time you launch a container. 

### people-db image

The PeopleDB image is called `people-db`. The most recently built image is always assigned the `latest`
tag, as well as a date-time tag of the form `YYYY-mm-ddTHHMMSS` and a date tag of the form `YY-mm-dd`.

The image contains tar files for a fully initialized instance of a MySQL database containing data from a
backup. When a container is run from an image, the files are un-tarred into volumes mounted at
`var/lib/mysql` and `/var/run/mysqld`, if and only if `/var/lib/mysql` does not appear to contain
database files already. Because the tar files contain pre-initialized binary data files, start-up time
is minimal.

Passwords for the root MySQL account and for the people application account are pre-loaded into the database and
are not stored as clear text in the image. You must contact SWEG staff to obtain these passwords.

To list the `people-sync` version and tomcat version information, run the following:

    docker run --rm 536333801959.dkr.ecr.us-east-1.amazonaws.com/people-db:latest version

To list all supported configuration variables and their defaults, run the following

    docker run --rm 536333801959.dkr.ecr.us-east-1.amazonaws.com/people-db:latest configvars

### Using docker-compose 

#### Environment Variables

The `docker-compose.yml` file uses number of environment variables.

Variable|Description|Default
--------|-----------|-------
AWS_ACCESS_KEY_ID|AWS access key ID, for `docker login`|
AWS_SECRET_ACCESS_KEY|AWS secret access key, for `docker login`|
PEOPLE_DB_IMAGE|Database Docker image|*registry*/people-db
PEOPLE_DB_TAG|Database image tag|latest
PEOPLE_SEARCH_IMAGE|Webapp Docker image|*registry*/people-search
PEOPLE_SEARCH_TAG|Webapp image tag|latest
PEOPLE_SEARCH_PORT|Webapp port|9080
SECRETS_DIR|Secrets directory|.

Variables without a default are optional.

You can provide alternate values for these variables in a `.env` file, which must be in the same
directory as the `docker-compose.yml` file.

#### Secrets and Deployment-Environment-Specific Configuration Parameters

`people-db`, `people-sync`, and `people-search` docker containers all load variable
definitions from `*.env` and `.env` files in `/run/secrets`. (Refer to the `load-configvars.rc`
scripts in the application GitHub repos for details.) Because the default directory to
bind-mount as `/run/secrets` is "`.`", by default all containers will load the variables
from `compose.env` and `.env`. The `compose.env` file contains defaults that make sense
for the docker-compose configuration. The `.env` file (which is also read automatically
by docker-compose for *its* environment variables) is missing/ignored in the GitHub repo,
and is meant to be defined on the execution host at runtime. This implies that *all*
needed environment variables (those for running docker-compose and those for configuring
the applications and injecting secrets) can be specified in the `.env` file.

#### Bringing the Services Up and Down

To start the People services, `cd` to the directory containing the `docker-compose file` and
run the following command:

    docker-compose up

This will run the services in the foreground. Log messages will go to standard output. To stop
foreground containers, you can hit *CONTROL-C*.

To run the services in the background, the this instead:

    docker-compose up -d

In this case, log messages will be redirected; to display then, run

    docker-compose logs

If you see messages like the following when you try to bring the services up:

    ERROR: pull access denied for people-db, repository does not exist or may require 'docker login'
    
then you will need to run `docker login`. See the `AWS ECR` section above for details.
        
To bring the containers down, run

    docker-compose down


#### Connecting to the web application

To connect to the web application, point your browser at

    https://localhost:9443


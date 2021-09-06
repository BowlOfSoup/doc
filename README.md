doc. Personal docker helper
===

'doc' is a set of scripts to make life easier when working with docker, docker-compose and docker-sync.

It works by assuming you have a specific directory in which you put all your docker setup. E.g.: I have `~/Development/Docker` with a docker stack per subdirectory.

It heavily relies on [docker-compose](https://docs.docker.com/compose/) and [docker-sync](https://docker-sync.readthedocs.io/en/latest/).

Installation
---
**1.** Clone this repo in any directory

    git clone https://github.com/BowlOfSoup/doc.git

**2.** Add the doc directory to your path

for Bash:

    [~/.bashrc] or [~/.bash_profile]
    export PATH=/path/to/doc:$PATH

for Zsh:

    [~/.zshrc]
    export PATH=/path/to/doc:$PATH

**3.** Create a `config.ini` file, fill the variables.


    cp config.ini.dist config.ini

`config.ini` contains the following variables:
- **dockerDirectory**: path to a directory which contains directories with docker stacks/projects which should contain a `docker-compose.yml`.
You can indicate multiple root directories with the `;` separator.

Usage
---

Generic script

    doc --help

Docker helper commands:

    doc -d help

Docker-compose helper commands:

    doc -c help
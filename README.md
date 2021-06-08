# Composer Repository Mirror Kickstarter

## Setup

- Prepare a new VPS (virtual private server) and ensure the Ubuntu 18.04 or Ubuntu 20.04 has been installed.
- Login to the mirror server.
- Ensure the `git` command has been available.
- Clone this repository with `git` command then run `cd mirror-kickstarter/`.
- Update if needed the .env file (set INSTALL_PREFIX) to tell where to put the mirror
- Run `./mirror-kickstarter.sh` shell script to setup the environment.
- Create a `mirror.config.php` file on the current working directory. And it's the same directory as the `./mirror-installer.sh` file.
- Run `./mirror-installer.sh` shell script to setup the Packagist mirror repository.

## Debugging and force-resync of v2 metadata

- Run the `./mirror-debugger.sh` shell script.

## Update

- Run the `./mirror-updater.sh` shell script.

## Reference

- https://github.com/composer/mirror#composer-repository-mirror

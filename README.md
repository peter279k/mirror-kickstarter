# Composer Repository Mirror Kickstarter

## Setup

- Prepare a VPS (virtual private server) and ensure the Ubuntu 18.04 or Ubuntu 20.04 has been installed.
- Login to the mirror server.
- Ensure the `git` command has been available.
- Clone this repository with `git` command then run `cd mirror-kickstarter/`.
- Run `./mirror-kickstarter.sh` shell script.
- Create a `mirror.config.php` on `/var/www/html/mirror` folder.
- Run `./mirror-installer.sh` shell script.

## Debugging and force-resync of v2 metadata

- Run the `./mirror-debugger.sh` shell script.

## Update

- Run the `./mirror-updater.sh` shell script.

## Reference

- https://github.com/composer/mirror#composer-repository-mirror

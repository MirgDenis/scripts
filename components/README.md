### Description
Script for pulling components installed inside docker image.
It supports Yum, Apt, Apk, Pip and Gem installed packages. Also it can pull components from labels wich have specified format.

### Perquisites
Docker installed on the machine where it will be run.

### How to run
`bash ./components.sh <dockerimage_url>`

Output should look like:

Apt(Yum, Apk) packages installed:

…

Pip packages installed:

…

Gem packages installed:

…

Label components:

…

### Known issues
This script does not work for:
- Busybox based images 
- Images which consist only binaries
It will duplicate deb (and other pkg managers) installed python packages in "Deb installed" and "Python installed" section.

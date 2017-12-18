#!/bin/bash

# Made by Innovative Inventor at https://github.com/innovativeinventor.
# If you like this code, star it on GitHub!
# Contributions are always welcome.

# MIT License
# Copyright (c) 2017 InnovativeInventor

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

# Options
VERSION="1.0"

while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -h|--help)
    help=YES
    shift # past argument
    ;;
esac
done

display_help() {
    echo
    echo "Script version $VERSION"
    echo 'A tool for setting up a docker container with PiVPN'
    echo 'Usage: setup.sh <options>'
    echo 'Options:'
    echo '   -h --help                   Show help'
    echo '   -b --build                  Builds dockerfile'
    exit 1
}

setup() {
    git clone https://github.com/InnovativeInventor/docker-pivpn --depth 1


}

install_docker_mac() {
    echo "Please install docker at https://download.docker.com/mac/stable/Docker.dmg and restart this script"
}

install_docker_linux() {
    raspbian_dependencies () {
        sudo apt-get update
        sudo apt-get install -y apt-transport-https
        sudo apt-get install ca-certificates
        sudo apt-get install curl
        sudo apt-get install -y software-properties-common
        sudo apt-get install lsof
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
        sudo add-apt-repository \
        "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
        $(lsb_release -cs) \
        stable"
        sudo apt-get update
        sudo apt-get install -y docker-ce
    }
}

build_and_setup() {
    build
    docker_run_build
    pivpn_setup
}

build() {
    docker build -t pivpn .
}

docker_run_build () {
    container="$(docker run -i -d -P --cap-add=NET_ADMIN pivpn)"
    output=$(docker port "$container" 1194)
    port=${output#0.0.0.0:}
    echo Your port is $port
}

pivpn_setup() {
    # ssh root@127.0.0.1 -i "$HOME/.ssh/id_rsa" -p $port
    echo "$container"
    seed_random

    docker exec -it $container bash install.sh
    docker exec -it $container dpkg --configure -a
    docker exec -it $container bash install.sh
    echo "Done! To execute commands, type docker exec -it $container /bin/bash"
    echo "Your openvpn port should be $port"
}

seed_random() {
    rand="$(openssl rand -base64 100000)"
    docker exec -it $container echo "$rand" >> /dev/random
}

# Help option
if [ "$help" == YES ]; then
    display_help
fi

build_and_setup
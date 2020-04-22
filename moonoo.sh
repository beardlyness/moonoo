#!/usr/bin/env bash
#===============================================================================================================================================
# (C) Copyright 2019 MooNoo a project under the Crypto World Foundation (https://cryptoworld.is).
#
# Licensed under the GNU GENERAL PUBLIC LICENSE, Version 3.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.gnu.org/licenses/gpl-3.0.en.html
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
#===============================================================================================================================================
# title            :moonoo.sh
# description      :This script will make it super easy to setup mailcow, and have it be deployed in minutes.
# author           :The Crypto World Foundation.
# contributors     :beard
# date             :04-22-2020
# version          :0.0.1 Alpha
# os               :Debian/Ubuntu
# usage            :bash moonoo.sh
# notes            :If you have any problems feel free to email the maintainer: beard [AT] cryptoworld [DOT] is
#===============================================================================================================================================

# Force check for root
  if ! [ "$(id -u)" = 0 ]; then
    echo "You need to be logged in as root!"
     exit 1
  fi

  # Project URL, Local Directory, Dockerized Directory Repo List Path for Mapping in script.
    P_URL="https://github.com/mailcow/mailcow-dockerized"
    P_LOCAL_DIR="/opt/"
    P_DOCKERIZED_DIR="mailcow-dockerized"


# Setting up an update/upgrade global function
  function upkeep() {
    echo "Performing upkeep.."
      apt-get update -y
      apt-get dist-upgrade -y
      apt-get clean -y
  }


 # Setting up helpers for moonoo to work in sections.
  function moo_install_setup() {
    apt-get purge exim* postfix*
    apt-get autoremove
  }

  function moo_install_docker() {
    curl -sSL https://get.docker.com/ | CHANNEL=stable sh
    systemctl enable docker.service
    systemctl start docker.service
  }

  function moo_install_docker_compose() {
    curl -L https://github.com/docker/compose/releases/download/$(curl -Ls https://www.servercow.de/docker-compose/latest.php)/docker-compose-$(uname -s)-$(uname -m) > /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
  }

  function moo_install_check() {
    umask
    cd "$P_LOCAL_DIR"
    git clone "$P_URL"
    cd "$P_DOCKERIZED_DIR"
  }

 # Checks for required pieces of software and installs those that are missing.
  tools=( git apt-utils lsb-release curl dialog socat dirmngr apt-transport-https ca-certificates )
   grab_eware=""
     for e in "${tools[@]}"; do
       if command -v "$e" >/dev/null 2>&1; then
         echo "Dependency $e is installed.."
       else
         echo "Dependency $e is not installed..?"
          upkeep
          grab_eware="$grab_eware $e"
       fi
     done
    apt-get install $grab_eware

    # Grabbing info on active system
      flavor=$(lsb_release -cs)
      system=$(lsb_release -i | grep "Distributor ID:" | sed 's/Distributor ID://g' | sed 's/["]//g' | awk '{print tolower($1)}')


    # START
      read -r -p "Do you want to setup Mailcow now? (Y/Yes | N/No) " REPLY
        case "${REPLY,,}" in
          [yY]|[yY][eE][sS])
                moo_install_setup
                moo_install_docker
                moo_install_docker_compose
                moo_install_check
                bash ./generate_config.sh
                docker-compose pull
                docker-compose up
            ;;
          [nN]|[nN][oO])
              echo "You have said no? We cannot work without your permission!"
            ;;
          *)
            echo "Invalid response. You okay?"
            ;;
      esac

#!/bin/bash
# Description:   k9s updater
# Company:       Robotnik Automation S.L.L.
# Creation Year: 2023
# Author:        Guillem Gari <ggari@robotnik.es>
#
#
# Copyright (c) 2023, Robotnik Automation S.L.
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#     * Redistributions of source code must retain the above copyright
#       notice, this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above copyright
#       notice, this list of conditions and the following disclaimer in the
#       documentation and/or other materials provided with the distribution.
#     * Neither the name of the Robotnik Automation S.L.L. nor the
#       names of its contributors may be used to endorse or promote products
#       derived from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
# THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
# PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL Robotnik Automation S.L.L.
# BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY,
# OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
# OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
# WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
# OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
# EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#Colour
red_colour='\033[0;31m'
green_colour='\033[0;32m'
light_purple_colour='\033[1;35m'
err_colour="${red_colour}"
nfo_colour="${light_purple_colour}"
suc_colour="${green_colour}"
no_colour='\033[0m'

tool_list=(\
  git \
  curl \
  wget \
  jq \
  tar \
)

# url & files
github_api_url="https://api.github.com"
github_url="https://github.com"
github_k9s_user="derailed"
k9s_repo="k9s"
k9s_version_url="${github_api_url}/repos/${github_k9s_user}/${k9s_repo}/releases"
k9s_pkg="k9s_Linux_amd64.tar.gz"
k9s_local_pkg="/tmp/${k9s_pkg}"
k9s_download_url='${github_url}/${github_k9s_user}/${k9s_repo}/releases/download/${K9S_VERSION}/${k9s_pkg}'

#commands
check_local_k9s_command='k9s version &>/dev/null'
local_k9s_version_command='$(k9s version | grep Version | sed "s#.*:* ##")'
get_last_version_command='$(curl -sL ${k9s_version_url} | jq -r ".[0].name")'
download_last_version_command='rm -rf ${k9s_local_pkg} && wget ${k9s_download_url} -q -O ${k9s_local_pkg}'
install_k9s_command='cd /tmp && tar -xaf ${k9s_local_pkg} && mv /tmp/k9s /usr/local/bin/k9s && rm -rf ${k9s_local_pkg}'

err_str_root_permission="You need root privileges try:\nsudo ${0}"

nfo_str_tool_checking='Checking tools'
suc_str_tool_check_success='All required tools are available'

nfo_check_system="Scanning local system"

suc_str_local_version_k9s='k9s local version ${K9S_LOCAL_VERSION}'
err_str_local_version_k9s='could not retrieve k9s local version'
suc_str_available_version_k9s='k9s last avaible version ${K9S_VERSION}'
err_str_available_version_k9s='could not retrieve k9s last available version'

nfo_str_update_k9s='Updating k9s to ${K9S_VERSION}'
succ_str_k9s_already_updated='Already on the k9s version'
err_str_update_k9s='Error updateing k9s'
suc_str_update_k9s='k9s updated to ${K9S_VERSION}'


function print_error() {
  local message="${1}"
  eval "echo -e "'"'"${err_colour}[ERROR]${no_colour}:   ${message}"'"'" 2>&1"
}

function print_info() {
  local message="${1}"
  eval "echo -e "'"'"${nfo_colour}[INFO]${no_colour}:    ${message}"'"'""
}

function print_success() {
  local message="${1}"
  eval "echo -e "'"'"${suc_colour}[SUCCESS]${no_colour}: ${message}"'"'""
}

function check_root_permission() {
  if [[ "${EUID}" = 0 ]]; then
    return 0
  else
    print_error "${err_str_root_permission}"
    return 1
  fi
}

function tool_check() {
  local binary="${1}"
  if [[ -z "${binary}" ]];then
    return 1
  fi
  eval "${tool_check_cmd}"
  return $?
}

function tools_check() {
  local tools=("${@}")
  print_info "${nfo_str_tool_checking}"
  for tool in "${tools[@]}"; do
    if ! tool_check "${tool}"; then
      print_error "${err_str_required_tool_not_found}"
      return 1
    fi
  done
  print_success "${suc_str_tool_check_success}"
  return 0
}

function check_k9s_exits() {
  eval "${check_local_k9s_command}"
  return $?
}

function check_k9s_version() {
  eval "K9S_LOCAL_VERSION=${local_k9s_version_command}"
  return $?
}

function get_last_available_k9s_version() {
  if ! eval "K9S_VERSION=${get_last_version_command}"; then
    print_error "${err_str_available_version_k9s}"
    return 1
  fi
  return 0
}

function there_is_k9s_update() {
  print_info "${nfo_check_system}"
  if ! get_last_available_k9s_version; then
    return 1
  fi
  if ! check_k9s_exits; then
    return 0
  fi
  if ! check_k9s_version; then
    return 1
  fi
  if [[ ${K9S_LOCAL_VERSION} == ${K9S_VERSION} ]]; then
    print_success "${succ_str_k9s_already_updated}"
    return 1
  fi
  print_success "${suc_str_available_version_k9s}"
  return 0
}

function download_k9s(){
  eval "k9s_download_url=${k9s_download_url}"
  eval "${download_last_version_command}"
  return $?
}

function install_k9s() {
  eval "${install_k9s_command}"
  return $?
}

function update_k9s() {
  print_info "${nfo_str_update_k9s}"
  if ! download_k9s; then
    print_err "${err_str_update_k9s}"
    return 1
  fi
  if ! install_k9s; then
    print_err "${err_str_update_k9s}"
    return 1
  fi
  print_success "${suc_str_update_k9s}"
  return 0
}

function main() {
  if ! check_root_permission; then
    return 1
  fi
  if ! tools_check "${tool_list[@]}"; then
    return 1
  fi
  if ! there_is_k9s_update; then
    return 0
  fi
  if ! update_k9s; then
    return 1
  fi
  return 0
}

main "${@}"
exit $?

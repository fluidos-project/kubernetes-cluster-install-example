#!/bin/bash
# Description:   download ubuntu server iso
# Company:       Robotnik Automation S.L.
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
  grep \
  wget \
  awk \
  sha256sum \
  sed \
)

data_dir=""
data_files=(\
	iso-params \
)

data_files_fp=(\
)

shasum_url='${iso_base_url}/${ubuntu_distro}/${shasum_file}'
iso_name_full='${iso_base_url}/${ubuntu_distro}/${iso_name}'

#commands
shasum_download_command='wget ${shasum_url} -q -O ${shasum_file}'
get_iso_name_command='awk \"/${distro_type}/ {print \\\$2}\" ${shasum_file} | sed s#*##'
download_iso_command='wget ${iso_name_full} -O ${iso_name}'
verify_iso_command='sha256sum -c --ignore-missing ${shasum_file}'

err_str_root_permission="You need root privileges try:\nsudo ${0}"

nfo_str_tool_checking='Checking tools'
suc_str_tool_check_success='All required tools are available'

nfo_str_shasum_download="Downloading ubuntu iso shashum"
suc_str_shasum_download='Ubuntu iso shashum downloaded'
err_str_shasum_download='could not retrieve ${shasum_url}'

nfo_str_get_iso_name="Getting iso name"
suc_str_get_iso_name='Iso to download ${iso_name_full}'
err_str_get_iso_name='could not retrieve iso name'

nfo_str_dl_iso='Downloading ${iso_name_full}'
suc_str_dl_iso='${iso_name} Downloaded'
err_str_dl_iso='could not downloag ${iso_name_full}'

nfo_str_ver_iso='Verifiying ${iso_name}'
suc_str_ver_iso='${iso_name} is verified'
err_str_ver_iso='${iso_name} is corruped'

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

function test_file() {
	local file="${1}"
	if ! test -r "${file}"; then
		echo "File not present: ${file} : Aborting" 2>&1
		return 1
	fi
	return 0
}

function prepare_files() {
	previous_exec_path="$PWD"
	host_source_path="$(dirname "$(readlink -f "${0}")")"
	for data_file in "${data_files[@]}"; do
		data_file="${host_source_path}/${data_dir}/${data_file}"
		if ! test_file "${data_file}"; then
			return 1
		fi
		data_files_fp=(\
			"${data_files_fp[@]}" \
			"${data_file}" \
		)
	done

	cd "$host_source_path"
	return 0
}

function download_shasum() {
	print_info "${nfo_str_shasum_download}"
	eval "shasum_url=${shasum_url}"
	if ! eval "${shasum_download_command}"; then
		print_error "${err_str_shasum_download}"
		return 1
	fi
	print_success "${suc_str_shasum_download}"
	return 0
}

function get_iso_name() {
  print_info "${nfo_str_get_iso_name}"
  eval "get_iso_name_command=\"${get_iso_name_command}\""
  if ! iso_name=$(eval "${get_iso_name_command}"); then
    print_error "${err_str_get_iso_name}"
    return 1
  fi
  eval iso_name_full="${iso_name_full}"
  print_success "${suc_str_get_iso_name}"
	return 0
}

function download_iso() {
  print_info "${nfo_str_dl_iso}"
  if ! eval "${download_iso_command}"; then
    print_error "${err_str_dl_iso}"
    return 1
  fi
  print_success "${suc_str_dl_iso}"
	return 0
}

function verify_iso() {
	print_info "${nfo_str_ver_iso}"
  if ! eval "${verify_iso_command}"; then
    print_error "${err_str_ver_iso}"
    return 1
  fi
  print_success "${suc_str_ver_iso}"
  return 0
}

function get_iso() {
  if ! download_shasum; then
    return 1
  fi
  if ! get_iso_name; then
    return 1
  fi
  if ! download_iso; then
    return 1
  fi
  if ! verify_iso; then
    return 1
  fi

  return 0
}

function main() {
  # if ! check_root_permission; then
  #   return 1
  # fi
  if ! tools_check "${tool_list[@]}"; then
    return 1
  fi
  if ! get_iso; then
    return 0
  fi
  return 0
}

if ! prepare_files; then
	cd "${previous_exec_path}"
	exit 1
fi

for data_file in "${data_files_fp[@]}"; do
	if ! source "${data_file}"; then
		echo "Could not load: ${data_file} : Aborting" 2>&1
		exit 1
	fi
done

cd "${previous_exec_path}"

main "${@}"
exit $?

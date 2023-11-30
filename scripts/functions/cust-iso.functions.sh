#!/bin/bash
# Description:   General functions
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

function prepare_custom_iso_params() {
  print_info "${nfo_str_kernel_cmdline}"
  if [[ "${cloud_init_embedded_file}" == "true" ]]; then
    eval kernel_cmdline_additional_params_livecd="${kernel_cmdline_additional_params_livecd_embedded}"
  else
    if ! prepare_custom_iso_params_web; then
      print_error "${err_str_kernel_cmdline}"
      return 1
    fi
      eval kernel_cmdline_additional_params_livecd="${kernel_cmdline_additional_params_livecd_web}"
  fi
  eval kernel_cmdline_additional_params="${kernel_cmdline_additional_params}"
  print_success "${suc_str_kernel_cmdline}"
  return 0

}

function prepare_custom_iso_params_web() {
  if [[ -n "${cloud_init_server_port}" ]]; then
    cloud_init_server_path_first="${cloud_init_server_path_port}"
  else
    cloud_init_server_path_first="${cloud_init_server_path_no_port}"
  fi
  eval "cloud_init_server_path_first=${cloud_init_server_path_first}"
  if [[ -n "${cloud_init_server_folder}" ]]; then
    cloud_init_server_path="${cloud_init_server_path_folder}"
  else
    cloud_init_server_path="${cloud_init_server_path_no_folder}"
  fi
  eval cloud_init_server_path="${cloud_init_server_path}"
  eval kernel_cmdline_additional_params_livecd_web="${kernel_cmdline_additional_params_livecd_web}"
  return 0
}

function extract_iso() {
  print_info "${nfo_str_extract_iso}"
  if ! eval "${extract_iso_command}"; then
    print_error "${err_str_extract_iso}"
    return 1
  fi
  print_success "${suc_str_extract_iso}"
  return 0
}

function get_file_md5sum_file_entry() {
  eval "get_old_md5sum_line_command=\"${get_old_md5sum_line_command_template}\""
  old_md5sum=$(eval "${get_old_md5sum_line_command}")
  return 0
}
function obtain_new_md5sum_file() {
  eval "get_new_md5sum_line_command=\"${get_new_md5sum_line_command_template}\""
  new_md5sum=$(eval "${get_new_md5sum_line_command}")
  return 0
}
function modify_md5sum_file() {
  eval "replace_md5sum_line_command=\"${replace_md5sum_line_command_template}\""
  eval "${replace_md5sum_line_command}"
  return 0
}

function modify_file_md5sum() {
  print_info "${nfo_str_md5sum_path}"
  if ! get_file_md5sum_file_entry; then
    print_error "${err_str_md5sum_path}"
    return 1
  fi
  if ! obtain_new_md5sum_file; then
    print_error "${err_str_md5sum_path}"
    return 1
  fi
  if ! modify_md5sum_file; then
    print_error "${err_str_md5sum_path}"
    return 1
  fi
  print_success "${suc_str_md5sum_path}"
  return 0
}

function modify_kernel_cmdline_file() {
  print_info "${nfo_str_mod_boot_file}"
  if ! eval ${kernel_cmdline_mod_command}; then
    print_error "${err_str_mod_boot_file}"
    return 1
  fi
  print_success "${suc_str_mod_boot_file}"
  return 0
}

function modify_kernel_cmdline_files() {
  for boot_file in "${boot_files[@]}"; do
    if ! modify_kernel_cmdline_file; then
      return 1
    fi
    if ! modify_file_md5sum; then
      return 1
    fi
  done
  return 0
}

function add_md5sum_checksum() {
  eval "inject_md5sum_line_command=\"${inject_md5sum_line_command_template}\""
  eval "${inject_md5sum_line_command}"
  return 0
}

function add_md5sum_checksums_for_nocloud() {
  for file in "${nocloud_files[@]}"; do
    if ! add_md5sum_checksum; then
      return 1
    fi
  done
  return 0
}

function embbed_nocloud_config_file() {
  if [[ "${cloud_init_embedded_file}" != "true" ]]; then
    return 0
  fi
  print_info "${nfo_str_nocloud_embedd}"
  if ! eval "${create_nocloud_files_command}"; then
    print_error "${err_str_nocloud_embedd}"
    return 1
  fi
  if ! eval "${copy_cloud_init_file_command}"; then
   print_error "${err_str_nocloud_embedd}"
    return 1
  fi
  if ! eval add_md5sum_checksums_for_nocloud; then
    print_error "${err_str_nocloud_embedd}"
    return 1
  fi
  print_success "${suc_str_nocloud_embedd}"
  return 0
}

function clean_ghost_folder() {
  print_info "${nfo_str_ghost_clean}"
  if ! eval ${clean_ghost_folder_command}; then
    print_error "${err_str_ghost_clean}"
    return 1
  fi
  print_success "${suc_str_ghost_clean}"
  return 0
}

function correct_hwe_failure() {
  if ! eval ${correct_hwe_failure_command}; then
    print_error "${err_str_fix_hwe}"
    return 1
  fi
  return 0
}

function modify_iso() {
  if ! modify_kernel_cmdline_files; then
    return 1
  fi
  if ! embbed_nocloud_config_file; then
    return 1
  fi
  if ! clean_ghost_folder; then
    return 1
  fi
  if ! correct_hwe_failure; then
    return 1
  fi
  return 0
}

function create_new_iso() {
  eval new_iso_name="${new_iso_name}"
  print_info "${nfo_str_create_iso}"
  if ! eval ${create_new_image_command}; then
    print_error "${err_str_create_iso}"
  fi
  print_success "${suc_str_create_iso}"
  return 0
}

function clean_system() {
  print_info "${nfo_str_clean_system}"
  if ! eval ${clean_system_command}; then
    print_error "${err_str_clean_system}"
  fi
  print_success "${suc_str_clean_system}"
  return 0
}

function customize_iso() {
  if ! prepare_custom_iso_params; then
    return 1
  fi
  if ! extract_iso; then
    return 1
  fi
  if ! modify_iso; then
    return 1
  fi
  if ! create_new_iso; then
    return 1
  fi
  if clean_system; then
    return 1
  fi
  return 0
}

function main_customize_iso(){
  if ! cust_iso_parse_arguments "${@}"; then
    return 1
  fi
  if ! tools_check "${cust_iso_tool_list[@]}"; then
    return 1
  fi
  if ! main_download_iso; then
    return 1
  fi
  if ! customize_iso; then
    return 0
  fi
  return 0
}


function cust_iso_parse_arguments() {
  local key=""
  while [[ $# -gt 0 ]]; do
    key="${1}"
    case "${key}" in
      --distro|-d)
        ubuntu_distro="${2}"
        shift
        ;;
      --net | -s)
        cloud_init_embedded_file=false
        ;;
      --embedded | -e)
        cloud_init_embedded_file=true
        ;;
      --ci-file | -f)
        cloud_init_file="${2}"
        shift
        ;;
      --ci-server-prot | -t)
        cloud_init_server_prot="${2}"
        shift
        ;;
      --ci-server-name | -n)
        cloud_init_server_name="${2}"
        shift
        ;;
      --ci-server-port | -p)
        cloud_init_server_port="${2}"
        shift
        ;;
      --ci-server-folder | -d)
        cloud_init_server_folder="${2}"
        shift
        ;;
      --help|-h)
        cust_iso_help
        exit 0
        ;;
      --version|-v)
        cust_iso_version
        exit 0
        ;;
      *)
        cust_iso_help
        exit 0
        ;;
    esac
    shift
  done
  return 0
}

function cust_iso_help() {
cat << EOF
Automated ubuntu installation creator
Version: ${version}

Usage:
${0}
${0} [OPTIONS]

Optional arguments:
 -d, --distro [DISTRO]               Select ubuntu distro (focal/jammy)
                                     (focal/jammy)
 -s, --net                           Select to use the cloud-init
                                     server
 -e, --embedded                      Select to embedded the nocloud file
                                     inside the iso
                                     (This will invalide the ci* options)
 -f, --ci-file [FILE]                cloud-init file path
 -t, --ci-server-prot [PROTOCOL]     Cloud-init server protocol
                                     (https/http)
 -n, --ci-server-name [URL]          Cloud-init server url
 -p, --ci-server-port [PORT]         Cloud-init server port (default 80/443)
 -d, --ci-server-folder [FOLDER]     Cloud-init server folder

 -h, --help                Shows this help

 -v, --version             Shows the version of the script

EOF
  return 0
}

function cust_iso_version() {
cat << EOF
${0} (Automated ubuntu installation creator): ${version}

Copyright (C) 2023 Robotnik Automation S.L.
License BSD-3: BSD 3-clause license <https://opensource.org/licenses/BSD-3-Clause>.

Written by Guillem Gari.
EOF
}
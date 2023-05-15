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

function is_iso_already_downloaded() {
  print_info "${nfo_str_ck_local_iso}"
  if ! [[ -r "${iso_name}" ]]; then
    print_info "${err_str_ck_local_iso}"
    return 1
  fi
  print_success "${suc_str_ck_local_iso}"
  if ! verify_iso; then
    return 1
  fi
  iso_verifed=0
  return 0
}

function download_iso() {
  if is_iso_already_downloaded; then
    return 0
  fi
  print_info "${nfo_str_dl_iso}"
  if ! eval "${download_iso_command}"; then
    print_error "${err_str_dl_iso}"
    return 1
  fi
  print_success "${suc_str_dl_iso}"
	return 0
}

function verify_iso() {
  if [[ "${iso_verifed}" -eq 0 ]]; then
    return 0
  fi
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

function main_download_iso() {
  if ! tools_check "${down_iso_tool_list[@]}"; then
    return 1
  fi
  if ! get_iso; then
    return 0
  fi
  return 0
}
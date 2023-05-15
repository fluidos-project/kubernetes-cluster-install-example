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

tool_list=(\
  grep \
  wget \
  awk \
  sha256sum \
  sed \
  p7zip-full \
)

data_dir=""
data_files=(\
	iso-params \
)

data_files_fp=(\
)

func_dir=""
func_files=(\
  download-ubuntu-iso.sh \
)

funct_files_fp=(\
)

function check_root_permission() {
  if [[ "${EUID}" = 0 ]]; then
    return 0
  else
    print_error "${err_str_root_permission}"
    return 1
  fi
}



function customize_iso() {
    if ! download_iso; then
      return 1
    fi
  fi
  if ! change_iso; then
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
  if ! customize_iso; then
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

for data_file in "${data_files_fp[@]}"; do
	if ! source "${data_file}"; then
		echo "Could not load: ${data_file} : Aborting" 2>&1
		exit 1
	fi
done

cd "${previous_exec_path}"

main "${@}"
exit $?

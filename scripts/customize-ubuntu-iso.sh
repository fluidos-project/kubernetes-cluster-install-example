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

data_dir="data"
data_files=(\
  general.data.sh \
  strings.data.sh \
  commands.data.sh \
  down-iso.data.sh \
  cust-iso.data.sh \
  ../iso-params \

)

data_files_fp=(\
)

func_dir="functions"
func_files=(\
  general.functions.sh \
  down-iso.functions.sh \
  cust-iso.functions.sh \
)

func_files_fp=(\
)

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

  for func_file in "${func_files[@]}"; do
    func_file="${host_source_path}/${func_dir}/${func_file}"
    if ! test_file "${func_file}"; then
      return 1
    fi
    func_files_fp=(\
      "${func_files_fp[@]}" \
      "${func_file}" \
    )
  done
  cd "$host_source_path"
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

for func_file in "${func_files_fp[@]}"; do
  if ! source "${func_file}"; then
    echo "Could not load: ${func_file} : Aborting" 2>&1
    exit 1
  fi
done

cd "${previous_exec_path}"

main_customize_iso "${@}"
exit $?

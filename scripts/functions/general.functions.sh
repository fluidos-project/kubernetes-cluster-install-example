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
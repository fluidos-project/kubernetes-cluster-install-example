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
  return 0
}

function extract_iso() {
  return 0
}

function mount_iso() {
  return 0
}

function modify_iso() {
  return 0
}

function create_new_iso() {
  return 0
}

function clean_system() {
  return 0
}

function customize_iso() {
  if ! prepare_custom_iso_params; then
    return 1
  fi
  if ! extract_iso; then
    return 1
  fi
  if ! mount_iso; then
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

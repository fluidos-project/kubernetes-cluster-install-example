#!/bin/bash
# Description:   strings data
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

err_str_root_permission="You need root privileges try:\nsudo ${0}"

nfo_str_tool_checking='Checking tools'
suc_str_tool_check_success='All required tools are available'

nfo_str_shasum_download="Downloading ubuntu iso shashum"
suc_str_shasum_download='Ubuntu iso shashum downloaded'
err_str_shasum_download='could not retrieve ${shasum_url}'

nfo_str_get_iso_name="Getting iso name"
suc_str_get_iso_name='Iso to download ${iso_name_full}'
err_str_get_iso_name='could not retrieve iso name'

nfo_str_ck_local_iso='Checkig is ${iso_name} already present on machine'
suc_str_ck_local_iso='${iso_name} Downloaded'
err_str_ck_local_iso='No local image found'


nfo_str_dl_iso='Downloading ${iso_name_full}'
suc_str_dl_iso='${iso_name} Downloaded'
err_str_dl_iso='could not downloag ${iso_name_full}'

nfo_str_ver_iso='Verifiying ${iso_name}'
suc_str_ver_iso='${iso_name} is verified'
err_str_ver_iso='${iso_name} is corruped'

nfo_str_extract_iso='extracting ${iso_name}'
suc_str_extract_iso='${iso_name} is extracted on ${custom_iso_folder}'
err_str_extract_iso='extraction of ${iso_name} in ${custom_iso_folder} failed'

nfo_str_kernel_cmdline='Generating kernel cmdline additional arguments'
suc_str_kernel_cmdline='Generated kernel arguments ${kernel_cmdline_additional_params}'
err_str_kernel_cmdline='Failed to generate kernel arguments ${kernel_cmdline_additional_params}'

nfo_str_mod_boot_file='Modifing boot-file ${boot_file}'
suc_str_mod_boot_file='${boot_file} patched with additional kernel boot comands'
err_str_mod_boot_file='Failed to patch ${boot_file}'

nfo_str_md5sum_path='Changing md5sum of ${boot_file}'
suc_str_md5sum_path='Updated md5sum of ${boot_file}'
err_str_md5sum_path='Failed to update md5sum ${boot_file}'

nfo_str_nocloud_embedd='Enmbedding into the iso the no-cloud configuration'
suc_str_nocloud_embedd='No cloud configuration embedded from ${cloud_init_file}'
err_str_nocloud_embedd='Failed to embed ${cloud_init_file}'
#!/bin/bash
# Description:   customize iso data
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
cust_iso_tool_list=(\
  7z \
)

custom_iso_folder="cust_iso"
iso_cust_file_grub="${custom_iso_folder}/boot/grub/grub.cfg"
iso_cust_file_txt="${custom_iso_folder}/cust_iso/isolinux/txt.cfg"
iso_cust_file_lobk="${custom_iso_folder}/boot/grub/loopback.cfg"

kernel_cmdline_additional_params_permanent="net.ifnames=0 biosdevname=0"
kernel_cmdline_additional_params_livecd_web='autoinstall\\\ ip=dhcp\\\ ds=nocloud-net\\\\\\\\\\\;s=${cloud_init_server_path}'

kernel_cmdline_additional_params_livecd_embedded='autoinstall\\\ ds=nocloud-net\\\\\;s=/cdrom/nocloud/'

kernel_cmdline_additional_params_livecd=''
kernel_cmdline_additional_params='${kernel_cmdline_additional_params_livecd}\ ---\ ${kernel_cmdline_additional_params_permanent}'

cloud_init_server_path_no_port='${cloud_init_server_prot}://${cloud_init_server_name}/'
cloud_init_server_path_port='${cloud_init_server_prot}://${cloud_init_server_name}:${cloud_init_server_port}/'
cloud_init_server_path_first=''
cloud_init_server_path_no_folder='${cloud_init_server_path_first}'
cloud_init_server_path_folder='${cloud_init_server_path_first}${cloud_init_server_folder}/'
cloud_init_server_path=''
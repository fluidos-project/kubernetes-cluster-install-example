#!/bin/bash
# Description:   commands to use
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

#commands
shasum_download_command='wget ${shasum_url} -q -O ${shasum_file}'
get_iso_name_command='awk \"/${distro_type}/ {print \\\$2}\" ${shasum_file} | sed s#*##'
download_iso_command='wget ${iso_name_full} -O ${iso_name}'
verify_iso_command='sha256sum -c --ignore-missing ${shasum_file}'

extract_iso_command='rm -rf ${custom_iso_folder} && 7z x -y ${iso_name}  -o${custom_iso_folder}'
kernel_cmdline_mod_command='sed -i "s#---#${kernel_cmdline_additional_params}#" ${boot_file}'
get_old_md5sum_line_command_template='grep .${boot_file#${custom_iso_folder}} ${iso_md5sum_file}'
get_new_md5sum_line_command_template='md5sum ${boot_file} | sed "s#${boot_file}#.${boot_file#${custom_iso_folder}}#"'
replace_md5sum_line_command_template='sed -i \"s#${old_md5sum}#${new_md5sum}#\" ${iso_md5sum_file}'
create_nocloud_files_command='mkdir -p ${custom_iso_folder}/nocloud && touch ${custom_iso_folder}/nocloud/{meta-data,vendor-data}'
copy_cloud_init_file_command='cp ${cloud_init_file} ${custom_iso_folder}/nocloud/user-data'
clean_ghost_folder_command='rm -rf ${custom_iso_folder}/[BOOT\]/'
create_new_image_command='xorriso -as mkisofs -r -V Ubuntu\ custom\ amd64 -o ${new_iso_name} -J -l -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -eltorito-alt-boot -e boot/grub/efi.img -no-emul-boot -isohybrid-gpt-basdat -isohybrid-apm-hfsplus -isohybrid-mbr /usr/lib/ISOLINUX/isohdpfx.bin  ${custom_iso_folder}/boot ${custom_iso_folder}'
inject_md5sum_line_command_template='md5sum ${file} | sed "s#${file}#.${file#${custom_iso_folder}}#" >>${iso_md5sum_file}'
clean_system_command='rm -rf ${custom_iso_folder}'
# xorriso -as mkisofs -r \
#   -V Ubuntu\ custom\ amd64 \
#   -o ${new_iso_name} \
#   -J -l -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot \
#   -boot-load-size 4 -boot-info-table \
#   -eltorito-alt-boot -e boot/grub/efi.img -no-emul-boot \
#   -isohybrid-gpt-basdat -isohybrid-apm-hfsplus \
#   -isohybrid-mbr /usr/lib/ISOLINUX/isohdpfx.bin  \
#   ${custom_iso_folder}/boot ${custom_iso_folder}\
# '

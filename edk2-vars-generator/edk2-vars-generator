#!/usr/bin/env python3
#
# Copyright 2021 Canonical Ltd.
# Authors:
# - dann frazier <dann.frazier@canonical.com>
#
# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License version 3, as published
# by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranties of MERCHANTABILITY,
# SATISFACTORY QUALITY, or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# this program.  If not, see <http://www.gnu.org/licenses/>.
#

import argparse
import os.path
import pexpect
import shutil
import sys
from UEFI.Filesystems import FatFsImage, EfiBootableIsoImage
from UEFI.Qemu import QemuEfiMachine, QemuEfiVariant, QemuEfiFlashSize
from UEFI import Qemu

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "-f", "--flavor", help="UEFI Flavor",
        choices=['AAVMF', 'OVMF', 'OVMF_4M'],
        required=True,
    )
    parser.add_argument(
        "-e", "--enrolldefaultkeys",
        help='Path to "EnrollDefaultKeys" EFI binary',
        required=True,
    )
    parser.add_argument(
        "-s", "--shell",
        help='Path to "Shell" EFI binary',
        required=True,
    )
    parser.add_argument(
        "-C", "--certificate",
        help='base64-encoded PK/KEK1 certificate',
        required=True,
    )
    parser.add_argument(
        "-c", "--code",
        help='UEFI code image',
        required=True,
    )
    parser.add_argument(
        "--no-default",
        action="store_true",
        help='Do not enroll the default keys, just the PK/KEK1 certificate',
    )
    parser.add_argument(
        "-V", "--vars-template",
        help='UEFI vars template',
        required=True,
    )
    parser.add_argument(
        "-o", "--out-file",
        help="Output file for generated vars template",
        required=True,
    )
    parser.add_argument("-d", "--debug", action="store_true",
                        help="Emit debug messages")
    args = parser.parse_args()

    FlavorConfig = {
        'AAVMF': {
            'EfiArch': 'AA64',
            'QemuCommand': Qemu.QemuCommand(
                QemuEfiMachine.AAVMF,
                code_path=args.code,
                vars_template_path=args.vars_template,
            ),
        },
        'OVMF': {
            'EfiArch': 'X64',
            'QemuCommand': Qemu.QemuCommand(
                QemuEfiMachine.OVMF_Q35,
                variant=QemuEfiVariant.SECBOOT,
                flash_size=QemuEfiFlashSize.SIZE_4MB,
                code_path=args.code,
                vars_template_path=args.vars_template,
            ),
        },
        'OVMF_4M': {
            'EfiArch': 'X64',
            'QemuCommand': Qemu.QemuCommand(
                QemuEfiMachine.OVMF_Q35,
                variant=QemuEfiVariant.SECBOOT,
                flash_size=QemuEfiFlashSize.SIZE_4MB,
                code_path=args.code,
                vars_template_path=args.vars_template,
            ),
        },
    }

    eltorito = FatFsImage(64)
    eltorito.makedirs(os.path.join('EFI', 'BOOT'))
    removable_media_path = os.path.join(
        'EFI', 'BOOT', f"BOOT{FlavorConfig[args.flavor]['EfiArch']}.EFI"
    )
    eltorito.insert_file(args.shell, removable_media_path)
    eltorito.insert_file(
        args.enrolldefaultkeys,
        args.enrolldefaultkeys.split(os.path.sep)[-1]
    )
    iso = EfiBootableIsoImage(eltorito)

    q = FlavorConfig[args.flavor]['QemuCommand']
    q.add_disk(iso.path)
    q.add_oem_string(11, args.certificate)

    child = pexpect.spawn(' '.join(q.command))
    if args.debug:
        child.logfile = sys.stdout.buffer
    child.expect(['Press .* or any other key to continue'], timeout=None)
    child.sendline('\x1b')
    child.expect(['Shell> '], timeout=None)
    child.sendline('FS0:\r')
    child.expect(['FS0:\\\\> '], timeout=None)
    enrollcmd = ['EnrollDefaultKeys.efi']
    if args.no_default:
        enrollcmd.append("--no-default")
    child.sendline(f'{" ".join(enrollcmd)}\r')
    child.expect(['FS0:\\\\> '], timeout=None)
    # Clear the BootOrder. See #1015759
    child.sendline('setvar BootOrder =\r')
    child.expect(['FS0:\\\\> '], timeout=None)
    child.sendline('reset -s\r')
    child.wait()
    shutil.copy(q.pflash.varfile_path, args.out_file)

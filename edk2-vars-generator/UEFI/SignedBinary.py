#
# Copyright 2022 Canonical Ltd.
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

import os
import subprocess
import tempfile


class SignedBinary:
    def __init__(self, binary_path, key_path, cert_path, password=None):
        openssl_password_args = []
        if password:
            openssl_password_args = [
                "-passin", f"pass:{password}"
            ]
        with tempfile.NamedTemporaryFile() as keytmp:
            subprocess.check_call(
                [
                    "openssl", "rsa",
                ] + openssl_password_args + [
                    "-in", f"{key_path}",
                    "-out", f"{keytmp.name}",
                ]
            )
            with tempfile.NamedTemporaryFile(delete=False) as f:
                self.path = f.name

            subprocess.check_call(
                [
                    "sbsign", "--key", f"{keytmp.name}",
                    "--cert", f"{cert_path}",
                    binary_path, "--output", f"{self.path}"
                ]
            )

    def __del__(self):
        os.unlink(self.path)

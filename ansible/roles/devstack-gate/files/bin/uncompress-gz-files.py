#!/usr/bin/python -tt
# vim: ai ts=4 sts=4 et sw=4

# Copyright (c) 2016 Intel Corporation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

import os
import re
import subprocess
import sys

BASE_DIR = os.path.abspath('.')


def main():
    uncompress_files(BASE_DIR)


def uncompress_files(directory):
    for dirpath, dirnames, filenames in os.walk(directory):
        for filename in filenames:
            full_path = os.path.join(dirpath, filename)
            if not filename.endswith('.gz'):
                continue
            cmd = ['gunzip', full_path]
            print "Exec: {}".format(' '.join(cmd))
            subprocess.check_call(cmd)


if '__main__' == __name__:
    sys.exit(main())


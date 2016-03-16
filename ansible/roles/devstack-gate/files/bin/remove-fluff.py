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
import sys

BASE_DIR = os.path.abspath('.')
OUTPUT_DIR = os.path.join(BASE_DIR, 'processed')


REMOVE_REGEXES = (
    re.compile(r'Connecting to AMQP server on'),
    re.compile(r'Connected to AMQP server on'),
    re.compile(r'Running periodic task'),
    re.compile(r'Authenticating user token process_request'),
    re.compile(r'Received request from user: user_id'),
    re.compile(r'MSG_ID is [0-9a-f]{32} _send /usr/local/lib/python2.7/dist-packages/oslo_messaging/_drivers/amqpdriver.py'),
    re.compile(r'keystonemiddleware.auth_token [-] Storing token in cache store /usr/local/lib/python2.7/dist-packages/keystonemiddleware/auth_token/_cache.py'),
    re.compile(r'heal_instance_info_cache'),
)

def main():
    if not os.path.isdir(OUTPUT_DIR):
        os.mkdir(OUTPUT_DIR)
    for filename in sorted(os.listdir(BASE_DIR)):
        full_path = os.path.join(BASE_DIR, filename)
        if not filename.endswith('.txt'):
            continue
        process_file(filename)


def process_file(filename):
    content = read_file(filename)
    modified, content = remove_fluff(content)
    if modified:
        print "Modified file: {}".format(filename)
    write_file(filename, content)


def remove_fluff(content):
    FLUFF_MSG = "FLUFF_REMOVED"
    modified = False
    output = []
    for line in content:
        keep_line = True
        for index, regex in enumerate(REMOVE_REGEXES):
            if regex.search(line):
                keep_line = False
                modified = True
                break
        if keep_line:
            output.append(line)
        else:
            if output and output[-1].startswith(FLUFF_MSG):
                output[-1] += "{}".format(index)
            else:
                output.append("{}-{}".format(FLUFF_MSG, index))
    return modified, output


def read_file(filename):
    content = []
    with open(filename, 'r') as in_file:
        for line in in_file.readlines():
            content.append(line.rstrip())
    return content


def write_file(filename, content):
    base_name = os.path.basename(filename)
    with open(os.path.join(OUTPUT_DIR, base_name), 'w') as out_file:
        for line in content:
            out_file.write('{}\n'.format(line))


if '__main__' == __name__:
    sys.exit(main())


#!/usr/bin/python -tt
# vim: ai ts=4 sts=4 et sw=4

#    Copyright (c) 2014 Intel Corporation
#
#    This program is free software; you can redistribute it and/or modify it
#    under the terms of the GNU General Public License as published by the Free
#    Software Foundation; version 2 of the License.
#
#    This program is distributed in the hope that it will be useful, but
#    WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
#    or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
#    for more details.
#
#    You should have received a copy of the GNU General Public License along
#    with this program; if not, write to the Free Software Foundation, Inc., 59
#    Temple Place - Suite 330, Boston, MA 02111-1307, USA.  http://www.fsf.org/

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


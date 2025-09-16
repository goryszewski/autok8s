#!/bin/env python3
from ansible.module_utils.basic import *
import os, json
import re, sys


def firstProg(text):
    text1 = "Hello " + text
    return text1


def run_module():
    # params
    module_args = dict(
        yourName=dict(type='str', required=True),
        new=dict(type='bool', required=False, default=False)
    )

    result = dict(
        changed=False,
        disks=[]
    )

    module = AnsibleModule(argument_spec=module_args)

    if module.check_mode:
        module.exit_json(**result)

    if result['disks']:
        result['changed'] = True

    if module.params['yourName'] == 'fail me':
        module.fail_json(msg='You requested this to fail', **result)

    module.exit_json(**result)

def main():
    run_module()


if __name__ == '__main__':
    main()

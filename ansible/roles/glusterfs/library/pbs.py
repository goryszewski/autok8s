#!/bin/env python3
# from ansible.module_utils.basic import *
import os, json
import re, sys ,requests

ADDRESS: str = "https://192.168.122.76:8007/"

def firstProg(text):
    text1 = "Hello " + text
    return text1


# def run_module():
#     # params
#     module_args = dict(
#         yourName=dict(type='str', required=True),
#         new=dict(type='bool', required=False, default=False)
#     )

#     result = dict(
#         changed=False,
#         disks=[]
#     )

#     module = AnsibleModule(argument_spec=module_args)

#     if module.check_mode:
#         module.exit_json(**result)

#     if result['disks']:
#         result['changed'] = True

#     if module.params['yourName'] == 'fail me':
#         module.fail_json(msg='You requested this to fail', **result)

#     module.exit_json(**result)



def auth():
    path = "/api2/json/access/ticket"
    url = f"{ADDRESS}/{path}"

    auth: dict = {"username":"root@pam","password":"Dupa123$"}

    response = requests.post(url=url,json=auth,verify=False)


    print("H: ",response.headers)
    print("CODE: ", response.status_code)
    data= response.json()
    tocket = data['data']['ticket']
    print(tocket)
    return tocket

def get_ds(ticket):
    path = "/api2/json/config/datastore"
    url = f"{ADDRESS}/{path}"
    headers = {"Authorization": f"PBSAPIToken={ticket}"}
    response = requests.get(url=url,verify=False,headers=headers)
    print("H: ",response.headers)
    print("CODE: ", response.status_code)

def main():
    tocket = auth()
    get_ds(ticket=tocket)



if __name__ == '__main__':
    main()

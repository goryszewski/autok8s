#!/usr/bin/env python

import json
import libvirt,libxml2

class Host:
    def __init__(self):
        self.conn = libvirt.open("qemu:///system")
    
    def get_vm(self):
        return self.conn.listAllDomains(libvirt.VIR_CONNECT_LIST_DOMAINS_ACTIVE)

class Domain:
    def __init__(self,tmp):

        xmldesc = tmp.XMLDesc(0)

        doc = libxml2.parseDoc(xmldesc).xpathNewContext()
        self.description  = doc.xpathEval("/domain/description")[0].content
        self.address_ip = tmp.interfaceAddresses(libvirt.VIR_DOMAIN_INTERFACE_ADDRESSES_SRC_AGENT)['ens3']['addrs'][0]['addr']
        self.dns = doc.xpathEval("/domain/name")[0].content


    def get_hostname(self):
        return self.dns.split('.')[0]

    def get_dns(self):
        return self.dns

    def get_ip(self):
        return self.address_ip
    def get_description(self):
        return self.description

class Domains:
    _domains=[]
    def __init__(self):
        self.host = Host()
        self.domains = self.host.get_vm()
        for i in self.domains:
            try:
                VM = Domain(i)
            except:
                continue
            self._domains.append(VM)

    def get(self):
        hostvars = {}
        output = {'_meta': {'hostvars': hostvars}}
        for vm in self._domains:
            net = vm.get_ip()
            hostvars[net]= { 'hostname' : vm.get_hostname(), 'dns':vm.get_dns() }
            tags = vm.get_description().split("_")
            for tag in tags:
                if tag in output:
                    output[tag]['hosts'].append(net)
                else:
                    output[tag]={'hosts': [net]}
        return output



class invent():
    def __init__(self,domains):
        pass

def main():
    groups = Domains().get()



    print(json.dumps(groups, indent=True))


if __name__ == '__main__':
    main()
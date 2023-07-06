#!/usr/bin/env python

import json
import libvirt,libxml2

class Host:
    def __init__(self):
        self.conn = libvirt.open("qemu:///system")
    
    def getAllVM(self):
        return self.conn.listAllDomains(libvirt.VIR_CONNECT_LIST_DOMAINS_ACTIVE)


class Domain:
    def __init__(self,tmp):
        # self._addresses_ip= []
        xmldesc = tmp.XMLDesc(0)
        doc = libxml2.parseDoc(xmldesc).xpathNewContext()

        # interfaces = tmp.interfaceAddresses(libvirt.VIR_DOMAIN_INTERFACE_ADDRESSES_SRC_AGENT)
        # for interface,value in interfaces.items():
        #     if interface == 'lo':
        #         continue
        #     self._addresses_ip.append()

        self.description  = doc.xpathEval("/domain/description")[0].content
        self.address_ip = tmp.interfaceAddresses(libvirt.VIR_DOMAIN_INTERFACE_ADDRESSES_SRC_AGENT)['ens3']['addrs'][0]['addr']
        self.dns = doc.xpathEval("/domain/name")[0].content

    def getHostname(self):
        return self.dns.split('.')[0]

    def getDNS(self):
        return self.dns

    def getIP(self):
        return self.address_ip

    def getDescription(self):
        return self.description


class Domains:
    def __init__(self):
        self._counter = 0
        self._domains=[]
        self._host = Host()
        self.vm = self._host.getAllVM()

        for i in self.vm:
            try:
                VM = Domain(i)
            except:
                continue
            self._domains.append(VM)

    def __iter__(self):
        return self

    def __next__(self):
        if self._counter >= len(self._domains):
            self._counter=0
            raise StopIteration
        else:
            self._counter+=1
            return self._domains[self._counter-1]


class invent():
    def __init__(self,domains):
        self._domains = domains

    def get(self):
        hostvars = {}
        output = {'_meta': {'hostvars': hostvars}}

        for vm in self._domains:
            host = vm.getIP()
            hostvars[host]= { 'hostname' : vm.getHostname(), 'dns':vm.getDNS() }
            tags = vm.getDescription().split("_")

            for tag in tags:
                if tag in output:
                    output[tag]['hosts'].append(host)
                else:
                    output[tag]={'hosts': [host]}

        return output


def main():
    domains = Domains()
    output = invent(domains)

    print(json.dumps(output.get(), indent=True))

if __name__ == '__main__':
    main()

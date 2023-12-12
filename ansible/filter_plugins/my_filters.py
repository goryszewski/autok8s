#!/usr/bin/python
class FilterModule(object):
    def filters(self):
        return {
            'fix_to_san': self.fix_to_san,
            'endpoints' : self.endpoints,
        }

    def endpoints(self,items):
        endpoints=[]
        for item in items:
            endpoints.append(f"{item}:2379")

        return endpoints

    def fix_to_san(self, items):
        new_list=[]
        for item in items:
            new_list.append(f"IP:{item}")

        return new_list

#!/usr/bin/python
class FilterModule(object):
    def filters(self):
        return {
            'a_filter': self.a_filter,
        }

    def a_filter(self, items):
        new_list=[]
        for item in items:
            new_list.append("IP:"+item)

        return new_list
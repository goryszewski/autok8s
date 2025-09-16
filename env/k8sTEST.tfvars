hosts = {
  "master01" : { memoryMB : "8192", "tags" : ["etcd", "nodeK8S", "controlplane", "init"] ,"disks" : { "d1" : { "size" : 10000000000 }}  },
  "master02" : { memoryMB : "8192", "tags" : ["etcd", "nodeK8S", "controlplane"] ,"disks" : { "d1" : { "size" : 10000000000 }}},
  "worker01" : { "tags" : ["nodeK8S", "worker"], memoryMB : "8192" ,"disks" : { "d1" : { "size" : 10000000000 }}},
  "haproxy01" : { "tags" : ["haproxy", "dns"], memoryMB : "2048" ,"disks" : { "d1" : { "size" : 10000000000 }}},
  "lbexternal01" : { "tags" : ["lbexternal"], memoryMB : "2048" ,"disks" : { "d1" : { "size" : 10000000000 }}},
}

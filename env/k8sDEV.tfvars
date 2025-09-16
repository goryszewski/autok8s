 hosts ={\
	"master01" : { memoryMB: "8192" , "tags" : ["etcd","nodeK8S","controlplane","init"] },\
	"worker01" : { "tags" : ["nodeK8S","worker"]  , memoryMB: "8192"}, \
	"dns01" : { "tags" : ["dns","master"] , memoryMB: "2048"},\
 }

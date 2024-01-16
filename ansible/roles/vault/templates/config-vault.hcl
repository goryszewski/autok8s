disable_cache           = true
disable_mlock           = true
ui                      = true

listener "tcp" {
   address              = "0.0.0.0:8200"
   cluster_addr         = "0.0.0.0:8201"
   tls_client_ca_file   = "/etc/ssl/Kubernetes_CA.pem"
   tls_cert_file        = "/etc/ssl/node_{{hostname}}.pem"
   tls_key_file         = "/etc/ssl/node_{{hostname}}.key"
   tls_disable          = false
}

storage "raft" {

   node_id              = "{{ inventory_hostname }}"
   path                 = "/opt/vault/data"

{% for host in groups['vault'] %}
{% if host != inventory_hostname %}
   retry_join {

      leader_api_addr   = "https://{{ host }}:8200"

   }

{% endif %}
{% endfor %}

}

cluster_addr            = "https://{{ inventory_hostname }}:8201"
api_addr                = "https://vault.{{ domain }}:8200"
max_lease_ttl           = "10h"
default_lease_ttl       = "10h"
cluster_name            = "auto_k8s_cluster_vault"
raw_storage_endpoint    = true
disable_sealwrap        = true
disable_printable_check = true

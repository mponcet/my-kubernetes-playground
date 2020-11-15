resource "local_file" "ansible_hosts" {
  content = templatefile("ansible_hosts.tmpl",
  {
    master_ip    = libvirt_domain.k8s_master.network_interface[0].addresses[0],
    master_name  = libvirt_domain.k8s_master.name,
    workers_ip   = libvirt_domain.k8s_worker[*].network_interface[0].addresses[0],
    workers_name = libvirt_domain.k8s_worker[*].name,
   }
  )
  filename = "ansible_hosts"
}

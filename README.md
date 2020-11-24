# My kubernetes playground

Create a kubernetes cluster using Terraform / Libvirt / Ansible

## Create k8s master and workers

### Install libvirt-nss

https://libvirt.org/nss.html

### Setup terraform (libvirt plugin)

```bash
mkdir -p ~/.local/share/terraform/plugins/registry.terraform.io/dmacvicar/libvirt/0.6.3/linux_amd64
cd ~/.local/share/terraform/plugins/registry.terraform.io/dmacvicar/libvirt/0.6.3/linux_amd64
wget https://github.com/dmacvicar/terraform-provider-libvirt/releases/download/v0.6.3/terraform-provider-libvirt-0.6.3+git.1604843676.67f4f2aa.Fedora_32.x86_64.tar.gz
tar xvzf terraform-provider-libvirt-0.6.3+git.1604843676.67f4f2aa.Fedora_32.x86_64.tar.gz
```

### Create VMs with terraform & libvirt

```bash
cd terraform
terraform init
terraform plan
terraform apply
ssh ubuntu@k8s-master
ssh ubuntu@k8s-worker-1
```

### Provision cluster with Ansible

```bash
cd ansible
ansible-playbook k8s_setup.yml -i ../terraform/ansible_hosts -u ubuntu
```

## Docs

https://github.com/dmacvicar/terraform-provider-libvirt

https://cloudinit.readthedocs.io/en/latest/index.html

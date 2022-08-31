output "jbs_ssh" {
  value = { for k, v in module.lx_jb : k => "ssh -i ${var.ssh_key_path}/${terraform.workspace} ${terraform.workspace}@${v.public_name}" }
}

output "vms_linux" {
  value = { for k, v in module.lx_vm : k => v.hostname }
}

output "vms_windows" {
  value = { for k, v in module.win_vm : k => v.hostname }
}

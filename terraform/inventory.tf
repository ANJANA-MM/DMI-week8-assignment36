resource "null_resource" "generate_inventory" {
  # Ensure this runs after VMs and public IPs are ready
  depends_on = [
    azurerm_linux_virtual_machine.minif_vm,
    azurerm_public_ip.minif_public_ip
  ]

  triggers = {
    # Trigger rerun if any VM IP changes
    vm_ip = azurerm_public_ip.minif_public_ip.ip_address
  }

  provisioner "local-exec" {
    command     = "terraform output -json vm_public_ip > terraform_output.json && python3 generate_inventory.py"
    working_dir = "${path.module}"  # ensures command runs in terraform folder
  }
}

import os
import json

# ensure output folder exists
output_dir = "../ansible"
os.makedirs(output_dir, exist_ok=True)

# Load Terraform output
with open("terraform_output.json") as f:
    data = json.load(f)  

# Assign VM to group
web = [data]  

# Generate inventory content
inventory_content = "[web]\n" + "\n".join(web) + "\n\n"
inventory_content += "[all:vars]\n"
inventory_content += "ansible_user=azureuser\n"
inventory_content += "ansible_ssh_private_key_file=/home/youruser/.ssh/id_ed25519\n"  # use absolute path

# Write inventory
with open(f"{output_dir}/inventory.ini", "w") as f:
    f.write(inventory_content)

print("inventory.ini generated successfully!")

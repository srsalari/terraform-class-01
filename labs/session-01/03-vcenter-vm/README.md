# Lab 1.3: The same VM, through vCenter

**Objectives:** 4a (resource vs data), 4b (references between resources)
**Platform:** 🟦 vSphere with vCenter · **Time:** 15 min (instructor demo; hands-on if you have a vCenter)

In Lab 1.2 Terraform talked straight to one ESXi host. Here it talks to **vCenter**, which manages that host. The VM is the same size (1 vCPU, 512 MB, empty 8 GB thin disk). What changes is how you find things and what you can create:

| | Lab 1.2: ESXi directly | Lab 1.3: vCenter |
|---|---|---|
| `VSPHERE_SERVER` | the ESXi host | the vCenter |
| Datacenter | `data "vsphere_datacenter" "dc" {}` (the built-in `ha-datacenter`) | must be named: `name = var.datacenter` |
| Host | `data "vsphere_host"` without a name (the only host) | must be named: `name = var.host` (vCenter may manage many hosts) |
| VM folders | don't exist | `vsphere_folder`, created by Terraform |
| VM ID (`moid`) | a number, e.g. `3` | `vm-1042` |
| Clone, customization, tags, OVF | not available | available (later in the course) |

> **Needs:** a vCenter that manages a **licensed** ESXi host, and a vCenter user that can create folders and VMs. A free-edition ESXi host cannot be added to vCenter.

## Step 1: Credentials and variables (3 min)

```bash
cd labs/session-01/03-vcenter-vm

export VSPHERE_SERVER="<VCENTER_IP>"
export VSPHERE_USER="administrator@vsphere.local"   # or your vCenter user
export VSPHERE_PASSWORD='********'
export VSPHERE_ALLOW_UNVERIFIED_SSL=true

cp terraform.tfvars.example terraform.tfvars
```

Fill in `terraform.tfvars` with names from **your** vCenter inventory (vSphere Client > *Hosts and Clusters*): the datacenter, and the host exactly as it is listed (often its IP address).

The `VSPHERE_*` variables are the same names as in Lab 1.2, so they now point to vCenter. Open a new terminal, or export them again, before going back to Lab 1.2.

## Step 2: Read the code (3 min)

Open `data.tf` and `main.tf` side by side with Lab 1.2 and find the three differences from the table above. In `main.tf`, find the line that makes the VM **depend on** the folder.

## Step 3: Init, plan, apply (6 min)

```bash
terraform init
terraform fmt -check && terraform validate
terraform plan
terraform apply
```

Look at the plan: **two** resources to add. In the apply output, `vsphere_folder.lab` is created **before** `vsphere_virtual_machine.vm`. Nobody wrote "create the folder first": Terraform worked it out from the reference `folder = vsphere_folder.lab.path`.

In the vSphere Client: *VMs and Templates* view > your datacenter > folder `s01-lab` > `s01-vc-vm01`.

## Step 4: Destroy (3 min)

This VM is only for comparison. Remove it:

```bash
terraform destroy
```

The order is reversed: the VM goes first, then the folder (a folder that still holds a VM cannot be deleted).

**Question:** the datacenter, host, datastore and network are still there after `destroy`. Why?

<details><summary>Answer</summary>

They are `data` sources: Terraform only reads them. `destroy` removes only what is declared in `resource` blocks and recorded in state: the folder and the VM.
</details>

## Troubleshooting

| Error | Likely cause |
|---|---|
| `datacenter '...' not found` | The name is case-sensitive; copy it from the vSphere Client |
| `host '...' not found` | Use the host name exactly as listed in vCenter (often the IP address) |
| `NoPermission` ... `Folder.Create` | Your vCenter user cannot create folders; ask for a role with *Folder > Create folder* on the datacenter |
| `Cannot complete login` | You exported the ESXi credentials; vCenter users look like `user@vsphere.local` |
| Power-on fails with `insufficient memory` | The host is out of RAM (vCenter itself needs 14 GB) |

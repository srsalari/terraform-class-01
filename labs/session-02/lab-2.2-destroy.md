# Lab 2.2: Destroy one VM, then everything

**Objective:** 3f (destroy) · **Platform:** 🟦 your ESXi host · **Time:** 1:10–1:30 (20 min)

Same folder: `labs/session-02/vm-lab`.

## Step 1: Add a second VM (5 min)

Append this to `main.tf`. It is a smaller copy of the first VM:

```hcl
resource "vsphere_virtual_machine" "test" {
  name             = "${var.student}-test01"
  resource_pool_id = data.vsphere_host.esxi.resource_pool_id
  datastore_id     = data.vsphere_datastore.ds.id

  num_cpus = 1
  memory   = 256
  guest_id = "ubuntu64Guest"

  network_interface {
    network_id   = data.vsphere_network.net.id
    adapter_type = "vmxnet3"
  }

  disk {
    label            = "disk0"
    size             = 1
    thin_provisioned = true
  }

  wait_for_guest_net_timeout = 0
}
```

```bash
terraform apply
```

`Plan: 1 to add, 0 to change, 0 to destroy.` The first VM is untouched.

## Step 2: The normal way to remove one VM: delete its code (5 min)

Terraform is declarative: the code says what should exist. To get rid of `test`, **delete the whole `resource "vsphere_virtual_machine" "test"` block** from `main.tf`, then:

```bash
terraform plan
```

`# vsphere_virtual_machine.test will be destroyed` and `(because vsphere_virtual_machine.test is not in configuration)`.

**Don't apply yet.** Undo the deletion (put the block back), and run `terraform plan` again: `No changes`.

## Step 3: `-target`, the exception (5 min)

```bash
terraform plan -destroy -target="vsphere_virtual_machine.test"
terraform destroy -target="vsphere_virtual_machine.test"
```

Read the warning Terraform prints:

```
Warning: Resource targeting is in effect
...
The -target option is not for routine use ...
```

Now run `terraform plan`. **Question:** what does it want to do, and why?

<details><summary>Answer</summary>

`1 to add`: it wants to create `test` again. The code still declares it, so the code and the real world disagree. `-target` changed the infrastructure but not the code. That's why it is for emergencies and recovery, and why deleting the block (Step 2) is the right way.
</details>

Delete the `test` block from `main.tf` now, so code and reality agree again. `terraform plan` → `No changes`.

## Step 4: Destroy everything, then rebuild (5 min)

```bash
terraform plan -destroy      # preview only, changes nothing
terraform destroy            # type "yes"
```

Look at the state now:

```bash
terraform state list         # empty
```

The state file still exists, but holds no resources. Rebuild for the next labs:

```bash
terraform apply
```

A new VM (new `moid`) with everything in your code: size, note, `shutdown_wait_timeout`.

> **Shared workplace ESXi:** `destroy` removes only the resources in **this folder's state**. It never touches your colleagues' VMs, even if they have similar names.

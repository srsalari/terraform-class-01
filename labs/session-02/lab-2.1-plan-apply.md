# Lab 2.1: Read a plan, then apply it

**Objectives:** 3d (plan), 3e (apply) · **Platform:** 🟦 your ESXi host · **Time:** 0:00–1:10 (2 × 35 min, with talk)

Everything in Session 2 happens in **one folder**: `labs/session-02/vm-lab`. You continue with the VM you built in Lab 1.2.

## Step 0: Move your VM into the new folder (10 min)

Terraform knows which VM is "yours" only from the **state file**. To keep managing the same VM from a new folder, the state has to come with you.

```bash
cd labs/session-02/vm-lab

# MOVE the state (don't copy it). Two folders with the same state would both
# think they own the VM: a destroy in the old folder would delete it.
mv ../../session-01/02-first-vm/terraform.tfstate .
cp ../../session-01/02-first-vm/terraform.tfvars .

# Did you change main.tf in Session 1 (more memory, a cdrom block to install
# Linux...)? Then bring YOUR main.tf too:
#   cp ../../session-01/02-first-vm/main.tf .

export VSPHERE_SERVER="<ESXI_IP>"
export VSPHERE_USER="root"            # or the ESXi user you were given
export VSPHERE_PASSWORD='********'
export VSPHERE_ALLOW_UNVERIFIED_SSL=true

terraform init
terraform plan
```

**Goal:** `No changes. Your infrastructure matches the configuration.`

| `plan` shows instead | Why | Fix |
|---|---|---|
| `memory = 2048 -> 512`, `- cdrom {...}` | You changed the VM in Session 1 but used the starting `main.tf` | Copy your Session 1 `main.tf` here |
| `+ create` for the VM | No state here (not moved, or you destroyed the VM in Session 1) | Move the state, or just `terraform apply` to build a new VM |
| `Error: ... already exists` on apply | The VM exists but Terraform has no state for it | Find your `terraform.tfstate`; if it is lost, delete the VM by hand in the Host Client and apply |

> **Shared workplace ESXi?** Terraform only touches what is in **its own state**. Other VMs on the host are invisible to it: never in a plan, never destroyed. Your `student` prefix keeps your names apart from colleagues' VMs.

## Step 1: A change that only Terraform sees (5 min)

Changing CPU or memory needs the VM powered off. Terraform first asks the guest OS to shut down and waits up to 3 minutes. A VM without an OS has no VMware Tools, so that wait is wasted. Add this line to the `vsphere_virtual_machine` resource in `main.tf`:

```hcl
  shutdown_wait_timeout = 1   # minutes; then Terraform powers the VM off
```

```bash
terraform plan
```

The plan shows `~ update in-place` for `shutdown_wait_timeout`. **Question:** does anything change on the ESXi host when you apply this?

<details><summary>Answer</summary>

No. `shutdown_wait_timeout` is a setting of the provider's resource, not of the VM. Terraform stores it in state only. Not every `~` means an API call.
</details>

```bash
terraform apply
```

## Step 2: Read a plan line by line (15 min)

Change the VM size in `main.tf`:

```hcl
  num_cpus = 2
  memory   = 1024
```

Save the plan to a file and look at it in three ways:

```bash
terraform plan -out=tfplan
terraform show tfplan                    # the same plan, read back from the file
terraform show -json tfplan | jq '.resource_changes[] | {address, actions: .change.actions}'
```

| Symbol | Meaning |
|---|---|
| `+` | create |
| `-` | destroy |
| `~` | update in place |
| `-/+` | destroy, then create a replacement |
| `+/-` | create the replacement first, then destroy (`create_before_destroy`, Session 4) |
| `<=` | read a data source during apply |

Look for the summary line: `Plan: 0 to add, 1 to change, 0 to destroy.`

> **`tfplan` can hold secrets** in plain text (variable values, attributes). It is in `.gitignore`. Never commit or share it.

## Step 3: Apply the saved plan (10 min)

```bash
terraform apply tfplan
```

No `yes` prompt this time: you already reviewed **exactly** this plan. That is how pipelines apply: plan in one step, review, apply the file.

Watch the Host Client while it runs: the VM powers **off**, gets the new size, and powers **on** again.

**Question:** the plan said "update in-place". Was there downtime?

<details><summary>Answer</summary>

Yes. In-place means the same VM object is kept (same `moid`, same UUID), not that the change is invisible. Without CPU/memory hot-add the VM must be powered off.
</details>

Now try `terraform apply tfplan` **again**:

```
Error: Saved plan is stale
```

A saved plan is tied to the state it was made from. Once applied, it can't be used again.

## Step 4: Force a replacement (15 min)

Note your VM's ID first:

```bash
terraform output vm_moid
```

Sometimes a VM is broken in a way Terraform can't see, and you want a fresh one. Ask for a replacement explicitly:

```bash
terraform plan -replace="vsphere_virtual_machine.vm"
```

The plan shows `-/+` and `# vsphere_virtual_machine.vm will be replaced, as requested`.

```bash
terraform apply -replace="vsphere_virtual_machine.vm"
terraform output vm_moid
```

The `moid` (and `vm_uuid`) changed: this is a **new** VM with the same name. Everything inside the old VM's disk is gone.

> `terraform taint` did the same in older versions. It is deprecated: use `-replace`.

## Step 5: A change without a power cycle (5 min, if time allows)

Add a note to the VM:

```hcl
  annotation = "Managed by Terraform. Owner: s01"
```

`plan`, then `apply`. Notes change while the VM keeps running. You will use this field again in Lab 2.4 (drift).

## Troubleshooting

| Problem | Likely cause |
|---|---|
| Apply waits about 1 minute at `Still modifying...` | Normal: it waits `shutdown_wait_timeout`, then powers the VM off |
| `Error: Saved plan is stale` | The state changed after `plan -out`. Run `plan -out=tfplan` again |
| `jq: command not found` | Install jq (`brew install jq`, `winget install jqlang.jq`, `sudo apt install jq`), or skip the jq line |
| Power-on fails: `insufficient memory` | The host is out of RAM. Use `memory = 1024` or less |

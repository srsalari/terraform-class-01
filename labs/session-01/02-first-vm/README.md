# Lab 1.2: Your first VM on vSphere

**Objectives:** 3a (workflow), 3b (init), 3c (validate), 3g (fmt), 4a (resource vs data)
**Platform:** 🟦 vSphere · **Time:** 30 min instructor talk/demo + 50 min lab

You'll create one small VM on an ESXi host, straight from your own laptop, and go through the whole workflow on the way:

```
write → init → fmt → validate → plan → apply
```

> **No vCenter needed.** Terraform talks straight to an ESXi host. The VM is built from scratch (1 vCPU, 512 MB, an empty 8 GB thin disk, no operating system yet), because cloning from a template needs vCenter.
>
> **Which ESXi?** Use the licensed ESXi host you were given. If you only have the free ESXi from the nested-ESXi guide, every step works except `apply`: the free licence makes the API read-only, and apply fails with *"current license or ESXi version prohibits execution of the requested operation"*. That is expected; follow the instructor's demo for the apply step.
>
> **Keep your VM at the end.** Session 2 continues with it.

## The files

| File | What it holds |
|---|---|
| `versions.tf` | Required Terraform version and providers |
| `provider.tf` | The vSphere provider. Credentials come from environment variables, never from code |
| `variables.tf` | Inputs: your ID, datastore and network (with defaults that match a fresh ESXi) |
| `data.tf` | **Data sources** that read existing objects on the ESXi host |
| `main.tf` | **Resource**: the VM that Terraform creates and manages |
| `outputs.tf` | Values printed after apply. *Badly formatted on purpose* |

## Step 1: Credentials and variables (5 min)

```bash
cd labs/session-01/02-first-vm

export VSPHERE_SERVER="<ESXI_IP>"           # your ESXi host
export VSPHERE_USER="root"                  # or the ESXi user you were given
export VSPHERE_PASSWORD='********'
export VSPHERE_ALLOW_UNVERIFIED_SSL=true

cp terraform.tfvars.example terraform.tfvars
# set student to your ID; change datastore/network only if your host uses other names
```

`terraform.tfvars` is listed in `.gitignore`. Why is that a good habit, even though this file holds no secrets?

## Step 2: Initialize (5 min)

```bash
terraform init
```

- Find the provider in the output. Its source is **`vmware/vsphere`**, not `hashicorp/vsphere`. The provider moved to a new namespace, and the old address stopped receiving updates at 2.12. The **source address** (`<host>/<namespace>/<type>`) is how Terraform finds a provider.
- `init` downloads providers, sets up the backend (local by default) and installs modules. Run it again whenever any of those change. Running it twice is safe.

## Step 3: Format (5 min)

```bash
terraform fmt -check       # lists the files that need formatting; exits non-zero
terraform fmt -diff        # shows the changes and applies them
terraform fmt -check       # now silent, exit code 0
```

`fmt` only changes layout: indentation and lining up the `=` signs. It never changes what the code means. Use `-recursive` for subfolders. `fmt -check` is a common check in CI pipelines.

## Step 4: Validate (10 min)

```bash
terraform validate
```

Now break the configuration on purpose, one change at a time. Run `validate` after each change, then undo it:

1. In `main.tf`, change `data.vsphere_datastore.ds.id` to `data.vsphere_datastore.dss.id`.
2. Remove the `}` that closes the `disk` block.
3. Change `num_cpus = 1` to `num_cpus = "one"`.
4. In `terraform.tfvars`, change `datastore` to a name that doesn't exist.

**Question:** which of these did `validate` catch, and which one got through? Why?

<details><summary>Answer</summary>

`validate` caught 1 to 3. They are syntax, reference and type errors, and it can find them without contacting ESXi.
Change 4 passes `validate`, because validate never calls any API. It is caught only by `plan`, when the data source looks up the datastore and finds nothing.
</details>

## Step 5: Plan and apply (20 min)

```bash
terraform plan
terraform apply            # review the plan, then type "yes"
```

Creating the VM takes a few seconds. Then look back at the plan output:
- Data sources are read during the plan. They don't appear as `+ create`.
- Which values show as `(known after apply)`? Why can't Terraform know them earlier?

When it finishes:

```bash
terraform output
terraform output -raw vm_power_state
```

Open the ESXi Host Client (`https://<ESXI_IP>/ui`) > *Virtual Machines* and find your VM. Open its console: it is powered on but shows "no operating system", which is correct for now. Installing an OS automatically comes later in the course.

**Run `terraform plan` again.** It reports *No changes*: the real VM matches the code.

## Step 6: Resource vs data (5 min, discussion)

| | `resource` | `data` |
|---|---|---|
| Purpose | Create and manage an object | Read an existing object |
| Lifecycle | create / update / destroy | read only |
| Address | `vsphere_virtual_machine.vm` | `data.vsphere_datastore.ds` |
| In this lab | the VM | datacenter, datastore, network, host |

**Question:** what happens to the datastore when you run `terraform destroy`?

## Extra exercise (if you finish early)

Add an output called `datastore_id` that shows `data.vsphere_datastore.ds.id`. Run `terraform apply` again. Notice that the plan reports **no infrastructure changes**, only the new output.

## Troubleshooting

| Error | Likely cause |
|---|---|
| `x509: certificate signed by unknown authority` | `VSPHERE_ALLOW_UNVERIFIED_SSL` isn't set |
| `ServerFaultCode: Cannot complete login due to an incorrect user name or password` | Wrong user or password, or the host is in lockdown mode (managed by a vCenter that blocks direct logins) |
| `datastore '...' not found` | A typo in tfvars; check the name in the Host Client under *Storage* |
| `network '...' not found` | Port group name is case-sensitive: `VM Network` |
| `current license or ESXi version prohibits execution of the requested operation` | Free ESXi licence: the API is read-only. Plan works, apply doesn't. Use a licensed host |
| `The name '...' already exists` | Someone on the same host used the same `student` value; pick a unique one |
| Power-on fails with `insufficient memory` | The host is out of RAM; power off other VMs |

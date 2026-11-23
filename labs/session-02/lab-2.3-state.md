# Lab 2.3: Look inside the state

**Objectives:** 2d, 6a (what state is for), 7b (inspect state from the CLI) · **Platform:** 🟦 your ESXi host · **Time:** 2:15–3:00 (45 min)

Same folder: `labs/session-02/vm-lab`, with the VM you rebuilt at the end of Lab 2.2.

## Step 1: The state file is JSON (10 min)

```bash
ls -l terraform.tfstate terraform.tfstate.backup
jq '{version, terraform_version, serial, lineage}' terraform.tfstate
jq -r '.resources[] | "\(.mode)  \(.type).\(.name)"' terraform.tfstate
```

| Field | What it is for |
|---|---|
| `serial` | Goes up by one every time the state is written. Shows which copy is newer |
| `lineage` | A unique ID given when the state was first created. Two states with different lineages are not versions of the same thing |
| `resources` | One entry per resource **and per data source** (`mode: "data"`), with every attribute |
| `terraform.tfstate.backup` | The previous version, written automatically before each change |

**Question:** your configuration has one VM. Why are there five entries?

<details><summary>Answer</summary>

One `managed` resource (the VM) and four `data` sources (datacenter, host, datastore, network). Data sources are recorded too, with the values read during the last run.
</details>

> **Never edit `terraform.tfstate` by hand**, and never commit it: it can hold passwords and other secrets in plain text. Session 6 moves it to a shared, locked backend.

## Step 2: `state list` and `state show` (10 min)

```bash
terraform state list
terraform state show vsphere_virtual_machine.vm
terraform state show data.vsphere_datastore.ds
```

- `state list` prints **addresses**: `vsphere_virtual_machine.vm`, `data.vsphere_datastore.ds`...
- `state show <address>` prints every attribute Terraform knows about one object, including values you never wrote in code (`moid`, `uuid`, `power_state`, disk details).

Find in the `state show` output: the VM's `moid`, its `memory`, and the datastore's `stats` (free and total capacity, in the data source).

## Step 3: `show` and `show -json` (15 min)

```bash
terraform show                        # the whole state, human readable
terraform show -json | jq '.values.root_module.resources[] | {address, mode}'
terraform show -json | jq '.values.root_module.resources[] | select(.mode=="managed") | .values | {name, num_cpus, memory, moid}'
```

`show -json` is the stable, machine-readable format. Scripts and CI tools read this, not the raw `terraform.tfstate`, because the raw file layout can change between versions.

## Step 4: Outputs come from state (5 min)

```bash
terraform output
terraform output -raw vm_moid
terraform output -json | jq .
```

`terraform output` does not call ESXi. It reads the values saved in state at the last apply. **Try it:** set `export VSPHERE_PASSWORD=wrong` and run `terraform output` again. It still works. Then run `terraform plan`: it fails at login. Put the right password back.

## Step 5: Why Terraform needs state at all (5 min, discussion)

| Purpose | In this lab |
|---|---|
| **Mapping** code to real objects | `vsphere_virtual_machine.vm` ↔ the VM with this `moid` |
| **Metadata** such as dependencies | The VM depends on four data sources; destroy order comes from here |
| **Performance** | Terraform knows what exists without listing the whole host |

**Question:** you delete `terraform.tfstate` (don't!). What would `terraform plan` show?

<details><summary>Answer</summary>

`1 to add`: Terraform no longer knows the VM exists, so it plans to create it. The apply would fail with "already exists" (same name). The real VM would be orphaned: still running, but unmanaged. Recovering means importing it (Session 6).
</details>

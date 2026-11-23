# Lab 2.4: Drift, someone changed the VM by hand

**Objective:** 6d (drift and refresh-only) · **Platform:** 🟦 your ESXi host · **Time:** 3:00–3:25 (25 min)

Same folder: `labs/session-02/vm-lab`. Your VM has the note from Lab 2.1 Step 5 (`annotation = "Managed by Terraform. Owner: s01"`). If you skipped that step, add it and apply first.

## Step 1: Change the VM outside Terraform (5 min)

Pretend a colleague edits the VM in the Host Client. Do **one** of these:

- **Host Client:** `https://<ESXI_IP>/ui` > *Virtual Machines* > your VM > *Edit settings* > *VM Options* > *General Options* > *Notes*: type `Changed by hand`, then *Save*. (Menu names can differ slightly by ESXi version.)
- **govc** (check `govc vm.change -h` first):

  ```bash
  export GOVC_URL=$VSPHERE_SERVER GOVC_USERNAME=$VSPHERE_USER GOVC_PASSWORD=$VSPHERE_PASSWORD GOVC_INSECURE=1
  govc vm.change -vm s01-vm01 -annotation "Changed by hand"
  ```

## Step 2: Terraform notices (5 min)

```bash
terraform plan
```

```
Note: Objects have changed outside of Terraform
...
  ~ annotation = "Managed by Terraform. Owner: s01" -> "Changed by hand"
...
  ~ annotation = "Changed by hand" -> "Managed by Terraform. Owner: s01"
```

`plan` **refreshes** first: it reads the real VM, reports what changed outside Terraform, then plans to put the VM back the way the code says.

## Step 3: Accept the change into state: `-refresh-only` (5 min)

What if the hand change was right, and you want to keep it?

```bash
terraform plan -refresh-only
terraform apply -refresh-only     # type "yes"
```

A refresh-only apply updates the **state** to match reality. It never changes the VM.

Now run a normal plan again:

```bash
terraform plan
```

**Question:** it still wants to change the note back. Why?

<details><summary>Answer</summary>

`-refresh-only` updated the state, not the code. The code still says `annotation = "Managed by Terraform. Owner: s01"`, so a normal plan still wants to apply it. To really keep a hand change, change the code too, or tell Terraform to ignore that attribute (Step 4).
</details>

> `terraform refresh` is the old command for the same thing. It is deprecated because it updates state **without** showing you the changes first. Use `apply -refresh-only`.

## Step 4: Ignore an attribute on purpose (5 min)

Some attributes are meant to be edited by people (notes, tags set by a backup tool...). Add this inside the `vsphere_virtual_machine "vm"` block:

```hcl
  lifecycle {
    ignore_changes = [annotation]
  }
```

```bash
terraform plan
```

`No changes`. Terraform still reads the note, but no longer tries to correct it. Change the note again in the Host Client and plan: still `No changes`.

## Step 5: Clean up (5 min)

**Keep your VM:** Session 3 continues from this folder and this state.

Two choices, depending on your instructor's instructions:

- **Keep (default):** do nothing. Leave `terraform.tfstate` in `vm-lab`.
- **Free the host's RAM until next session:** `terraform destroy`. Next session starts with `terraform apply`.

## Troubleshooting

| Problem | Likely cause |
|---|---|
| `plan` shows no drift | The note was changed on another VM, or not saved. Check the name |
| govc: `vm 's01-vm01' not found` | Set `GOVC_URL` etc. as in Step 1, and use your own VM name |
| `ignore_changes` gives `Unsupported attribute` | Put `lifecycle` **inside** the resource block; list attribute names without quotes |

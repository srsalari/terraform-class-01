# Session 2: Core workflow & state

3:30 in total: 3:15 of teaching plus one 15-minute break. Objectives: 2d, 3d, 3e, 3f, 6a, 6d, 7b.

| Time | Block | Material |
|---|---|---|
| 0:00 | Move the Session 1 VM into `vm-lab`; reading a plan, saved plans (3d) | [Lab 2.1](lab-2.1-plan-apply.md), steps 0–2 |
| 0:35 | Apply: in-place vs replacement, `-replace` (3e) | Lab 2.1, steps 3–5 |
| 1:10 | Destroy, `plan -destroy`, `-target` with care (3f) | [Lab 2.2](lab-2.2-destroy.md) |
| 1:30 | **Break** | |
| 1:45 | How Terraform uses state; the local backend (2d, 6a) | Slides |
| 2:15 | Inspect state from the CLI (7b) | [Lab 2.3](lab-2.3-state.md) |
| 3:00 | Drift: `-refresh-only`, `ignore_changes` (6d) | [Lab 2.4](lab-2.4-drift.md) |
| 3:25 | Recap | Quiz (in class) |

All labs run in **one folder**, [`vm-lab/`](vm-lab), which continues with the VM from Lab 1.2.

## Lab platform: the team's own ESXi at work

Each student runs Terraform **from their own laptop** against the team's ESXi server at their workplace, straight to the host, no vCenter needed.

- **Shared host:** every student uses a unique `student` ID (`s01`, `s02`...). VM names are `sNN-vm01` and, in Lab 2.2, `sNN-test01`.
- **Terraform only touches what is in its own state.** Other VMs on the host never appear in a plan and are never destroyed. Still: run `plan` and read it before every `apply`.
- **Resources:** at most 2 small VMs per student at a time (1 GB + 256 MB RAM, thin disks of 8 GB + 1 GB). No OS is installed.
- **ESXi user:** `root`, or an ESXi user whose role can create, reconfigure, power and delete VMs on the host (the built-in *Administrator* role is enough).
- **Host managed by vCenter, direct logins blocked (lockdown mode)?** Point `VSPHERE_SERVER` at the vCenter and set `datacenter` and `host` in `terraform.tfvars` (see `terraform.tfvars.example`).
- **Free ESXi only (nested, read-only API):** `plan`, `show` and the state commands work; every `apply` and `destroy` fails with a licence error. Follow the demo for those steps.

# Session 1: Foundations & first VM

3:30 in total: 3:15 of teaching plus one 15-minute break. Objectives: 1a–c, 2a–b, 3a–c, 3g, 4a.

| Time | Block | Material |
|---|---|---|
| 0:00 | Welcome, laptop pre-check | [`00-precheck/precheck.sh`](00-precheck/precheck.sh) |
| 0:15 | IaC concepts and benefits (1a, 1b) | Slides |
| 0:45 | Multi-cloud, hybrid-cloud and service-agnostic workflows (1c) | Slides |
| 1:05 | Providers, versions, lock file (2a, 2b) | [Lab 1.1: `01-providers`](01-providers/README.md) |
| 1:40 | **Break** | |
| 1:55 | Workflow overview, vSphere provider, `init` (3a, 3b) | [Lab 1.2: `02-first-vm`](02-first-vm/README.md), steps 1–2 (instructor demo) |
| 2:25 | First VM on ESXi: fmt, validate, plan, apply (3c, 3g, 4a) | Lab 1.2, steps 3–6 |
| 3:00 | The same VM through vCenter, a folder, dependencies (4a, 4b) | [Lab 1.3: `03-vcenter-vm`](03-vcenter-vm/README.md) (demo; hands-on with a vCenter) |
| 3:15 | Recap | Quiz (in class) |

## Lab platform

Students run Terraform on **their own laptops** against an **ESXi host directly, with no vCenter**:

- **Licensed ESXi** (the team's host): the whole lab works, including `apply`. Several students can share one host; the `student` prefix keeps VM names apart.
- **Free ESXi** (nested on VMware Workstation, see [optional-nested-esxi-fa.docx](optional-nested-esxi-fa.docx)): everything except `apply`, because the free licence makes the API read-only.
- **No ESXi at all** (e.g. Apple Silicon Mac): `init`, `fmt` and `validate` still work; follow the instructor's demo for `plan` and `apply`.

The instructor demos Lab 1.2 on a licensed ESXi host and Lab 1.3 on vCenter. On a 16 GB server vCenter uses 14 GB by itself, so the Lab 1.3 VM (512 MB) may only power on with vCenter's memory overcommitted; run Lab 1.3 last and destroy its VM right away.

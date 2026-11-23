# Lab 1.1: Providers, versions and the lock file

**Objectives:** 2a (install and version providers), 2b (how Terraform uses providers)
**Platform:** ⬜ platform-free (`random`, `local`) · **Time:** 35 min (including the instructor talk)

These two providers need no credentials and no cloud. That lets us study *how* providers work without any infrastructure getting in the way.

## Part A: Install the providers (10 min)

```bash
cd labs/session-01/01-providers
terraform version
terraform init
```

Read the `init` output and answer:
1. Which provider versions were installed? Why those versions?
2. Where did Terraform download them from?

Look at what `init` created:

```bash
find .terraform -maxdepth 6 | head -20
cat .terraform.lock.hcl
terraform providers
```

**Discussion points:**
- Each provider is a **separate executable (plugin)**. Terraform Core talks to it over RPC. The path under `.terraform/providers/` is
  `<hostname>/<namespace>/<type>/<version>/<os_arch>/`.
- `hashicorp/random` is short for `registry.terraform.io/hashicorp/random`. The Registry hostname is implied.
- `.terraform/` is a local cache, so **don't commit it**. `.terraform.lock.hcl` records exact versions and checksums, so **do commit it**.

## Part B: Use the providers (5 min)

```bash
terraform apply        # type "yes"
cat out/inventory.txt
terraform output server_name
```

## Part C: Version constraints and the lock file (15 min)

1. In `versions.tf`, change the `random` constraint to an exact older version:

   ```hcl
   version = "= 3.6.0"
   ```

2. Run `terraform init`. **It fails.** Read the error: the lock file records a newer version that no longer satisfies the constraint.
3. Run `terraform init -upgrade`. This lets Terraform pick a new version and rewrite the lock file. Check the result with `cat .terraform.lock.hcl`.
4. Set the constraint back to `~> 3.6` and run `terraform init -upgrade` again.

**Constraint cheat sheet:**

| Constraint | Means |
|---|---|
| `= 3.6.0` | exactly 3.6.0 |
| `>= 3.6` | 3.6 or newer, including 4.x and later |
| `~> 3.6` | ≥ 3.6 and < 4.0 (only the right-most number may increase) |
| `~> 3.6.0` | ≥ 3.6.0 and < 3.7.0 |
| `>= 3.6, < 3.8` | a range |

## Part D: `required_version` (5 min)

Change `required_version` to `">= 99.0.0"` and run `terraform plan`. Read the error, then change it back.

## Clean up

```bash
terraform destroy      # type "yes"
```

## Extra: where else can providers come from?

Terraform looks in the **Registry** by default. Two other options matter in locked-down VMware environments:
- `terraform providers mirror ./mirror` downloads providers into a folder. A `provider_installation { filesystem_mirror { ... } }` block in `~/.terraformrc` can then point to it.
- `TF_PLUGIN_CACHE_DIR` shares one download cache across all your projects.

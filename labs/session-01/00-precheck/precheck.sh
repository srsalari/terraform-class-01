#!/usr/bin/env bash
# Session 1 pre-check: confirms each laptop is ready for the course.
# Usage:  ./precheck.sh
# Optional: export GOVC_URL=<ESXI_IP> GOVC_USERNAME / GOVC_PASSWORD / GOVC_INSECURE=1
#           first to also test the ESXi login and licence.

MIN_TF="1.12.0"
pass=0; warn=0; fail=0

ok()   { printf "  \033[32m[PASS]\033[0m %s\n" "$1"; pass=$((pass+1)); }
wn()   { printf "  \033[33m[WARN]\033[0m %s\n" "$1"; warn=$((warn+1)); }
bad()  { printf "  \033[31m[FAIL]\033[0m %s\n" "$1"; fail=$((fail+1)); }

# Returns 0 if version $1 >= version $2
ver_ge() { [ "$(printf '%s\n%s\n' "$2" "$1" | sort -V | head -n1)" = "$2" ]; }

echo "== Required tools"
if command -v terraform >/dev/null 2>&1; then
  tfv=$(terraform version -json 2>/dev/null | sed -n 's/.*"terraform_version": *"\([^"]*\)".*/\1/p')
  if ver_ge "$tfv" "$MIN_TF"; then ok "terraform $tfv"; else bad "terraform $tfv is older than $MIN_TF"; fi
else
  bad "terraform not found"
fi

for t in git; do
  if command -v $t >/dev/null 2>&1; then ok "$t found"; else bad "$t not found"; fi
done

echo "== Recommended tools"
for t in aws govc jq code; do
  if command -v $t >/dev/null 2>&1; then ok "$t found"; else wn "$t not found (needed later in the course)"; fi
done

echo "== Network access (provider downloads)"
for url in https://registry.terraform.io/.well-known/terraform.json https://releases.hashicorp.com/ https://github.com/; do
  if curl -s -o /dev/null -m 10 -w "%{http_code}" "$url" | grep -qE '^(200|301|302)$'; then
    ok "reach $url"
  else
    bad "cannot reach $url (ask the instructor about the provider mirror)"
  fi
done

echo "== ESXi host"
if [ -n "$GOVC_URL" ] && command -v govc >/dev/null 2>&1; then
  if govc about >/dev/null 2>&1; then
    ok "govc login to $GOVC_URL ($(govc about 2>/dev/null | sed -n 's/^FullName: *//p'))"
    lic=$(govc license.ls 2>/dev/null | sed -n 's/^ *Name: *//p' | head -n1)
    case "$lic" in
      *[Ff]ree*|*[Hh]ypervisor*) wn "licence: $lic (read-only API: plan works, apply will fail)";;
      "") wn "could not read the licence";;
      *) ok "licence: $lic";;
    esac
  else
    bad "govc cannot log in to $GOVC_URL"
  fi
else
  wn "skipped (set GOVC_URL and install govc to test)"
fi

echo "== AWS (used from Session 5)"
if command -v aws >/dev/null 2>&1 && aws sts get-caller-identity >/dev/null 2>&1; then
  ok "AWS credentials work"
else
  wn "AWS credentials not set up yet"
fi

echo
echo "Result: $pass passed, $warn warnings, $fail failed"
[ "$fail" -eq 0 ]

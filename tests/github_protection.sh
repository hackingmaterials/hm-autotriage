#!/usr/bin/env bash
# setup.sh opens .github/ to the bots in mayhem or with --edit-github yes,
# but its workflows and the bots' own files stay protected in every mode.
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"
repo=mergatron-test/github-protection-test
out=output/github-protection-test
trap 'rm -rf "$out"' EXIT
failed=0

# Usage: check "<setup.sh options>" yes|no
# yes|no: whether an ordinary .github/ file is protected.
check() {
  # shellcheck disable=SC2086
  if ! bash setup.sh --repo "$repo" --maintainer @someone $1 </dev/null >/dev/null 2>&1; then
    echo "FAIL: setup.sh $1 exited with an error"
    failed=1
    return
  fi
  local f want got
  for f in .github/ISSUE_TEMPLATE/bug.md .github/dependabot.yml \
    .github/workflows/ci.yml .github/workflows/mergatron.yml \
    .github/mergatron.conf .github/mergatron_guard.sh .github/autofix_rules.md \
    .github/CODEOWNERS; do
    want=yes
    case "$f" in .github/ISSUE_TEMPLATE/* | .github/dependabot.yml) want="$2" ;; esac
    # shellcheck disable=SC1091
    got=$(
      cd "$out"
      source .github/mergatron_lib.sh
      load_conf .github/mergatron.conf
      if matches_any "$f" "${protected[@]}"; then echo yes; else echo no; fi
    )
    if [[ "$got" != "$want" ]]; then
      echo "FAIL: setup.sh $1: $f protected '$got', expected '$want'"
      failed=1
    fi
  done
}

check "--mode conservative" yes
check "--mode conservative --edit-github yes" yes
check "--mode normal" yes
check "--mode normal --edit-github yes" no
check "--mode normal --no-autofix --edit-github yes" no
check "--mode mayhem" no
check "--mode mayhem --edit-github no" yes

if bash setup.sh --repo "$repo" --maintainer @someone --edit-github maybe </dev/null >/dev/null 2>&1; then
  echo "FAIL: setup.sh accepted --edit-github maybe"
  failed=1
fi

exit $failed

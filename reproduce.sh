#!/usr/bin/env bash
set -euo pipefail

root="$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
selected="all"
skip_runtime=0
include_archive=0

usage() {
  echo "Usage: ./reproduce.sh [--case 001|002|003|004|005|archive-771|all] [--skip-runtime] [--include-archive]"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --case)
      [[ $# -ge 2 ]] || { usage >&2; exit 2; }
      selected="$2"
      shift 2
      ;;
    --skip-runtime)
      skip_runtime=1
      shift
      ;;
    --include-archive)
      include_archive=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "error: unknown argument: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

case "$selected" in
  001|002|003|004|005|archive-771|all) ;;
  *)
    echo "error: unsupported case: $selected" >&2
    usage >&2
    exit 2
    ;;
esac

"$root/scripts/setup_dependencies.sh"

dafny_bin="${DAFNY_BIN:-$root/.tools/dafny-4.3.0/dafny/dafny}"
benchmark_dir="${DAFNYBENCH_DIR:-$root/third_party/DafnyBench}"
dafny_cores="${DAFNY_CORES:-2}"
[[ "$dafny_cores" =~ ^[1-9][0-9]*$ ]] || {
  echo "error: DAFNY_CORES must be a positive integer" >&2
  exit 2
}
run_id="$(date -u +%Y%m%dT%H%M%SZ)-$$"
logs_dir="$root/.repro/runs/$run_id/logs"
runtime_dir="$root/.repro/runs/$run_id/runtime"
mkdir -p "$logs_dir" "$runtime_dir"
echo "Dafny cores: $dafny_cores"

if [[ $skip_runtime -eq 0 &&
      ("$selected" == "all" || "$selected" == "001" || "$selected" == "003") ]]; then
  command -v python3 >/dev/null 2>&1 || {
    echo "error: python3 is required for runtime counterexamples; use --skip-runtime to omit them" >&2
    exit 1
  }
fi

run_ok() {
  local label="$1"
  local expected="$2"
  shift 2
  local log="$logs_dir/$label.log"
  local rc

  echo "== $label"
  if "$@" >"$log" 2>&1; then rc=0; else rc=$?; fi
  if [[ $rc -ne 0 ]] || ! grep -Fq "$expected" "$log"; then
    echo "unexpected result (exit $rc); full output:" >&2
    sed -n '1,240p' "$log" >&2
    exit 1
  fi
  grep -F "Dafny program verifier finished" "$log" | tail -n 1
}

run_expected_fail() {
  local label="$1"
  local expected="$2"
  shift 2
  local log="$logs_dir/$label.log"
  local rc

  echo "== $label (expected verifier failure)"
  if "$@" >"$log" 2>&1; then rc=0; else rc=$?; fi
  if [[ $rc -eq 0 ]] || ! grep -Fq "$expected" "$log"; then
    echo "recorded failure did not reproduce as expected (exit $rc); full output:" >&2
    sed -n '1,240p' "$log" >&2
    exit 1
  fi
  grep -F "Dafny program verifier finished" "$log" | tail -n 1
}

stage_runtime_case() {
  local id="$1"
  local case_dir="$2"
  local reference_rel="$3"
  local stage="$runtime_dir/$id"
  local staged_case="$stage/$case_dir"
  local staged_reference="$stage/third_party/DafnyBench/$reference_rel"

  mkdir -p "$staged_case" "$(dirname "$staged_reference")"
  cp "$root/$case_dir/comparison_harness.dfy" "$staged_case/"
  cp "$root/$case_dir/generated_attempt_01.dfy" "$staged_case/"
  cp "$benchmark_dir/$reference_rel" "$staged_reference"
  echo "$staged_case/comparison_harness.dfy"
}

run_runtime_001() {
  if [[ $skip_runtime -eq 1 ]]; then
    return 0
  fi
  local reference_rel="DafnyBench/dataset/ground_truth/AssertivePrograming_tmp_tmpwf43uz0e_Find_Substring.dfy"
  local staged
  staged="$(stage_runtime_case 001 case_001_substring_occurrence "$reference_rel")"
  run_ok "001-runtime" "Dafny program verifier finished with 1 verified, 0 errors" \
    "$dafny_bin" run --cores "$dafny_cores" "$staged" -t:py
  grep -Fq 'ground truth: ok=false, index=1' "$logs_dir/001-runtime.log"
  grep -Fq 'generated:    ok=false, index=0' "$logs_dir/001-runtime.log"
}

run_runtime_003() {
  if [[ $skip_runtime -eq 1 ]]; then
    return 0
  fi
  local reference_rel="DafnyBench/dataset/ground_truth/Program-Verification-Dataset_tmp_tmpgbdrlnu__Dafny_from dafny main repo_dafny2_COST-verif-comp-2011-3-TwoDuplicates.dfy"
  local staged
  staged="$(stage_runtime_case 003 case_003_repeated_value_pair "$reference_rel")"
  run_ok "003-runtime" "Dafny program verifier finished with 1 verified, 0 errors" \
    "$dafny_bin" run --cores "$dafny_cores" "$staged" -t:py
  grep -Fq 'ground truth: (1, 0)' "$logs_dir/003-runtime.log"
  grep -Fq 'generated:    (0, 1)' "$logs_dir/003-runtime.log"
  grep -Fq 'ground truth: (2, 1)' "$logs_dir/003-runtime.log"
  [[ "$(grep -Fc 'generated:    (0, 1)' "$logs_dir/003-runtime.log")" -eq 2 ]]
}

run_001() {
  local case_dir="$root/case_001_substring_occurrence"
  local reference="$benchmark_dir/DafnyBench/dataset/ground_truth/AssertivePrograming_tmp_tmpwf43uz0e_Find_Substring.dfy"
  run_ok "001-reference" "Dafny program verifier finished with 12 verified, 0 errors" "$dafny_bin" verify --cores "$dafny_cores" "$reference"
  run_ok "001-generated" "Dafny program verifier finished with 3 verified, 0 errors" "$dafny_bin" verify --cores "$dafny_cores" "$case_dir/generated_attempt_01.dfy"
  run_ok "001-combined" "Dafny program verifier finished with 16 verified, 0 errors" "$dafny_bin" verify --cores "$dafny_cores" --verify-included-files "$case_dir/comparison_harness.dfy"
  run_runtime_001
}

run_002() {
  local case_dir="$root/case_002_local_transition_trace"
  local reference="$benchmark_dir/DafnyBench/dataset/ground_truth/DafnyPrograms_tmp_tmp74_f9k_c_automaton.dfy"
  run_ok "002-reference" "Dafny program verifier finished with 3 verified, 0 errors" "$dafny_bin" verify --cores "$dafny_cores" "$reference"
  run_expected_fail "002-generated" "Dafny program verifier finished with 3 verified, 2 errors" "$dafny_bin" verify --cores "$dafny_cores" "$case_dir/generated_attempt_01.dfy"
}

run_003() {
  local case_dir="$root/case_003_repeated_value_pair"
  local reference="$benchmark_dir/DafnyBench/dataset/ground_truth/Program-Verification-Dataset_tmp_tmpgbdrlnu__Dafny_from dafny main repo_dafny2_COST-verif-comp-2011-3-TwoDuplicates.dfy"
  run_ok "003-reference" "Dafny program verifier finished with 4 verified, 0 errors" "$dafny_bin" verify --cores "$dafny_cores" "$reference"
  run_ok "003-generated" "Dafny program verifier finished with 18 verified, 0 errors" "$dafny_bin" verify --cores "$dafny_cores" "$case_dir/generated_attempt_01.dfy"
  run_ok "003-combined" "Dafny program verifier finished with 23 verified, 0 errors" "$dafny_bin" verify --cores "$dafny_cores" --verify-included-files "$case_dir/comparison_harness.dfy"
  run_runtime_003
}

run_004() {
  local case_dir="$root/case_004_four_kind_arrangement"
  local reference="$benchmark_dir/DafnyBench/dataset/ground_truth/formal_verication_dafny_tmp_tmpwgl2qz28_Challenges_ex7.dfy"
  run_ok "004-reference" "Dafny program verifier finished with 6 verified, 0 errors" "$dafny_bin" verify --cores "$dafny_cores" "$reference"
  run_ok "004-generated" "Dafny program verifier finished with 18 verified, 0 errors" "$dafny_bin" verify --cores "$dafny_cores" "$case_dir/generated_attempt_01.dfy"
  run_ok "004-combined" "Dafny program verifier finished with 49 verified, 0 errors" "$dafny_bin" verify --cores "$dafny_cores" --verify-included-files "$case_dir/comparison_harness.dfy"
}

run_005() {
  local case_dir="$root/case_005_tree_window"
  local reference="$benchmark_dir/DafnyBench/dataset/ground_truth/dafny-rope_tmp_tmpl4v_njmy_Rope.dfy"
  run_ok "005-reference" "Dafny program verifier finished with 21 verified, 0 errors" "$dafny_bin" verify --cores "$dafny_cores" "$reference"
  run_ok "005-generated" "Dafny program verifier finished with 3 verified, 0 errors" "$dafny_bin" verify --cores "$dafny_cores" "$case_dir/generated_attempt_01.dfy"
  run_ok "005-combined" "Dafny program verifier finished with 26 verified, 0 errors" "$dafny_bin" verify --cores "$dafny_cores" --verify-included-files "$case_dir/comparison_harness.dfy"
}

run_archive_771() {
  local case_dir="$root/archive/id771_segmented_weighted_sum"
  local reference="$benchmark_dir/DafnyBench/dataset/ground_truth/veri-sparse_tmp_tmp15fywna6_dafny_spmv.dfy"
  run_ok "archive-771-reference" "Dafny program verifier finished with 4 verified, 0 errors" "$dafny_bin" verify --cores "$dafny_cores" "$reference"
  run_ok "archive-771-generated" "Dafny program verifier finished with 3 verified, 0 errors" "$dafny_bin" verify --cores "$dafny_cores" "$case_dir/generated_attempt_01.dfy"
  run_ok "archive-771-combined" "Dafny program verifier finished with 14 verified, 0 errors" "$dafny_bin" verify --cores "$dafny_cores" --verify-included-files "$case_dir/comparison_harness.dfy"
}

echo "== provenance checksums"
(cd "$root" && sha256sum -c provenance/SHA256SUMS)

echo "== heuristic forbidden-feature scan"
forbidden='assume|\{:[[:space:]]*(verify[[:space:]]+false|axiom|extern)|decreases[[:space:]]+\*|(^|[^[:alnum:]_])print([[:space:](;]|$)'
if grep -En "$forbidden" \
  "$root/case_001_substring_occurrence/generated_attempt_01.dfy" \
  "$root/case_002_local_transition_trace/generated_attempt_01.dfy" \
  "$root/case_003_repeated_value_pair/generated_attempt_01.dfy" \
  "$root/case_004_four_kind_arrangement/generated_attempt_01.dfy" \
  "$root/case_005_tree_window/generated_attempt_01.dfy"; then
  echo "error: forbidden construct found" >&2
  exit 1
fi
echo "no matches"

if [[ "$selected" == "all" ]]; then
  run_001
  run_002
  run_003
  run_004
  run_005
else
  case "$selected" in
    001) run_001 ;;
    002) run_002 ;;
    003) run_003 ;;
    004) run_004 ;;
    005) run_005 ;;
    archive-771) run_archive_771 ;;
  esac
fi

if [[ $include_archive -eq 1 && "$selected" != "archive-771" ]]; then
  run_archive_771
fi

echo "Reproduction checks completed. Logs: $logs_dir"

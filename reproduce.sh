#!/usr/bin/env bash
set -euo pipefail

root="$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
selected="all"
skip_runtime=0
include_archive=0

usage() {
  echo "Usage: ./reproduce.sh [--case 001..015|archive-771|all] [--skip-runtime] [--include-archive]"
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
  001|002|003|004|005|006|007|008|009|010|011|012|013|014|015|archive-771|all) ;;
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
      ("$selected" == "all" || "$selected" == "001" ||
       "$selected" == "003" || "$selected" == "009" ||
       "$selected" == "010" || "$selected" == "012") ]]; then
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
  if grep -Fq "Dafny program verifier finished" "$log"; then
    grep -F "Dafny program verifier finished" "$log" | tail -n 1
  else
    grep -F "$expected" "$log" | tail -n 1
  fi
}

require_log_contains() {
  local label="$1"
  local expected="$2"
  local log="$logs_dir/$label.log"

  if ! grep -Fq -- "$expected" "$log"; then
    echo "recorded diagnostic for $label was not found:" >&2
    echo "  $expected" >&2
    echo "full output:" >&2
    sed -n '1,240p' "$log" >&2
    exit 1
  fi
}

require_log_count() {
  local label="$1"
  local expected_count="$2"
  local expected="$3"
  local log="$logs_dir/$label.log"
  local actual_count

  actual_count="$(grep -Fc -- "$expected" "$log" || true)"
  if [[ "$actual_count" -ne "$expected_count" ]]; then
    echo "recorded diagnostic count for $label did not reproduce:" >&2
    echo "  expected $expected_count occurrence(s), found $actual_count" >&2
    echo "  diagnostic: $expected" >&2
    echo "full output:" >&2
    sed -n '1,240p' "$log" >&2
    exit 1
  fi
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

stage_repair_runtime_case() {
  local id="$1"
  local case_dir="$2"
  local round="$3"
  local reference_rel="${4:-}"
  local stage="$runtime_dir/$id-repair"
  local staged_repair="$stage/$case_dir/repair"

  mkdir -p "$staged_repair/$round"
  cp "$root/$case_dir/repair/comparison_harness.dfy" "$staged_repair/"
  cp "$root/$case_dir/repair/$round/output_program.dfy" \
    "$staged_repair/$round/"
  if [[ -n "$reference_rel" ]]; then
    local staged_reference="$stage/third_party/DafnyBench/$reference_rel"
    mkdir -p "$(dirname "$staged_reference")"
    cp "$benchmark_dir/$reference_rel" "$staged_reference"
  fi
  echo "$staged_repair/comparison_harness.dfy"
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

run_runtime_012() {
  if [[ $skip_runtime -eq 1 ]]; then
    return 0
  fi
  local reference_rel="DafnyBench/dataset/ground_truth/Program-Verification-Dataset_tmp_tmpgbdrlnu__Dafny_from dafny main repo_dafny2_MajorityVote.dfy"
  local staged
  staged="$(stage_runtime_case 012 case_012_majority_candidate "$reference_rel")"
  run_ok "012-runtime" "Dafny program verifier finished with 5 verified, 0 errors" \
    "$dafny_bin" run --cores "$dafny_cores" "$staged" -t:py
  grep -Fq 'input:     [0, 1, 2]' "$logs_dir/012-runtime.log"
  grep -Fq 'generated: 0' "$logs_dir/012-runtime.log"
  grep -Fq 'reference: 2' "$logs_dir/012-runtime.log"
}

run_repair_runtime_009() {
  if [[ $skip_runtime -eq 1 ]]; then
    return 0
  fi
  local reference_rel="DafnyBench/dataset/ground_truth/Program-Verification-Dataset_tmp_tmpgbdrlnu__Dafny_algorithms and leetcode_heap2.dfy"
  local staged
  staged="$(stage_repair_runtime_case 009 case_009_local_array_repair round_02 "$reference_rel")"
  run_ok "009-repair-runtime" "Dafny program verifier finished with 1 verified, 0 errors" \
    "$dafny_bin" run --cores "$dafny_cores" "$staged" -t:py
  grep -Fq 'initial contents:       [7]' "$logs_dir/009-repair-runtime.log"
  grep -Fq 'reference contents:     [7]' "$logs_dir/009-repair-runtime.log"
  grep -Fq 'repaired contents:      [0]' "$logs_dir/009-repair-runtime.log"
  grep -Fq 'reference next:         -1' "$logs_dir/009-repair-runtime.log"
  grep -Fq 'repaired next:          -1' "$logs_dir/009-repair-runtime.log"
  grep -Fq 'reference alias kept:   true' "$logs_dir/009-repair-runtime.log"
  grep -Fq 'repaired alias kept:    true' "$logs_dir/009-repair-runtime.log"
}

run_repair_runtime_010() {
  if [[ $skip_runtime -eq 1 ]]; then
    return 0
  fi
  local staged
  staged="$(stage_repair_runtime_case 010 case_010_in_place_chain_reversal round_01)"
  run_ok "010-repair-runtime" "Dafny program verifier finished with 15 verified, 0 errors" \
    "$dafny_bin" run --cores "$dafny_cores" --verify-included-files "$staged" -t:py
  grep -Fq 'input values: [1, 2]' "$logs_dir/010-repair-runtime.log"
  grep -Fq 'abstract returned sequences agree: [2, 1]' "$logs_dir/010-repair-runtime.log"
  grep -Fq 'reference returns old tail: true' "$logs_dir/010-repair-runtime.log"
  grep -Fq 'repaired returns old head: true' "$logs_dir/010-repair-runtime.log"
  grep -Fq 'reference returned successor is old head: true' "$logs_dir/010-repair-runtime.log"
  grep -Fq 'repaired returned successor is old tail: true' "$logs_dir/010-repair-runtime.log"
  grep -Fq 'reference old-head value / old-tail value: 1 / 2' "$logs_dir/010-repair-runtime.log"
  grep -Fq 'repaired old-head value / old-tail value: 2 / 1' "$logs_dir/010-repair-runtime.log"
  grep -Fq 'reference old-head successor is null: true' "$logs_dir/010-repair-runtime.log"
  grep -Fq 'repaired old-head successor is old tail: true' "$logs_dir/010-repair-runtime.log"
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
  run_ok "002-repair-round-01" "Dafny program verifier finished with 4 verified, 0 errors" "$dafny_bin" verify --cores "$dafny_cores" "$case_dir/repair/round_01/output_program.dfy"
  run_ok "002-repair-comparison" "Dafny program verifier finished with 12 verified, 0 errors" "$dafny_bin" verify --cores "$dafny_cores" --verify-included-files "$case_dir/repair/comparison_harness.dfy"
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

run_006() {
  local case_dir="$root/case_006_entry_selection"
  local reference="$benchmark_dir/DafnyBench/dataset/ground_truth/CS5232_Project_tmp_tmpai_cfrng_LFUSimple.dfy"
  run_ok "006-reference" "Dafny program verifier finished with 8 verified, 0 errors" "$dafny_bin" verify --cores "$dafny_cores" "$reference"
  run_ok "006-generated" "Dafny program verifier finished with 3 verified, 0 errors" "$dafny_bin" verify --cores "$dafny_cores" "$case_dir/generated_attempt_01.dfy"
  run_ok "006-combined" "Dafny program verifier finished with 15 verified, 0 errors" "$dafny_bin" verify --cores "$dafny_cores" --verify-included-files "$case_dir/comparison_harness.dfy"
}

run_007() {
  local case_dir="$root/case_007_ordered_structure_extension"
  local reference="$benchmark_dir/DafnyBench/dataset/ground_truth/Dafny-Practice_tmp_tmphnmt4ovh_BST.dfy"
  run_ok "007-reference" "Dafny program verifier finished with 14 verified, 0 errors" "$dafny_bin" verify --cores "$dafny_cores" "$reference"
  run_ok "007-generated" "Dafny program verifier finished with 11 verified, 0 errors" "$dafny_bin" verify --cores "$dafny_cores" "$case_dir/generated_attempt_01.dfy"
  run_ok "007-combined" "Dafny program verifier finished with 38 verified, 0 errors" "$dafny_bin" verify --cores "$dafny_cores" --verify-included-files "$case_dir/comparison_harness.dfy"
}

run_008() {
  local case_dir="$root/case_008_multiplicity_expansion"
  local reference="$benchmark_dir/DafnyBench/dataset/ground_truth/DafnyPrograms_tmp_tmp74_f9k_c_map-multiset-implementation.dfy"
  run_ok "008-reference" "Dafny program verifier finished with 27 verified, 0 errors" "$dafny_bin" verify --cores "$dafny_cores" "$reference"
  run_ok "008-generated" "Dafny program verifier finished with 4 verified, 0 errors" "$dafny_bin" verify --cores "$dafny_cores" "$case_dir/generated_attempt_01.dfy"
  run_ok "008-combined" "Dafny program verifier finished with 37 verified, 0 errors" "$dafny_bin" verify --cores "$dafny_cores" --verify-included-files "$case_dir/comparison_harness.dfy"
}

run_009() {
  local case_dir="$root/case_009_local_array_repair"
  local reference="$benchmark_dir/DafnyBench/dataset/ground_truth/Program-Verification-Dataset_tmp_tmpgbdrlnu__Dafny_algorithms and leetcode_heap2.dfy"
  run_ok "009-reference" "Dafny program verifier finished with 6 verified, 0 errors" "$dafny_bin" verify --cores "$dafny_cores" "$reference"
  run_expected_fail "009-generated" "Dafny program verifier finished with 5 verified, 1 error" "$dafny_bin" verify --cores "$dafny_cores" "$case_dir/generated_attempt_01.dfy"
  require_log_contains "009-generated" "generated_attempt_01.dfy(51,15): Error: assignment might update an array element not in the enclosing context's modifies clause"
  run_expected_fail "009-repair-round-01" "Dafny program verifier finished with 5 verified, 1 error" "$dafny_bin" verify --cores "$dafny_cores" "$case_dir/repair/round_01/output_program.dfy"
  require_log_contains "009-repair-round-01" "output_program.dfy(78,11): Error: assertion might not hold"
  run_ok "009-repair-round-02" "Dafny program verifier finished with 6 verified, 0 errors" "$dafny_bin" verify --cores "$dafny_cores" "$case_dir/repair/round_02/output_program.dfy"
  run_ok "009-repair-comparison" "Dafny program verifier finished with 13 verified, 0 errors" "$dafny_bin" verify --cores "$dafny_cores" --verify-included-files "$case_dir/repair/comparison_harness.dfy"
  run_repair_runtime_009
}

run_010() {
  local case_dir="$root/case_010_in_place_chain_reversal"
  local reference="$benchmark_dir/DafnyBench/dataset/ground_truth/Program-Verification-Dataset_tmp_tmpgbdrlnu__Dafny_from dafny main repo_dafny1_ListContents.dfy"
  run_ok "010-reference" "Dafny program verifier finished with 10 verified, 0 errors" "$dafny_bin" verify --cores "$dafny_cores" "$reference"
  run_expected_fail "010-generated" "17 resolution/type errors detected in generated_attempt_01.dfy" "$dafny_bin" verify --cores "$dafny_cores" "$case_dir/generated_attempt_01.dfy"
  require_log_count "010-generated" 17 "Error: type seq<T> does not have a member Length"
  run_ok "010-repair-round-01" "Dafny program verifier finished with 8 verified, 0 errors" "$dafny_bin" verify --cores "$dafny_cores" "$case_dir/repair/round_01/output_program.dfy"
  run_ok "010-repair-comparison" "Dafny program verifier finished with 15 verified, 0 errors" "$dafny_bin" verify --cores "$dafny_cores" --verify-included-files "$case_dir/repair/comparison_harness.dfy"
  run_repair_runtime_010
}

run_011() {
  local case_dir="$root/case_011_queue_extension"
  local reference="$benchmark_dir/DafnyBench/dataset/ground_truth/Program-Verification-Dataset_tmp_tmpgbdrlnu__Dafny_from dafny main repo_dafny1_Queue.dfy"
  run_ok "011-reference" "Dafny program verifier finished with 18 verified, 0 errors" "$dafny_bin" verify --cores "$dafny_cores" "$reference"
  run_ok "011-generated" "Dafny program verifier finished with 6 verified, 0 errors" "$dafny_bin" verify --cores "$dafny_cores" "$case_dir/generated_attempt_01.dfy"
  run_ok "011-combined" "Dafny program verifier finished with 35 verified, 0 errors" "$dafny_bin" verify --cores "$dafny_cores" --verify-included-files "$case_dir/comparison_harness.dfy"
}

run_012() {
  local case_dir="$root/case_012_majority_candidate"
  local reference="$benchmark_dir/DafnyBench/dataset/ground_truth/Program-Verification-Dataset_tmp_tmpgbdrlnu__Dafny_from dafny main repo_dafny2_MajorityVote.dfy"
  run_ok "012-reference" "Dafny program verifier finished with 16 verified, 0 errors" "$dafny_bin" verify --cores "$dafny_cores" "$reference"
  run_ok "012-generated" "Dafny program verifier finished with 7 verified, 0 errors" "$dafny_bin" verify --cores "$dafny_cores" "$case_dir/generated_attempt_01.dfy"
  run_ok "012-combined" "Dafny program verifier finished with 28 verified, 0 errors" "$dafny_bin" verify --cores "$dafny_cores" --verify-included-files "$case_dir/comparison_harness.dfy"
  run_runtime_012
}

run_013() {
  local case_dir="$root/case_013_undo_log_recovery"
  local reference="$benchmark_dir/DafnyBench/dataset/ground_truth/Program-Verification-Dataset_tmp_tmpgbdrlnu__Dafny_lightening_verifier.dfy"
  run_ok "013-reference" "Dafny program verifier finished with 37 verified, 0 errors" "$dafny_bin" verify --cores "$dafny_cores" "$reference"
  run_expected_fail "013-generated" "Dafny program verifier finished with 6 verified, 2 errors" "$dafny_bin" verify --cores "$dafny_cores" "$case_dir/generated_attempt_01.dfy"
  require_log_contains "013-generated" "generated_attempt_01.dfy(226,12): Error: assignment might update an array element not in the enclosing context's modifies clause"
  require_log_contains "013-generated" "generated_attempt_01.dfy(307,11): Error: assignment might update an array element not in the enclosing context's modifies clause"
  run_ok "013-repair-round-01" "Dafny program verifier finished with 7 verified, 0 errors" "$dafny_bin" verify --cores "$dafny_cores" "$case_dir/repair/round_01/output_program.dfy"
  run_ok "013-repair-comparison" "Dafny program verifier finished with 50 verified, 0 errors" "$dafny_bin" verify --cores "$dafny_cores" --warn-deprecation false --verify-included-files "$case_dir/repair/comparison_harness.dfy"
}

run_014() {
  local case_dir="$root/case_014_distinct_window"
  local reference="$benchmark_dir/DafnyBench/dataset/ground_truth/dafleet_tmp_tmpa2e4kb9v_0001-0050_0003-longest-substring-without-repeating-characters.dfy"
  run_ok "014-reference" "Dafny program verifier finished with 4 verified, 0 errors" "$dafny_bin" verify --cores "$dafny_cores" "$reference"
  run_ok "014-generated" "Dafny program verifier finished with 4 verified, 0 errors" "$dafny_bin" verify --cores "$dafny_cores" "$case_dir/generated_attempt_01.dfy"
  run_ok "014-combined" "Dafny program verifier finished with 13 verified, 0 errors" "$dafny_bin" verify --cores "$dafny_cores" --verify-included-files "$case_dir/comparison_harness.dfy"
}

run_015() {
  local case_dir="$root/case_015_parent_propagation"
  local reference="$benchmark_dir/DafnyBench/dataset/ground_truth/dafny-language-server_tmp_tmpkir0kenl_Test_vacid0_Composite.dfy"
  run_ok "015-reference" "Dafny program verifier finished with 13 verified, 0 errors" "$dafny_bin" verify --cores "$dafny_cores" "$reference"
  run_ok "015-generated" "Dafny program verifier finished with 4 verified, 0 errors" "$dafny_bin" verify --cores "$dafny_cores" "$case_dir/generated_attempt_01.dfy"
  run_ok "015-combined" "Dafny program verifier finished with 34 verified, 0 errors" "$dafny_bin" verify --cores "$dafny_cores" --verify-included-files "$case_dir/comparison_harness.dfy"
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
(cd "$root" && sha256sum -c provenance/extension_freeze_SHA256SUMS)
(cd "$root" && sha256sum -c provenance/extension_results_SHA256SUMS)
(cd "$root" && sha256sum -c provenance/repair_SHA256SUMS)

echo "== heuristic forbidden-feature scan"
forbidden='assume|\{:[[:space:]]*(verify[[:space:]]+false|axiom|extern)|decreases[[:space:]]+\*|(^|[^[:alnum:]_])print([[:space:](;]|$)'
forbidden_scan_files=(
  "$root"/case_???_*/generated_attempt_01.dfy
  "$root"/case_002_local_transition_trace/repair/round_*/output_program.dfy
  "$root"/case_009_local_array_repair/repair/round_*/output_program.dfy
  "$root"/case_010_in_place_chain_reversal/repair/round_*/output_program.dfy
  "$root"/case_013_undo_log_recovery/repair/round_*/output_program.dfy
)
if grep -En "$forbidden" "${forbidden_scan_files[@]}"; then
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
  run_006
  run_007
  run_008
  run_009
  run_010
  run_011
  run_012
  run_013
  run_014
  run_015
else
  case "$selected" in
    001) run_001 ;;
    002) run_002 ;;
    003) run_003 ;;
    004) run_004 ;;
    005) run_005 ;;
    006) run_006 ;;
    007) run_007 ;;
    008) run_008 ;;
    009) run_009 ;;
    010) run_010 ;;
    011) run_011 ;;
    012) run_012 ;;
    013) run_013 ;;
    014) run_014 ;;
    015) run_015 ;;
    archive-771) run_archive_771 ;;
  esac
fi

if [[ $include_archive -eq 1 && "$selected" != "archive-771" ]]; then
  run_archive_771
fi

echo "Reproduction checks completed. Logs: $logs_dir"

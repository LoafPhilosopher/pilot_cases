#!/usr/bin/env bash
set -euo pipefail

root="$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
dafny_version="4.3.0"
dafny_archive_name="dafny-4.3.0-x64-ubuntu-20.04.zip"
dafny_archive_sha256="6920fc19db0d5d4d07e8ef2c2386511eb97a02175b38a994774a2b830ad0e11e"
dafny_url="https://github.com/dafny-lang/dafny/releases/download/v4.3.0/$dafny_archive_name"
benchmark_commit="0cd28feed9cd0179b07fdb9d002f8c39063658e4"
benchmark_url="https://github.com/sun-wendy/DafnyBench.git"

die() {
  echo "error: $*" >&2
  exit 1
}

need_command() {
  command -v "$1" >/dev/null 2>&1 || die "required command not found: $1"
}

need_command git
need_command sha256sum

if [[ -n "${DAFNY_BIN:-}" ]]; then
  [[ "$DAFNY_BIN" == /* ]] || die "DAFNY_BIN must be an absolute path"
  dafny_bin="$DAFNY_BIN"
  [[ -x "$dafny_bin" ]] || die "DAFNY_BIN is not executable: $dafny_bin"
else
  [[ "$(uname -s)" == "Linux" && "$(uname -m)" == "x86_64" ]] ||
    die "automatic Dafny installation supports Linux x86_64; set DAFNY_BIN for another platform"
  need_command curl
  need_command mktemp
  need_command unzip

  tools_dir="$root/.tools"
  archive="$tools_dir/$dafny_archive_name"
  install_dir="$tools_dir/dafny-$dafny_version"
  dafny_bin="$install_dir/dafny/dafny"
  mkdir -p "$tools_dir"

  if [[ ! -f "$archive" ]] ||
     ! printf '%s  %s\n' "$dafny_archive_sha256" "$archive" | sha256sum -c - >/dev/null 2>&1; then
    partial="$(mktemp "$tools_dir/.dafny-download.XXXXXX")"
    trap 'rm -f -- "$partial"' EXIT
    echo "Downloading Dafny $dafny_version..."
    curl --fail --location --retry 3 --output "$partial" "$dafny_url"
    printf '%s  %s\n' "$dafny_archive_sha256" "$partial" | sha256sum -c -
    mv -- "$partial" "$archive"
    trap - EXIT
  fi

  if [[ ! -x "$dafny_bin" ]]; then
    [[ ! -e "$install_dir" ]] ||
      die "incomplete Dafny installation at $install_dir; move it aside and retry"
    partial_install="$(mktemp -d "$tools_dir/.dafny-install.XXXXXX")"
    trap 'rm -rf -- "$partial_install"' EXIT
    unzip -q "$archive" -d "$partial_install"
    chmod u+x "$partial_install/dafny/dafny"
    mv -- "$partial_install" "$install_dir"
    trap - EXIT
  fi
fi

actual_dafny_version="$("$dafny_bin" --version)"
[[ "$actual_dafny_version" == "$dafny_version" ]] ||
  die "expected Dafny $dafny_version, found $actual_dafny_version at $dafny_bin"

is_git_checkout() {
  git -C "$1" rev-parse --is-inside-work-tree >/dev/null 2>&1
}

if [[ -n "${DAFNYBENCH_DIR:-}" ]]; then
  [[ "$DAFNYBENCH_DIR" == /* ]] ||
    die "DAFNYBENCH_DIR must be an absolute path"
  benchmark_dir="$(CDPATH= cd -- "$DAFNYBENCH_DIR" && pwd -P)"
  is_git_checkout "$benchmark_dir" ||
    die "DAFNYBENCH_DIR is not a Git checkout: $benchmark_dir"
  actual_commit="$(git -C "$benchmark_dir" rev-parse HEAD)"
  [[ "$actual_commit" == "$benchmark_commit" ]] ||
    die "DAFNYBENCH_DIR must be at $benchmark_commit, found $actual_commit"

  include_checkout="$root/third_party/DafnyBench"
  if [[ "$benchmark_dir" != "$include_checkout" ]]; then
    mkdir -p "$root/third_party"
    if [[ -L "$include_checkout" ]]; then
      [[ "$(CDPATH= cd -- "$include_checkout" && pwd -P)" == "$benchmark_dir" ]] ||
        die "$include_checkout points to a different checkout"
    elif [[ -e "$include_checkout" ]]; then
      die "$include_checkout already exists; remove it or omit DAFNYBENCH_DIR"
    else
      ln -s "$benchmark_dir" "$include_checkout"
    fi
  fi
else
  benchmark_dir="$root/third_party/DafnyBench"
  if [[ -L "$benchmark_dir" ]]; then
    is_git_checkout "$benchmark_dir" ||
      die "$benchmark_dir is a symlink but not a Git checkout"
    actual_commit="$(git -C "$benchmark_dir" rev-parse HEAD)"
    [[ "$actual_commit" == "$benchmark_commit" ]] ||
      die "symlinked DafnyBench checkout must remain at $benchmark_commit"
  elif ! is_git_checkout "$benchmark_dir"; then
    [[ ! -e "$benchmark_dir" ]] ||
      die "$benchmark_dir exists but is not a Git checkout"
    mkdir -p "$root/third_party"
    git init "$benchmark_dir"
    git -C "$benchmark_dir" remote add origin "$benchmark_url"

    git -C "$benchmark_dir" fetch --depth 1 origin "$benchmark_commit"
    git -C "$benchmark_dir" checkout --detach FETCH_HEAD
  else
    actual_commit="$(git -C "$benchmark_dir" rev-parse HEAD)"
    if [[ "$actual_commit" != "$benchmark_commit" ]]; then
      git -C "$benchmark_dir" fetch --depth 1 origin "$benchmark_commit"
      git -C "$benchmark_dir" checkout --detach FETCH_HEAD
    fi
  fi
fi

actual_commit="$(git -C "$benchmark_dir" rev-parse HEAD)"
[[ "$actual_commit" == "$benchmark_commit" ]] ||
  die "expected DafnyBench $benchmark_commit, found $actual_commit"
[[ -z "$(git -C "$benchmark_dir" status --porcelain --untracked-files=no)" ]] ||
  die "DafnyBench checkout has tracked modifications; use a clean checkout at $benchmark_commit"
[[ -f "$benchmark_dir/DafnyBench/dataset/ground_truth/dafny-rope_tmp_tmpl4v_njmy_Rope.dfy" ]] ||
  die "DafnyBench checkout does not have the expected dataset layout"

echo "Dafny:      $dafny_bin ($actual_dafny_version)"
echo "DafnyBench: $benchmark_dir ($actual_commit)"

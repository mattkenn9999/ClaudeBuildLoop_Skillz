#!/usr/bin/env bash
# Install the loop skills into Claude Code's skills directory.
#
# Default: symlink, so edits in this repo are live immediately.
# Pass --copy to copy instead, so changes only take effect when you re-run this.
#
# Usage:
#   ./install.sh           # symlink (default)
#   ./install.sh --copy    # copy

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_DIR="${HOME}/.claude/skills"
MODE="symlink"
[ "${1:-}" = "--copy" ] && MODE="copy"

SKILLS=(spec init build review loop)

mkdir -p "${SKILLS_DIR}"

for skill in "${SKILLS[@]}"; do
  src="${REPO_DIR}/${skill}"
  dest="${SKILLS_DIR}/${skill}"

  if [ -e "${dest}" ] || [ -L "${dest}" ]; then
    echo "removing existing ${dest}"
    rm -rf "${dest}"
  fi

  if [ "${MODE}" = "symlink" ]; then
    ln -s "${src}" "${dest}"
    echo "linked  ${skill}  ->  ${src}"
  else
    cp -r "${src}" "${dest}"
    echo "copied  ${skill}"
  fi
done

echo "done (${MODE}). Restart Claude Code if it was already running."

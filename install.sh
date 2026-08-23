#!/usr/bin/env bash
set -euo pipefail

repo="Ericwong5021/chatgpt-pro-planning-skill"
ref="${CHATGPT_PRO_PLANNING_REF:-main}"
skill_name="chatgpt-pro-planning"
codex_root="${CODEX_HOME:-${HOME}/.codex}"
skills_dir="${codex_root}/skills"
destination="${skills_dir}/${skill_name}"

if ! command -v curl >/dev/null 2>&1; then
  echo "curl is required." >&2
  exit 1
fi

if ! command -v tar >/dev/null 2>&1; then
  echo "tar is required." >&2
  exit 1
fi

if [[ -e "${destination}" ]]; then
  echo "Skill already exists at ${destination}. Move or remove it before installing." >&2
  exit 1
fi

temp_root="$(mktemp -d)"
staging="${skills_dir}/.${skill_name}.install.$$"

cleanup() {
  rm -rf "${temp_root}"
  if [[ -e "${staging}" ]]; then
    rm -rf "${staging}"
  fi
}

trap cleanup EXIT INT TERM

mkdir -p "${temp_root}/source" "${skills_dir}"
curl -fsSL "https://github.com/${repo}/archive/${ref}.tar.gz" -o "${temp_root}/archive.tar.gz"
tar -xzf "${temp_root}/archive.tar.gz" -C "${temp_root}/source"

skill_file="$(find "${temp_root}/source" -type f -path '*/skill/SKILL.md' -print -quit)"

if [[ -z "${skill_file}" ]]; then
  echo "The downloaded archive does not contain skill/SKILL.md." >&2
  exit 1
fi

source_dir="${skill_file%/SKILL.md}"
cp -R "${source_dir}" "${staging}"

if [[ ! -f "${staging}/SKILL.md" ]]; then
  echo "Skill validation failed before installation." >&2
  exit 1
fi

mv "${staging}" "${destination}"
echo "Installed ${skill_name} to ${destination}"
echo "The skill will be available on your next Codex turn."

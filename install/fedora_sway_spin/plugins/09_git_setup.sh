#!/usr/bin/env bash
set -euo pipefail

GH_USER=$(gh api user --jq .login 2>/dev/null || true)

if [[ -z "$GH_USER" ]]; then
  gh auth login
  GH_USER=$(gh api user --jq .login)
fi

GH_EMAIL=$(gh api user --jq '.email // empty' 2>/dev/null || true)
if [[ -z "$GH_EMAIL" ]]; then
  GH_EMAIL="${GH_USER}@users.noreply.github.com"
fi

git config --global user.name "$GH_USER"
git config --global user.email "$GH_EMAIL"
git config --global core.editor "nvim"
git config --global gpg.format ssh
git config --global commit.gpgsign true

SSH_KEY="$HOME/.ssh/github_signing"

if [[ ! -f "$SSH_KEY" ]]; then
  mkdir -p "$HOME/.ssh"
  chmod 700 "$HOME/.ssh"
  ssh-keygen -t ed25519 -C "$GH_EMAIL" -f "$SSH_KEY" -N ""
fi

git config --global user.signingkey "${SSH_KEY}.pub"

eval "$(ssh-agent -s)" > /dev/null
ssh-add "$SSH_KEY"

KEY_TITLE="$(hostname)-$(date +%Y%m%d)"
PUB_KEY="$(cat "${SSH_KEY}.pub")"

add_key_if_missing() {
  local type="$1"
  local existing
  existing=$(gh api user/ssh_signing_keys 2>/dev/null | jq -r '.[].key' || true)
  if [[ "$type" == "authentication" ]]; then
    existing=$(gh api user/keys --jq '.[].key' 2>/dev/null || true)
  fi

  if echo "$existing" | grep -qF "$(awk '{print $2}' <<< "$PUB_KEY")"; then
    echo "SSH $type key already registered on GitHub."
  else
    gh ssh-key add "${SSH_KEY}.pub" --title "$KEY_TITLE" --type "$type"
    echo "SSH $type key added to GitHub."
  fi
}

gh auth refresh -h github.com -s admin:ssh_signing_key
add_key_if_missing signing

#!/usr/bin/env bash

DOTFILES_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
source "$DOTFILES_ROOT/script/utils.sh"

# ── pyenv: install latest Python 3 ──────────────────────────────────────────

if ! command -v pyenv >/dev/null; then
  warn "pyenv not found, skipping Python installation"
  exit 0
fi

info "fetching latest Python 3 version..."
LATEST_PY3=$(pyenv install --list | grep -E '^\s+3\.[0-9]+\.[0-9]+$' | tail -1 | tr -d ' ')
info "latest Python 3: ${LATEST_PY3}"

if pyenv versions --bare | grep -qx "${LATEST_PY3}"; then
  info "Python ${LATEST_PY3} already installed, skipping"
else
  info "installing Python ${LATEST_PY3} via pyenv..."
  pyenv install "${LATEST_PY3}"
fi

info "setting Python ${LATEST_PY3} as global default..."
pyenv global "${LATEST_PY3}"
pyenv rehash

# ── pip plugins ──────────────────────────────────────────────────────────────

plugins=(
    virtualenv
    autopep8
    flake8
    pytz
    requests
    thefuck
)

if ! command -v pip3 >/dev/null; then
  warn "pip3 not found, skipping plugin installation"
  exit 0
fi

info "upgrading pip..."
pip3 install --upgrade pip

info "installing pip plugins..."
pip3 install "${plugins[@]}"

#!/usr/bin/env bash

PYTHON_BIN="$HOME/.pyenv/versions/3.11.8/bin/python"

current_version=$($PYTHON_BIN --version)
expected_version='Python 3.11.8'

if [[ "$current_version" != "$expected_version" ]]; then
    echo "❌ Incorrect Python version:"
    echo "- Expected: $expected_version"
    echo "- Got: $current_version"
    exit 1
fi

[[ -d 'data' ]] || mkdir data

VENV_NAME='.invoice2data-venv'

rm --recursive --force "$VENV_NAME"
$PYTHON_BIN -m venv "$VENV_NAME"
source "$VENV_NAME/bin/activate"

# pip install --upgrade pip setuptools wheel
pip install invoice2data openpyxl dateparser

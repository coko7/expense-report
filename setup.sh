#!/usr/bin/env bash

[[ ! -d 'data' ]] && mkdir data

python -m venv '.invoice2data-venv' \
    && source .invoice2data-venv/bin/activate \
    && pip install --upgrade setuptools \
    && pip install invoice2data \
    && pip install openpyxl

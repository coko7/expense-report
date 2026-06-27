#!/usr/bin/env bash

fd --type f --glob 'sigxp*' ~/Downloads --print0 \
    | xargs --null -I {} mv {} ./data/invoices/mine

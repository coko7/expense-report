#!/usr/bin/env bash

[[ ! -f ".invoice2data-venv/bin/activate" ]] && echo "missing python venv" && exit 1

source .invoice2data-venv/bin/activate

TEMPLATES_DIR='./templates/'
INVOICES_DIR="data/invoices"

OUTPUT_FILE='data/parsed_data.json'
TMP_OUTPUT_FILE="data/tmp_invoice_data.json"

# EMP_NUM should be put in .env
source .env

# fd -e pdf . ./invoices/ | xargs invoice2data \
#     --template-folder templates \
#     --output-format json \
#     --output-name "$output_file"

json_invoices=()
for invoice_file in $(fd . -e pdf "$INVOICES_DIR"); do
    echo "Parsing: $invoice_file"

    if [[ "$invoice_file" == *"mine"* ]]; then
        cost_num=$EMP_NUM
    elif [[ "$invoice_file" == *"company"* ]]; then
        cost_num=0
    else
        cost_num=-1
    fi

    invoice2data "$invoice_file" \
        --template-folder "$TEMPLATES_DIR" --exclude-built-in-templates \
        --output-format json --output-name "$TMP_OUTPUT_FILE"

    json=$(jq -c '.[]' "$TMP_OUTPUT_FILE" \
        | jq '. + {file_path: "'"$invoice_file"'"}' \
        | jq '. + {cost_num: '"$cost_num"'}')
    json_invoices+=("$json")
done

rm "$TMP_OUTPUT_FILE"
jq -s '.' <<< "${json_invoices[*]}" > "$OUTPUT_FILE"

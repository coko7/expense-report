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

GREEN='\033[32m'
RED='\033[31m'
BOLD='\033[1m'
RESET='\033[0m'

json_invoices=()
total=0
for invoice_file in $(fd . -e pdf "$INVOICES_DIR"); do
  if [[ "$invoice_file" == *"mine"* ]]; then
    cost_num=$EMP_NUM
  elif [[ "$invoice_file" == *"company"* ]]; then
    cost_num=0
  else
    cost_num=-1
  fi

  invoice2data "$invoice_file" \
    --input-reader pdftotext \
    --template-folder "$TEMPLATES_DIR" --exclude-built-in-templates \
    --output-format json --output-name "$TMP_OUTPUT_FILE" \
    >/dev/null 2>&1

  json=$(jq -c '.[]' "$TMP_OUTPUT_FILE" 2>/dev/null |
    jq '. + {file_path: "'"$invoice_file"'"}' |
    jq '. + {cost_num: '"$cost_num"'}')

  if [[ -n "$json" ]]; then
    amount=$(echo "$json" | jq -r '.amount')
    currency=$(echo "$json" | jq -r '.currency')

    if [[ "$currency" == "EUR" ]]; then
      amount_eur=$amount
      echo -e "${GREEN}✓${RESET} $invoice_file -> ${GREEN}$amount EUR${RESET}"
    else
      amount_eur=$(qalc -t "$amount $currency to EUR" | grep -oP '[\d.]+' | xargs printf "%.2f")
      echo -e "${GREEN}✓${RESET} $invoice_file -> ${GREEN}$amount $currency (~$amount_eur EUR)${RESET}"
    fi
    total=$(echo "$total + $amount_eur" | bc)
    json_invoices+=("$json")
  else
    echo -e "${RED}✗${RESET} $invoice_file"
  fi
done

echo -e "\nTotal: ${BOLD}$total €${RESET}"

rm "$TMP_OUTPUT_FILE"
jq -s '.' <<<"${json_invoices[*]}" >"$OUTPUT_FILE"

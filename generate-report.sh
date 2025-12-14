#!/usr/bin/env bash

# xlsx_file='expenses.xlsx'
json_file='data/parsed_data.json'
temp_csv='data/temp.csv'

# Get EMP_NAME and EMP_NUM
source .env

employee_name=$(gum input --prompt="Employee Name> " --value="$EMP_NAME")
employee_number=$(gum input --prompt="Employee Number> " --value="$EMP_NUM")
expenses_date=$(gum input --prompt="Expense Report Date> " --value="$(date +'%d %B %Y')")
[[ -z "$expenses_date" ]] && echo "requires expenses date" && exit 1

iso_date=$(date -d "$expenses_date" +'%Y-%m-%d')
month_date=$(date -d "$iso_date" +'%b%Y')

jq -r '
    # Step 1: Pivot currency amounts
    map(
        . + {
            amount_eur: if .currency == "EUR" then .amount else (.amount / 10) end,
            amount_sek: if .currency == "SEK" then .amount else (.amount * 10) end,
            vat_eur: if .currency == "EUR" then (.vat_amount // 0) else ((.vat_amount // 0) / 10) end,
            vat_sek: if .currency == "SEK" then (.vat_amount // 0) else ((.vat_amount // 0) * 10)  end
        }
    )
    |
    # Step 2: Convert to CSV
    .[] | [
        .description // empty,
        .cost_num // empty,
        (.amount_eur // empty | tonumber),
        (.vat_eur // empty | tonumber),
        (.amount_sek // empty | tonumber),
        (.vat_sek // empty | tonumber)
    ] | @csv
' "$json_file" > "$temp_csv"

EXPENSES_TEMPLATE="expenses_template.xlsx"
expense_file="data/expense_${employee_name}_${month_date}.xlsx"

cp "$EXPENSES_TEMPLATE" "$expense_file"
echo "✓ Created empty expenses report: $expense_file"

python create_xlsx.py "$expense_file" "$temp_csv" "$employee_name" "$employee_number" "$iso_date"
rm "$temp_csv"

# ssconvert --merge-to "$xlsx_file" temp.csv "$xlsx_file"

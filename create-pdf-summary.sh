#!/usr/bin/env bash

expenses_date="$1"
[[ -z "$expenses_date" ]] && { echo "date expected"; exit 1; }

employee_id="$2"
[[ -z "$employee_id" ]] && { echo "employee ID expected: foo1377"; exit 1; }

INVOICES_DIR="data/invoices"
TARGET_DIR="target/pdf-extracts"

pdf_count=$(fd . -e pdf "$INVOICES_DIR" | wc -l)
[[ "$pdf_count" -eq 0 ]] && { echo "no pdf found, exiting"; exit 1; }

if [[ ! -d "$TARGET_DIR" ]]; then
    echo "dir not found: $TARGET_DIR, creating..."
    command mkdir --verbose --parents "$TARGET_DIR"
fi

for pdf in $(fd . -e pdf "$INVOICES_DIR"); do
    echo "Parsing: $pdf"
    filename=$(basename "$pdf" .pdf)
    pdfseparate -f 1 -l 1 "$pdf" "$TARGET_DIR/$filename-%d-first.pdf"
done

final_pdf="all-invoices_${employee_id}_${expenses_date}.pdf"
pdfunite $TARGET_DIR/*-first.pdf "$TARGET_DIR/$final_pdf"

rm $TARGET_DIR/*-first.pdf

#!/usr/bin/env bash

expenses_date="$1"
[[ -z "$expenses_date" ]] && { echo "date expected"; exit 1; }

employee_id="$2"
[[ -z "$employee_id" ]] && { echo "employee ID expected: foo1377"; exit 1; }

page="${3:-first}"
[[ "$page" != "first" && "$page" != "last" ]] && { echo "page must be 'first' or 'last', got: $page"; exit 1; }

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
    if [[ "$page" == "first" ]]; then
        page_num=1
    else
        page_num=$(pdfinfo "$pdf" | awk '/^Pages:/ {print $2}')
    fi
    pdfseparate -f "$page_num" -l "$page_num" "$pdf" "$TARGET_DIR/$filename-%d-$page.pdf"
    [[ ! -f "$TARGET_DIR/$filename-$page_num-$page.pdf" ]] && { echo "✗ failed to extract page from: $pdf"; exit 1; }
done

final_pdf="all-invoices_${employee_id}_${expenses_date}.pdf"
pdfunite $TARGET_DIR/*-$page.pdf "$TARGET_DIR/$final_pdf"

rm $TARGET_DIR/*-$page.pdf

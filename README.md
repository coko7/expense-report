# 🧾 expense-report

Generate Excel reports from PDF invoices.

## Requirements

- python/pip (pyenv, 3.11.8)
- fd, jq, gum
- poppler-utils (pdftotext, pdfseparate, pdfunite, pdfinfo)
- invoice2data, dateparser, openpyxl (installed into the venv by `setup.sh`)

Requires a `.env` file with `EMP_NAME` and `EMP_NUM` variables.

## Usage

```console
$ ./setup.sh            # setup the python venv
$ ./invoice2json.sh     # use invoice2data to extract data from PDFs into data/parsed_data.json
$ ./generate-report.sh  # convert generated JSON into csv and insert it in the XLSX template
```

### Invoice folders

Put PDFs under `data/invoices/`:

- `mine/` → personal expense, reimbursed (cost_num = employee number)
- `company/` → direct company expense (cost_num = 0)
- anywhere else → cost_num = -1

### create-pdf-summary.sh

Merges one page from every invoice PDF into a single attachment PDF.

```console
$ ./create-pdf-summary.sh <date> <employee_id> [first|last]
```

- `date`, `employee_id` — used in the output filename `target/pdf-extracts/all-invoices_<employee_id>_<date>.pdf`
- `first|last` — which page to pull from each PDF (default `first`)

### hook-xp-files.sh

Moves files prefixed `sigxp` from `~/Downloads` into `data/invoices/mine/` — used when batch-downloading invoices from the employer's expense portal.

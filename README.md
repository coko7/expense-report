# 🧾 expense-report

Generate Excel reports from PDF invoices.

## Requirements

- python/pip
- fd, jq
- invoice2data
- gum

## Usage

```console
$ ./setup.sh            # setup the python venv
$ ./invoice2json.sh     # use invoice2data to extract data from PDFs
$ ./generate-report.sh  # convert generated JSON into csv and insert it in the XLSX template
```

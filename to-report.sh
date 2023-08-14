#!/bin/sh

cd /var/www/dharmatech.dev/data/usts-yield-curve.ps1

# mkdir -p ../reports/treasury-gov-tga-top

script -q -c 'pwsh -Command "./usts-yield-curve.ps1 -display_chart_url -save_iframe"' script-out

cat script-out |
    /home/dharmatech/go/bin/terminal-to-html -preview |
    sed 's/pre-wrap/pre/' |
    sed "s/terminal-to-html Preview/usts-yield-curve.ps1/" |
    sed 's/<body>/<body style="width: fit-content;">/' > ../reports/usts-yield-curve-table.html

# cp ../reports/treasury-gov-tga-top/latest.html ../reports/treasury-gov-tga-top/`date +%Y-%m-%d`.html

mv usts-yield-curve.html ../reports

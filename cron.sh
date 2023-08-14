#!/bin/sh

cd /var/www/dharmatech.dev/data/usts-yield-curve.ps1

tmux new-session -d -x 300 bash -c 'script -q -c ./to-report.sh'

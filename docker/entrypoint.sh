#!/usr/bin/env bash
set -euo pipefail

if [ -f /opt/conda/etc/profile.d/conda.sh ]; then
  source /opt/conda/etc/profile.d/conda.sh
else
  export PATH=/opt/conda/bin:$PATH
fi

conda activate base
conda activate dmsr

if [ "$#" -eq 0 ]; then
  exec /bin/bash
else
  exec "$@"
fi
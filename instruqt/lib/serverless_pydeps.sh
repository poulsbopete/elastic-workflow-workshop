#!/bin/bash
#
# Shared Python deps for Serverless Instruqt labs (elastic/es3-api-v2).
# Images often lack python3-venv / ensurepip; do not use `python3 -m venv .venv`.
#
# Prerequisites: WORKSHOP_DIR set to repo root; requirements.txt present.
# After sourcing: PYTHONPATH includes WORKSHOP_DIR and WORKSHOP_DIR/.pydeps
#
# Usage (from instruqt/startup-serverless.sh):
#   source "${INSTRUQT_DIR}/lib/serverless_pydeps.sh"
#
if [ -z "${WORKSHOP_DIR:-}" ]; then
    echo "ERROR: WORKSHOP_DIR must be set before sourcing serverless_pydeps.sh"
    exit 1
fi

PYDEPS="${WORKSHOP_DIR}/.pydeps"
mkdir -p "${PYDEPS}"

# Remove stale venv from older workshop versions (broken .venv/bin/python3 on these images)
if [ -d "${WORKSHOP_DIR}/.venv" ]; then
    echo "  Removing .venv (use .pydeps on Serverless lab images; venv/ensurepip is unreliable)..."
    rm -rf "${WORKSHOP_DIR}/.venv"
fi

echo "  Installing Python dependencies into ${PYDEPS} ..."
python3 -m pip install -q --upgrade pip 2>/dev/null || true
if ! python3 -m pip install -q -t "${PYDEPS}" -r "${WORKSHOP_DIR}/requirements.txt"; then
    echo "  ERROR: pip install -t failed. Ensure python3-pip is installed (setup-es3-api installs it)."
    exit 1
fi

export PYTHONPATH="${WORKSHOP_DIR}:${PYDEPS}${PYTHONPATH:+:${PYTHONPATH}}"

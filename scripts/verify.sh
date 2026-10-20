#!/usr/bin/env bash
# 로컬 전체 검증: 생성물 최신 여부 → 생성기 시험 → (KSX_TEST_PSQL이 있으면) E2E 시험
set -euo pipefail
cd "$(dirname "$0")/.."
export PYTHONPATH=tools/ksxgen${PYTHONPATH:+:$PYTHONPATH}
python -m ksxgen check --std standards --out ontologies
python tests/coverage/test_ksxgen.py
python tests/regression/test_e2e_minimal.py

#!/usr/bin/env bash
# 로컬 전체 검증: 생성물 최신 여부 → 생성기 시험 → S2 매핑 점검 → (KSX_TEST_PSQL이 있으면) E2E 시험
set -euo pipefail
cd "$(dirname "$0")/.."
export PYTHONPATH=tools/ksxgen${PYTHONPATH:+:$PYTHONPATH}
python -m ksxgen check --std standards --ext extensions/impix --out ontologies
python tests/coverage/test_ksxgen.py
PYTHONPATH=tools/automap python -m automap check --plan mapping/impix/s2_plan.yaml
python tests/coverage/test_automap.py
PYTHONPATH=tools/ksxload python -m ksxload check --plan mapping/impix/s3_plan.yaml
python tests/coverage/test_ksxload.py
python tests/regression/test_e2e_minimal.py

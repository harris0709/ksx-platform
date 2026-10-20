#!/usr/bin/env bash
# KS X 9101 제조 온톨로지 플랫폼 저장소 뼈대 생성 (구현 안내서 2.3 구조)
set -euo pipefail
R=${1:-ksx-platform}; ENT=${2:-acme}
mkdir -p "$R" && cd "$R"
d() { mkdir -p "$1"; [ -e "$1/.gitkeep" ] || touch "$1/.gitkeep"; }
for x in standards extensions/_template extensions/$ENT mapping/_template mapping/$ENT \
         tools/ksxgen tools/automap etl/dbt/models/stg etl/dbt/models/ksx etl/dbt/models/ext etl/dbt/macros etl/dbt/tests \
         ontologies/tbox ontologies/shapes ontologies/rules ontologies/mappings/rml ontologies/vocab \
         ontologies/catalog/nouns ontologies/catalog/tools ontologies/ddl ontologies/graph ontologies/report \
         services/mcp-ontology services/mcp-ledger services/mcp-kpi services/mcp-timeseries services/mcp-docs services/mcp-action \
         services/rule-runner services/pg-sync services/decision-engine/policies services/bod-gateway \
         dags infra/docker infra/helm infra/keycloak infra/opa infra/postgres tests/coverage tests/regression tests/e2e; do d "$x"; done
echo "created: $(pwd)"

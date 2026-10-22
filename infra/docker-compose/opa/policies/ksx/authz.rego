# =====================================================================
# KSX 기본 정책 — 사업장 경계 (구현안내서 3.1 절차 5, 8.2, 15장)
#
#   입력: { "claims": <Keycloak 액세스 토큰 클레임>, "graph": "<IRI>"(선택) }
#   출력:
#     data.ksx.authz.graphs          허용 Named Graph(정확 일치) — 도구가 FROM NAMED 로 강제
#     data.ksx.authz.graph_prefixes  허용 Named Graph 접두(추론 그래프 등 가변 ID)
#     data.ksx.authz.allow_graph     input.graph 접근 가능 여부
#     data.ksx.authz.ledger_session  PostgreSQL RLS 세션 변수(app.enterprise_id 등)
#
#   클레임이 불완전하면 아무 그래프도 허용하지 않는다(기본 거부).
# =====================================================================
package ksx.authz

import rego.v1

ready := true

base := data.ksx.config.graph_base

claims := object.get(input, "claims", {})

ent := object.get(claims, "enterpriseId", "")

site := object.get(claims, "siteId", "")

roles contains r if some r in object.get(claims, "roles", [])

# plants(다중) + plantId(단일) 모두 수용
plants contains p if {
	some p in object.get(claims, "plants", [])
	is_string(p)
	p != ""
}

plants contains p if {
	p := object.get(claims, "plantId", "")
	is_string(p)
	p != ""
}

valid_claims if {
	is_string(ent)
	ent != ""
	is_string(site)
	site != ""
	count(plants) > 0
}

# IRI 경로 구성요소 퍼센트 인코딩(안내서 8.1). 공백은 %20
enc(s) := replace(urlquery.encode(s), "+", "%20")

# ---- 전 테넌트 공통(읽기) ----
graphs contains sprintf("%stbox/ksx9101", [base]) if valid_claims

graphs contains sprintf("%sshapes", [base]) if valid_claims

graphs contains sprintf("%scodelist", [base]) if valid_claims

# ---- 해당 기업 Extension T-Box ----
graphs contains sprintf("%stbox/ext/%s", [base, enc(ent)]) if valid_claims

# ---- 사업장(공장) 단위 A-Box ----
graphs contains sprintf("%s%s/%s/%s", [base, enc(ent), enc(site), enc(p)]) if {
	valid_claims
	some p in plants
}

# ---- 규칙별 추론 그래프: graph:inferred/{Ent}/{Site}/{RuleID} ----
graph_prefixes contains sprintf("%sinferred/%s/%s/", [base, enc(ent), enc(site)]) if valid_claims

# ---- BOD 원장: 감사 역할만 ----
graph_prefixes contains sprintf("%sbod/", [base]) if {
	valid_claims
	data.ksx.config.auditor_role in roles
}

default allow_graph := false

allow_graph if input.graph in graphs

allow_graph if {
	some pre in graph_prefixes
	startswith(input.graph, pre)
	not contains(substring(input.graph, count(pre), -1), "..")
}

# ---- PostgreSQL RLS 세션 변수 (도구가 SET LOCAL 로 적용) ----
ledger_session := {
	"app.enterprise_id": ent,
	"app.site_id": site,
	"app.plant_ids": concat(",", sort([p | some p in plants])),
} if {
	valid_claims
}

# 불완전 클레임 진단(로그용)
deny_reason contains "missing enterpriseId" if not valid_ent

deny_reason contains "missing siteId" if not valid_site

deny_reason contains "missing plantId/plants" if count(plants) == 0

valid_ent if {
	is_string(ent)
	ent != ""
}

valid_site if {
	is_string(site)
	site != ""
}

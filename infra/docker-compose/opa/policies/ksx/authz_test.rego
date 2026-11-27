package ksx.authz_test

import rego.v1

import data.ksx.authz

base := "https://data.impix.co.kr/graph/"

p1_user := {"enterpriseId": "IMPIX", "siteId": "HQ", "plantId": "P1", "plants": ["P1"], "roles": ["data-engineer"]}

p2_user := {"enterpriseId": "IMPIX", "siteId": "HQ", "plants": ["P2"], "roles": []}

multi_plant := {"enterpriseId": "IMPIX", "siteId": "HQ", "plants": ["P1", "P2"], "roles": []}

auditor := {"enterpriseId": "IMPIX", "siteId": "HQ", "plants": ["P1"], "roles": ["auditor"]}

allow(c, g) if authz.allow_graph with input as {"claims": c, "graph": concat("", [base, g])}

test_vocab_graphs if {
	g := authz.graphs with input as {"claims": p1_user}
	concat("", [base, "tbox/ksx9101"]) in g
	concat("", [base, "tbox/inference"]) in g
	concat("", [base, "shapes"]) in g
	concat("", [base, "codelist"]) in g
	concat("", [base, "tbox/ext/IMPIX"]) in g
}

test_scopes if {
	s := authz.scopes with input as {"claims": p1_user}
	s == {"IMPIX", "IMPIX/HQ/HQ", "IMPIX/HQ/P1"}
}

test_common_data_allowed if {
	allow(p1_user, "IMPIX")
	allow(p1_user, "IMPIX/HQ/HQ")
	allow(p2_user, "IMPIX")
}

test_own_plant_allowed if {
	allow(p1_user, "IMPIX/HQ/P1")
	allow(p1_user, "quality/IMPIX/HQ/P1")
	allow(p1_user, "inferred/IMPIX/HQ/P1/R-020")
	allow(p1_user, "inferred/IMPIX/R-002")
	allow(p1_user, "inferred/IMPIX/HQ/HQ/R-100")
}

test_other_plant_denied if {
	not allow(p1_user, "IMPIX/HQ/P2")
	not allow(p1_user, "quality/IMPIX/HQ/P2")
	not allow(p1_user, "inferred/IMPIX/HQ/P2/R-020")
	not allow(p2_user, "inferred/IMPIX/HQ/P1/R-020")
}

# 기업 공통 추론 접두(inferred/IMPIX/)가 공장 추론 그래프까지 열지 않는다
test_prefix_one_segment_only if {
	not allow(p1_user, "inferred/IMPIX/HQ/P2/R-020")
	not allow(p1_user, "inferred/IMPIX/")
	not allow(p1_user, "inferred/IMPIX/HQ/R-001")
}

test_old_site_level_inferred_denied if {
	not allow(p1_user, "inferred/IMPIX/HQ/R-001")
}

test_other_site_denied if {
	not allow(p1_user, "IMPIX/BR/P1")
	not allow(p1_user, "IMPIX/BR/BR")
}

test_other_enterprise_denied if {
	not allow(p1_user, "tbox/ext/OTHER")
	not allow(p1_user, "OTHER")
	count(authz.graphs) == 0 with input as {"claims": {"enterpriseId": "OTHER", "siteId": "HQ", "plants": ["P1"]}}
}

test_multi_plant if {
	g := authz.graphs with input as {"claims": multi_plant}
	concat("", [base, "IMPIX/HQ/P1"]) in g
	concat("", [base, "IMPIX/HQ/P2"]) in g
}

test_path_traversal_denied if {
	not allow(p1_user, "inferred/IMPIX/HQ/P1/../../P2/R-020")
	not allow(p1_user, "inferred/IMPIX/HQ/P1/..")
}

test_bod_only_auditor if {
	not allow(p1_user, "bod/BOD-001")
	allow(auditor, "bod/BOD-001")
}

test_incomplete_claims_deny_all if {
	count(authz.graphs) == 0 with input as {"claims": {"enterpriseId": "IMPIX", "siteId": "HQ"}}
	count(authz.graphs) == 0 with input as {}
	not authz.ledger_session with input as {"claims": {"siteId": "HQ", "plants": ["P1"]}}
}

test_ledger_session if {
	s := authz.ledger_session with input as {"claims": multi_plant}
	s["app.enterprise_id"] == "IMPIX"
	s["app.site_id"] == "HQ"
	s["app.plant_ids"] == "P1,P2"
}

test_iri_components_encoded if {
	g := authz.graphs with input as {"claims": {"enterpriseId": "IMPIX", "siteId": "H Q", "plants": ["P/1"]}}
	concat("", [base, "IMPIX/H%20Q/P%2F1"]) in g
}

package ksx.authz_test

import rego.v1

import data.ksx.authz

base := "https://data.acme.example/graph/"

p1_user := {"enterpriseId": "ACME", "siteId": "HQ", "plantId": "P1", "plants": ["P1"], "roles": ["data-engineer"]}

multi_plant := {"enterpriseId": "ACME", "siteId": "HQ", "plants": ["P1", "P2"], "roles": []}

auditor := {"enterpriseId": "ACME", "siteId": "HQ", "plants": ["P1"], "roles": ["auditor"]}

test_common_graphs if {
	g := authz.graphs with input as {"claims": p1_user}
	concat("", [base, "tbox/ksx9101"]) in g
	concat("", [base, "shapes"]) in g
	concat("", [base, "codelist"]) in g
	concat("", [base, "tbox/ext/ACME"]) in g
}

test_own_plant_allowed if {
	authz.allow_graph with input as {"claims": p1_user, "graph": concat("", [base, "ACME/HQ/P1"])}
}

test_other_plant_denied if {
	not authz.allow_graph with input as {"claims": p1_user, "graph": concat("", [base, "ACME/HQ/P2"])}
}

test_other_site_denied if {
	not authz.allow_graph with input as {"claims": p1_user, "graph": concat("", [base, "ACME/BR/P1"])}
}

test_other_enterprise_ext_denied if {
	not authz.allow_graph with input as {"claims": p1_user, "graph": concat("", [base, "tbox/ext/OTHER"])}
}

test_multi_plant if {
	g := authz.graphs with input as {"claims": multi_plant}
	concat("", [base, "ACME/HQ/P1"]) in g
	concat("", [base, "ACME/HQ/P2"]) in g
}

test_inferred_prefix if {
	authz.allow_graph with input as {"claims": p1_user, "graph": concat("", [base, "inferred/ACME/HQ/R-OTD-01"])}
	not authz.allow_graph with input as {"claims": p1_user, "graph": concat("", [base, "inferred/ACME/BR/R-OTD-01"])}
}

test_path_traversal_denied if {
	not authz.allow_graph with input as {"claims": p1_user, "graph": concat("", [base, "inferred/ACME/HQ/../../BR/x"])}
}

test_bod_only_auditor if {
	not authz.allow_graph with input as {"claims": p1_user, "graph": concat("", [base, "bod/BOD-001"])}
	authz.allow_graph with input as {"claims": auditor, "graph": concat("", [base, "bod/BOD-001"])}
}

test_incomplete_claims_deny_all if {
	count(authz.graphs) == 0 with input as {"claims": {"enterpriseId": "ACME", "siteId": "HQ"}}
	count(authz.graphs) == 0 with input as {}
	not authz.ledger_session with input as {"claims": {"siteId": "HQ", "plants": ["P1"]}}
}

test_ledger_session if {
	s := authz.ledger_session with input as {"claims": multi_plant}
	s["app.enterprise_id"] == "ACME"
	s["app.site_id"] == "HQ"
	s["app.plant_ids"] == "P1,P2"
}

test_iri_components_encoded if {
	g := authz.graphs with input as {"claims": {"enterpriseId": "ACME", "siteId": "H Q", "plants": ["P/1"]}}
	concat("", [base, "ACME/H%20Q/P%2F1"]) in g
}

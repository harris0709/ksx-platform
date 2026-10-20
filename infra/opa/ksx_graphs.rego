package ksx.graphs

import rego.v1

# 토큰 클레임으로 허용 Named Graph 목록 계산 (도구가 SPARQL FROM NAMED로 강제)
allowed contains g if {
  some p in input.claims.plants
  g := sprintf("https://data.impix.co.kr/graph/%s/%s/%s", [input.claims.enterpriseId, input.claims.siteId, p])
}

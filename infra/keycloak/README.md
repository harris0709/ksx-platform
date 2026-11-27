# Keycloak realm

realm 정의는 `infra/docker-compose/keycloak/realm-ksx.json`(compose가 기동 시 가져옴)에 있습니다. 클레임 enterpriseId·siteId·plantId·plants·roles 매퍼와 IMPIX 개발 사용자(dev-p1·dev-p2·dev-all·dev-auditor 등)를 담습니다. 정책은 `infra/docker-compose/opa/policies/ksx/`.

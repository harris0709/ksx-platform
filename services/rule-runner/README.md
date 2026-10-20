# rule-runner (S7)

`ontologies/rules/*.rq`를 파일명 순서로 실행하고 결과를 `graph:inferred/{Ent}/{Site}/{RuleID}`에 통째로 교체합니다. 파라미터는 `ontologies/rules/params.yaml`.

```bash
python services/rule-runner/runner.py --fuseki http://localhost:3030/ksx --ent ACME --site HQ
python services/rule-runner/runner.py --local out/data.nt ontologies/vocab/codelist.ttl --today 2026-10-20   # 시험(rdflib)
```

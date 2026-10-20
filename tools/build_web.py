"""ontologies/catalog/nouns/*.json → web/data/nouns.js (웹 콘솔 데이터). 생성물이 바뀌면 다시 실행한다."""
import glob
import json
import os

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))


def main() -> None:
    slim = []
    for f in sorted(glob.glob(os.path.join(ROOT, "ontologies", "catalog", "nouns", "*.json"))):
        c = json.load(open(f, encoding="utf-8"))
        slim.append({k: c[k] for k in ["noun", "ko", "clause", "table", "area", "definition", "identity", "struct", "physical"]} | {
            "attrs": [[a["en"], a["ko"], a["type"], a["property"].replace("ksx:", ""), a.get("copyOf", ""), a["in"]] for a in c["attributes"]],
            "refs": [[r["attr"], r["target"], r["property"].replace("ksx:", ""), r["in"]] for r in c["references"]],
            "codes": [[x["attr"], x["group"]] for x in c["codes"]]})
    out = os.path.join(ROOT, "web", "data", "nouns.js")
    os.makedirs(os.path.dirname(out), exist_ok=True)
    with open(out, "w", encoding="utf-8", newline="\n") as fh:
        fh.write("// tools/build_web.py 생성물 — 직접 수정 금지\nconst NOUNS=" + json.dumps(slim, ensure_ascii=False, separators=(",", ":")) + ";\n")
    print(f"web/data/nouns.js: 명사 {len(slim)}개")


if __name__ == "__main__":
    main()

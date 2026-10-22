"""최소 SQL 조립기(psycopg.sql 일부 호환). 결과가 str 이므로 어떤 DB-API 드라이버에도 넘길 수 있다."""


class SQL(str):
    def format(self, *args, **kwargs):  # noqa: A003
        return SQL(str.format(self, *[str(a) for a in args], **{k: str(v) for k, v in kwargs.items()}))

    def join(self, parts):  # noqa: A003
        return SQL(str.join(self, [str(p) for p in parts]))


def Identifier(*parts):  # noqa: N802
    return SQL(".".join('"' + p.replace('"', '""') + '"' for p in parts))

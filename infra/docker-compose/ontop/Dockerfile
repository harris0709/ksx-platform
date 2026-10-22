# Ontop SPARQL 엔드포인트 + PostgreSQL JDBC 드라이버, 헬스체크용 curl
ARG ONTOP_VERSION
FROM ontop/ontop:${ONTOP_VERSION}
ARG PG_JDBC_VERSION
USER root
RUN (command -v curl >/dev/null) \
    || (apt-get update && apt-get install -y --no-install-recommends curl && rm -rf /var/lib/apt/lists/*) \
    || (apk add --no-cache curl)
ADD --chmod=644 https://repo1.maven.org/maven2/org/postgresql/postgresql/${PG_JDBC_VERSION}/postgresql-${PG_JDBC_VERSION}.jar /opt/ontop/jdbc/

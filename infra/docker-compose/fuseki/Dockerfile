# Apache Jena Fuseki(main server, TDB2) — 공식 배포 jar를 Maven Central에서 받아 고정 버전으로 빌드
FROM eclipse-temurin:21-jre-jammy
ARG JENA_VERSION
RUN apt-get update && apt-get install -y --no-install-recommends curl && rm -rf /var/lib/apt/lists/* \
 && mkdir -p /opt/fuseki /fuseki/databases \
 && curl -fsSL -o /opt/fuseki/fuseki-server.jar \
    "https://repo1.maven.org/maven2/org/apache/jena/jena-fuseki-server/${JENA_VERSION}/jena-fuseki-server-${JENA_VERSION}.jar" \
 && useradd -r -u 1001 fuseki && chown -R fuseki /fuseki
USER fuseki
WORKDIR /fuseki
EXPOSE 3030
ENV JAVA_OPTIONS="-Xmx2g"
ENTRYPOINT ["sh", "-c", "exec java $JAVA_OPTIONS -jar /opt/fuseki/fuseki-server.jar \"$@\"", "--"]

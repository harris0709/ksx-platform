# Apache Jena Fuseki (공식 배포본으로 빌드). 망분리 환경은 tar.gz를 미리 반입해 COPY로 바꾼다.
FROM eclipse-temurin:21-jre
ARG JENA_VERSION=5.2.0
RUN apt-get update && apt-get install -y --no-install-recommends curl && rm -rf /var/lib/apt/lists/* \
 && curl -fsSL https://archive.apache.org/dist/jena/binaries/apache-jena-fuseki-${JENA_VERSION}.tar.gz | tar -xz -C /opt \
 && mv /opt/apache-jena-fuseki-${JENA_VERSION} /opt/fuseki
WORKDIR /opt/fuseki
COPY config.ttl /opt/fuseki/run/config.ttl
EXPOSE 3030
CMD ["./fuseki-server", "--config=/opt/fuseki/run/config.ttl"]

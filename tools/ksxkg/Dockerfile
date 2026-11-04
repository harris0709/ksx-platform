# S5 지식 그래프 도구 실행 이미지: ksxkg(저장소를 /repo로 마운트해 그대로 실행) + Morph-KGC + psql
FROM python:3.12-slim
RUN apt-get update \
 && apt-get install -y --no-install-recommends postgresql-client \
 && rm -rf /var/lib/apt/lists/*
RUN pip install --no-cache-dir morph-kgc psycopg2-binary SQLAlchemy "PyYAML==6.0.2"
ENV PYTHONPATH=/repo/tools/ksxkg PYTHONUNBUFFERED=1 PYTHONUTF8=1
WORKDIR /repo
ENTRYPOINT ["python", "-m", "ksxkg"]

# S3 적재 도구 실행 이미지: ksxload(저장소를 /repo로 마운트해 그대로 실행) + dbt-postgres + psql + openpyxl(검토서)
FROM python:3.12-slim
RUN apt-get update \
 && apt-get install -y --no-install-recommends postgresql-client \
 && rm -rf /var/lib/apt/lists/*
RUN pip install --no-cache-dir "dbt-core>=1.8,<1.9" "dbt-postgres==1.8.2" "PyYAML==6.0.2" "openpyxl==3.1.5"
ENV PYTHONPATH=/repo/tools/ksxload PYTHONUNBUFFERED=1 PYTHONUTF8=1
WORKDIR /repo
ENTRYPOINT ["python", "-m", "ksxload"]

# S1 원천 분석 도구 실행 이미지 (저장소는 /repo 로 마운트)
FROM python:3.12-slim
RUN pip install --no-cache-dir "psycopg[binary]==3.2.3" "openpyxl==3.1.5" "PyYAML==6.0.2" "python-docx==1.1.2"
COPY s1profiler /app/s1profiler
ENV PYTHONPATH=/repo/tools/s1profiler:/app PYTHONUNBUFFERED=1
ENTRYPOINT ["python", "-m", "s1profiler"]

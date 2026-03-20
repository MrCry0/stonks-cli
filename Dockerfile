FROM python:3.11-slim AS builder
WORKDIR /app

RUN pip install --no-cache-dir --upgrade pip build

COPY pyproject.toml README.md /app/
COPY src /app/src

RUN python -m build --wheel

FROM python:3.11-slim AS runtime
WORKDIR /app

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

COPY --from=builder /app/dist/*.whl /tmp/
RUN pip install --no-cache-dir /tmp/*.whl && \
    rm -rf /tmp/*.whl

ENTRYPOINT ["stonks"]

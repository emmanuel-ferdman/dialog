FROM python:3.11-slim
LABEL org.opencontainers.image.source https://github.com/talkdai/dialog
LABEL org.opencontainers.image.licenses MIT

ENV PIP_DEFAULT_TIMEOUT=100
ENV PIP_DISABLE_PIP_VERSION_CHECK=on
ENV PIP_NO_CACHE_DIR=on
ENV PYTHONFAULTHANDLER=1
ENV PYTHONHASHSEED=random
ENV PYTHONUNBUFFERED=1

WORKDIR /app

COPY poetry.lock pyproject.toml /app/

RUN pip install poetry && \
  poetry config virtualenvs.create false && \
  poetry install --no-dev

COPY /src /app/src
COPY /etc /app/etc

WORKDIR /app/src

ENTRYPOINT [ "/app/etc/run.sh" ]

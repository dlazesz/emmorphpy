# From official Debian 10 Buster image pinned by its name bullseye-slim
FROM debian:bullseye-slim


# Install noske dependencies
## deb packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        python3-pip \
        hfst && \
    rm -rf /var/lib/apt/lists/* && \
    pip3 install gunicorn https://github.com/dlt-rilmta/emmorphpy/releases/download/v1.1.0/emmorphpy-1.1.0-py3-none-any.whl

ADD scripts/emmorphrest.py /app/
WORKDIR /app/

ENTRYPOINT ["python3", "-m", "gunicorn", "--bind", "0.0.0.0:8000", "emmorphrest:app", "--log-file=-"]
EXPOSE 8000

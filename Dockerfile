# From official Debian 13 Trixie image pinned by its name trixie-slim
FROM debian:trixie-slim


# Install noske dependencies
## deb packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        python3-pip \
        hfst && \
    rm -rf /var/lib/apt/lists/* && \
    pip3 install --break-system-packages gunicorn https://github.com/dlazesz/emmorphpy/releases/download/v1.1.1/emmorphpy-1.1.1-py3-none-any.whl

ADD scripts/emmorphrest.py /app/
WORKDIR /app/

ENTRYPOINT ["python3", "-m", "gunicorn", "--bind", "0.0.0.0:8000", "emmorphrest:app", "--log-file=-"]
EXPOSE 8000

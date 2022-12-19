FROM python:3.8-alpine

COPY ./shadowsocks-mod /app
WORKDIR /app

RUN apk add --no-cache \
        gcc \
        libsodium-dev \
        libffi-dev \
    apk add --no-cache --virtual .build \
        libc-dev \
        rust \
        cargo
    # python -m pip install --upgrade pip && \
RUN pip install --no-cache-dir -r requirements.txt && \
    cp docker-apiconfig.py userapiconfig.py && \
    apk del --purge .build

CMD ["server.py"]
ENTRYPOINT ["python"]
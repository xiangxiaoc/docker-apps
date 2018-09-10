FROM kibana:5.6.11

ADD Kibana_Hanization.tar.xz /

WORKDIR /Kibana_Hanization

RUN apt update && \
    apt install -y --no-install-recommends python && \
    python main.py /usr/share/kibana && \
    rm -rf /Kibana_Hanization && \
    apt purge -y --auto-remove python
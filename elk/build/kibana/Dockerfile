FROM kibana:5.6.11

ADD Kibana_Hanization.tar.xz /

WORKDIR /Kibana_Hanization

RUN python main.py /usr/share/kibana && \
    rm -rf /Kibana_Hanization
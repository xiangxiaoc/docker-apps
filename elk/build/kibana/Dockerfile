FROM kibana:6.4.2

USER root

ADD Kibana_Hanization.tar.xz /

WORKDIR /Kibana_Hanization

RUN python main.py /usr/share/kibana && \
    rm -rf /Kibana_Hanization 

USER kibana
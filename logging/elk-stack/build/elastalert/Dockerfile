FROM python:2.7.16

RUN git clone https://github.com/Yelp/elastalert.git 

WORKDIR /elastalert

RUN pip install -i https://pypi.tuna.tsinghua.edu.cn/simple/ -r requirements.txt
RUN python setup.py install

RUN elastalert-create-index --host elasticsearch --port 9200 --no-auth --no-ssl --url-prefix '' --index elastalert_status --old-index elastalert_status
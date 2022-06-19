FROM ubuntu

ENV DB_HOST '172.17.0.3'
ENV DB_PORT 5432
ENV DB_USER 'postgres'
ENV DB_PASSWORD 'password'
ENV DATABASE 'jokes'


RUN apt-get update
RUN apt-get install -y python3
RUN apt-get -y install python3-pip

COPY ./requirements.txt /server/requirements.txt

WORKDIR /server

RUN pip3 install -r requirements.txt
COPY . /server

CMD [ "python3", "main.py" ]


# docker build -t server .
# docker run -d --name myserver -p 80:80 --env DB_HOST=172.17.0.2 server
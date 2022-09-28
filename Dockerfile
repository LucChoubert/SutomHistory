FROM ubuntu

RUN apt-get update &&\
    apt-get install -y wget python-is-python3 ssmtp

WORKDIR /app

COPY orchestrateSutomHistory.sh .
COPY SutomHistory.py .
RUN touch ssmtp.conf &&\
    chmod 600 ssmtp.conf

CMD /app/orchestrateSutomHistory.sh 

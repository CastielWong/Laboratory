FROM python:3.8-alpine

ENV FLASK_ENV development
ENV FLASK_APP main.py
ENV FLASK_RUN_HOST 0.0.0.0

RUN apk add --no-cache gcc musl-dev linux-headers

WORKDIR /code

COPY ./requirements.txt /tmp
RUN pip install -r /tmp/requirements.txt

COPY ./restful .

CMD ["flask", "run"]

FROM python:alpine

WORKDIR /app
COPY main.py .
COPY requirements.txt .

RUN pip install -r requirements.txt

EXPOSE 8080 80

CMD ["python", "/app/main.py"]

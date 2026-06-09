FROM python:3.12-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app.py .
COPY commands.yaml .
COPY nc_awareness.yaml .
COPY templates ./templates

EXPOSE 443

CMD ["python", "app.py"]

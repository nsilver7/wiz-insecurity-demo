FROM python:3.9-slim

RUN useradd -u 1001 -m appuser

WORKDIR /app

COPY . .

RUN pip install --no-cache-dir -r requirements.txt

USER 1001

EXPOSE 8080

CMD ["python", "app.py"]

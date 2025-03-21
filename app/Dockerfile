FROM python:3.9-slim

RUN useradd -m appuser

WORKDIR /app

COPY . .

RUN pip install --no-cache-dir -r requirements.txt

USER appuser

EXPOSE 8080

CMD ["python", "app.py"]

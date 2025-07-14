# ---- Build stage ----
FROM python:3.11-alpine AS builder

# Install build deps only in build stage
RUN apk add --no-cache --virtual .build-deps \
    build-base \
    libpq \
    libpq-dev

WORKDIR /app

# Install pip deps into /install (keeps them separate from system)
COPY requirements.txt .
RUN pip install --upgrade pip && \
    pip install --prefix=/install -r requirements.txt

# ---- Final stage ----
FROM python:3.11-alpine

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    DJANGO_SETTINGS_MODULE=project.settings

WORKDIR /app

# Install runtime deps (smaller)
RUN apk add --no-cache libpq

# Copy installed Python packages from builder stage
COPY --from=builder /install /usr/local

# Copy project files
COPY . .

# Collect static + migrate
RUN python manage.py collectstatic --noinput && \
    python manage.py migrate --noinput

EXPOSE 8000

CMD ["gunicorn", "project.wsgi:application", "--bind", "0.0.0.0:8000"]

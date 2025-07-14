# ---- Build stage ----
FROM python:3.11-alpine AS builder

# Install build dependencies only needed at build time
RUN apk add --no-cache --virtual .build-deps \
    build-base \
    libpq \
    libpq-dev

WORKDIR /app

# Install pip dependencies into a custom location (/install)
COPY requirements.txt .
RUN pip install --upgrade pip && \
    pip install --prefix=/install -r requirements.txt

# ---- Final stage ----
FROM python:3.11-alpine

# Environment variables
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    DJANGO_SETTINGS_MODULE=project.settings

WORKDIR /app

# Install only runtime dependencies (tiny image)
RUN apk add --no-cache libpq

# Copy installed Python packages from builder stage
COPY --from=builder /install /usr/local

# Copy project files (adjust if your Docker build context is not the project root)
COPY . .

# Pre-run collectstatic and migrate during image build
# ⚠️ WARNING: This is only fine if DB is available at build time (rare).
# Usually better to run these commands at container start instead.
# Comment out if DB isn't reachable when building:
RUN python manage.py collectstatic --noinput && \
    python manage.py migrate --noinput

# Expose port
EXPOSE 8000

# Run gunicorn server
CMD ["gunicorn", "project.wsgi:application", "--bind", "0.0.0.0:8000"]

# syntax=docker/dockerfile:1

# ───────────────────────────────────────────────────────────────────────────────
# 📦 Base Image
FROM python:3.13-slim

# ───────────────────────────────────────────────────────────────────────────────
# 🛠️ Install System Packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    && rm -rf /var/lib/apt/lists/*

# ───────────────────────────────────────────────────────────────────────────────
# 🐍 Install Poetry
ENV POETRY_HOME="/opt/poetry"
ENV PATH="$POETRY_HOME/bin:$PATH"
ENV POETRY_VIRTUALENVS_CREATE=false
RUN curl -sSL https://install.python-poetry.org | python3 -

# ───────────────────────────────────────────────────────────────────────────────
# 🗂️ Set Working Directory
WORKDIR /app

# ───────────────────────────────────────────────────────────────────────────────
# 📜 Copy Dependency Files First (Leverage Caching)
COPY pyproject.toml poetry.lock* ./

# Install project dependencies (both main and dev groups)
RUN poetry install --no-root --with dev

# ───────────────────────────────────────────────────────────────────────────────
# 📋 Setup REPL Startup Configuration
RUN mkdir -p /root/.config/python
COPY .config/python/startup.py /root/.config/python/startup.py
ENV PYTHONSTARTUP=/root/.config/python/startup.py

# ───────────────────────────────────────────────────────────────────────────────
# 🗃️ Copy Full Project
COPY . .

# ───────────────────────────────────────────────────────────────────────────────
# ⚙️ Environment Settings
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV PIP_NO_CACHE_DIR=1

# ───────────────────────────────────────────────────────────────────────────────
# 🚀 Default Command (Can Be Overridden)
CMD ["bash"]

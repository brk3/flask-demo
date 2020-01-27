FROM ubuntu:bionic

# https://docs.microsoft.com/en-us/sql/connect/odbc/linux-mac/installing-the-microsoft-odbc-driver-for-sql-server
RUN apt-get update \
  && apt-get install --yes --no-install-recommends \
    ca-certificates \
    curl \
    gnupg2 \
  && rm -rf /var/lib/apt/lists/* \
  && curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - \
  && curl https://packages.microsoft.com/config/ubuntu/18.04/prod.list > /etc/apt/sources.list.d/mssql-release.list

ENV ACCEPT_EULA=Y

RUN apt-get update \
  && apt-get install --yes --no-install-recommends \
    build-essential \
    curl \
    python3 \
    python3-dev \
    python3-pip \
    python3-setuptools \
    unixodbc-dev \
    msodbcsql17 \
  && rm -rf /var/lib/apt/lists/*

RUN pip3 install wheel

ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8

# Set the port on which the app runs; make both values the same.
#
# IMPORTANT: When deploying to Azure App Service, go to the App Service on the Azure 
# portal, navigate to the Applications Settings blade, and create a setting named
# WEBSITES_PORT with a value that matches the port here (the Azure default is 80).
# You can also create a setting through the App Service Extension in VS Code.
ENV LISTEN_PORT=5000
EXPOSE 5000

# Indicate where uwsgi.ini lives
ENV UWSGI_INI uwsgi.ini

# Tell nginx where static files live. Typically, developers place static files for
# multiple apps in a shared folder, but for the purposes here we can use the one
# app's folder. Note that when multiple apps share a folder, you should create subfolders
# with the same name as the app underneath "static" so there aren't any collisions
# when all those static files are collected together.
ENV STATIC_URL /app/static

# Set the folder where uwsgi looks for the app
WORKDIR /app

# Copy the app contents to the image
COPY . /app

RUN pip install --no-cache-dir -U pip
RUN pip install --no-cache-dir -r /app/requirements.txt

ENV FLASK_APP=hello.py

ENTRYPOINT ["flask", "run", "--host=0.0.0.0"]

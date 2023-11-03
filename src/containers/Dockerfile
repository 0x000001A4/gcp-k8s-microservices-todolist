FROM python:3-slim

ARG DB_NAMESPACE
ARG SERVICE_NAME
ARG PORT

RUN apt-get clean && apt-get -y update && apt-get -y upgrade

RUN apt-get -y install \
    python3-dev \
    python3-pip

WORKDIR /app

COPY requirements.txt requirements.txt
RUN pip install -r requirements.txt --src /usr/local/src

COPY services/${SERVICE_NAME} .
COPY keys keys

ENV DB_NAMESPACE=${DB_NAMESPACE}
ENV PORT=${PORT}
ENV PYTHON_FILE="${SERVICE_NAME}.py"

CMD python "${PYTHON_FILE}"
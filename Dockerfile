FROM python:3.12-alpine
WORKDIR /app

RUN apk add --no-cache curl build-base

COPY . .

# Accept build-time PAT
ARG AZURE_DEVOPS_PAT

RUN mkdir -p /root/.pip && \
    echo "[global]" > /root/.pip/pip.conf && \
    echo "index-url = https://${AZURE_DEVOPS_PAT}:@pkgs.dev.azure.com/SailahariVegiraju/_packaging/pypublicfeed/pypi/simple/" >> /root/.pip/pip.conf

RUN pip install --no-cache-dir -r requirements.txt
EXPOSE 8080
ENTRYPOINT ["python3", "app.py"]
FROM python:3-alpine
WORKDIR /service
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY . ./
EXPOSE 8080
ENTRYPOINT ["python3", "app.py"]


FROM python:3.12-alpine
WORKDIR /app

RUN apk add --no-cache curl build-base

COPY . .

# Accept build-time PAT
ARG AZURE_DEVOPS_PAT

RUN mkdir -p /root/.pip && \
    echo "[global]" > /root/.pip/pip.conf && \
    echo "index-url = https://${AZURE_DEVOPS_PAT}:@pkgs.dev.azure.com/YOUR_ORG/YOUR_PROJECT/_packaging/YOUR_FEED/pypi/simple/" >> /root/.pip/pip.conf && \
    echo "extra-index-url = https://pypi.org/simple" >> /root/.pip/pip.conf && \
    echo "trusted-host = pkgs.dev.azure.com" >> /root/.pip/pip.conf

RUN pip install --no-cache-dir -r requirements.txt

CMD ["python", "main.py"]

docker build \
  --build-arg AZURE_DEVOPS_PAT=your_real_pat_here \
  -t my-private-python-app .

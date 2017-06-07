FROM jenkinsci/slave:alpine

USER root
RUN apk add --no-cache \
ca-certificates \
curl \
openssl

ENV DOCKER_BUCKET get.docker.com
ENV DOCKER_VERSION 17.04.0-ce
ENV DOCKER_SHA256 c52cff62c4368a978b52e3d03819054d87bcd00d15514934ce2e0e09b99dd100
ENV HELM_VERSION=v2.4.2
ENV HELM_FILENAME=helm-${HELM_VERSION}-linux-amd64.tar.gz

RUN set -x \
&& curl -fSL "https://${DOCKER_BUCKET}/builds/Linux/x86_64/docker-${DOCKER_VERSION}.tgz" -o docker.tgz \
&& echo "${DOCKER_SHA256} *docker.tgz" | sha256sum -c - \
&& tar -xzvf docker.tgz \
&& mv docker/* /usr/local/bin/ \
&& rmdir docker \
&& rm docker.tgz \
&& docker -v

RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl

RUN chmod +x ./kubectl
RUN mv ./kubectl /usr/local/bin/kubectl

RUN curl -L https://storage.googleapis.com/kubernetes-helm/${HELM_FILENAME} | tar xz && mv linux-amd64/helm /bin/helm && rm -rf linux-amd64

COPY docker-entrypoint.sh /usr/local/bin/

COPY jenkins-slave /usr/local/bin/jenkins-slave

RUN chmod +x /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/jenkins-slave

ENTRYPOINT docker-entrypoint.sh; jenkins-slave

CMD ["helm"]

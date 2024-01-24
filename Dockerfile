FROM python:3.7-slim-buster AS build
RUN apt-get update
RUN apt-get install sudo -y
RUN sudo apt-get install -y git apt-transport-https ca-certificates curl jq
RUN curl -L https://github.com/mikefarah/yq/releases/download/v4.30.6/yq_linux_amd64 -o /usr/local/bin/yq \
    && chmod +x /usr/local/bin/yq
ENV KUBE_VERSION="v1.25.4"
RUN curl -sLo /usr/local/bin/kubectl https://dl.k8s.io/release/${KUBE_VERSION}/bin/linux/amd64/kubectl \
&& chmod +x /usr/local/bin/kubectl

ADD ./scripts /usr/local/sbin/

WORKDIR /home

COPY . . 

ENV PATH=/root/.local/bin:$PATH
RUN chmod +x /usr/local/sbin/injectionMechanism.sh
CMD /usr/local/sbin/injectionMechanism.sh

FROM debian AS builder

MAINTAINER NTTID

ARG APPD_AGENT_VERSION=1.8-23.8.0.35032
ARG APPD_AGENT_ZIP=AppServerAgent-1.8-23.8.0.35032.zip
ARG APPD_AGENT_SHA256=bdb790454d44c21dab74bf400842739866c86faa9568bd95b35be1bc3b4c9c93

RUN apt-get update && apt-get install -y --no-install-recommends  unzip \
	&& rm -rf /var/lib/apt/lists/*

COPY ${APPD_AGENT_ZIP} /
RUN echo "${APPD_AGENT_SHA256} *AppServerAgent-${APPD_AGENT_VERSION}.zip" >> appd_checksum \
    && sha256sum -c appd_checksum \
    && rm appd_checksum \
    && unzip -oq AppServerAgent-${APPD_AGENT_VERSION}.zip -d /tmp 
	
	
FROM openjdk:17-oracle

COPY --from=builder /tmp /opt/appdynamics
COPY ./spring-petclinic-3.1.0-SNAPSHOT.jar /opt/spring-petclinic-3.1.0-SNAPSHOT.jar
WORKDIR /opt/

ENV APPDYNAMICS_AGENT_APPLICATION_NAME=Spring-external 
ENV APPDYNAMICS_AGENT_TIER_NAME=web-tier1 
ENV APPDYNAMICS_AGENT_ACCOUNT_NAME=ptnttindonesiatechnology-nfr 
ENV APPDYNAMICS_AGENT_ACCOUNT_ACCESS_KEY=jn8da2f8bhai 
ENV APPDYNAMICS_CONTROLLER_HOST_NAME=ptnttindonesiatechnology-nfr.saas.appdynamics.com 
ENV APPDYNAMICS_CONTROLLER_PORT=443 
ENV APPDYNAMICS_CONTROLLER_SSL_ENABLED=true 
ENV APPDYNAMICS_JAVA_AGENT_REUSE_NODE_NAME=true 
ENV APPDYNAMICS_JAVA_AGENT_REUSE_NODE_NAME_PREFIX=front-node


ENTRYPOINT ["java","-javaagent:/opt/appdynamics/javaagent.jar","-jar","spring-petclinic-3.1.0-SNAPSHOT.jar"]
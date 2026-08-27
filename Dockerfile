# ------------------------------------------------------------------------------
# IRIS AI Hub Studio - Main Dockerfile
# 
# Base image: InterSystems IRIS Community Edition with AI Hub
# This Dockerfile sets up the IRIS environment with AI Hub capabilities
# ------------------------------------------------------------------------------

# Use the official IRIS AI Hub Community image (2026.3.0AI.136.0)
# This includes AI Hub support + internal web server (htpd) for Management Portal
FROM docker.iscinternal.com/docker-intersystems/intersystems/iris-community:2026.3.0AI.136.0

# ------------------------------------------------------------------------------
# Environment Variables
# ------------------------------------------------------------------------------

ARG NAMESPACE="AI_HUB_STUDIO"

ENV IRISUSERNAME "_SYSTEM"
ENV IRISPASSWORD "SYS"
ENV IRISNAMESPACE $NAMESPACE
ENV PATH "/usr/irissys/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/home/irisowner/bin"

WORKDIR /home/irisowner/dev

# ------------------------------------------------------------------------------
# Copy application source and scripts
# ------------------------------------------------------------------------------

COPY config_http.toml /home/irisowner/dev/config_http.toml

# CPF merge file for namespace and database setup
COPY merge.cpf /home/irisowner/dev/merge.cpf

# Application installer
COPY App.Installer.cls /home/irisowner/dev/App.Installer.cls

# Source code
# Normalize permissions while copying: host files may be mode 0600, while IRIS
# compilation runs as irisowner. Executable bits are harmless for source files.
COPY --chown=irisowner:irisowner --chmod=0755 src /home/irisowner/dev/src

# IRIS startup script
COPY iris.script /home/irisowner/dev/iris.script

# ------------------------------------------------------------------------------
# IRIS setup: merge CPF, import code, create databases
# ------------------------------------------------------------------------------

RUN --mount=type=bind,src=.,dst=. \
    iris start IRIS && \
    iris merge IRIS /home/irisowner/dev/merge.cpf && \
    iris session IRIS < /home/irisowner/dev/iris.script && \
    iris stop IRIS quietly

# ------------------------------------------------------------------------------
# Ports exposed by IRIS
# 1972  -> IRIS SuperServer (ODBC, JDBC, etc.)
# 52773 -> Management Portal / Web Apps
# 53773 -> AI Hub WebSocket
# ------------------------------------------------------------------------------
EXPOSE 1972 52773 53773

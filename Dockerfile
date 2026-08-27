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

# Embedded Python environment
ENV IRISUSERNAME "_SYSTEM"
ENV IRISPASSWORD "SYS"
ENV IRISNAMESPACE $NAMESPACE
ENV PYTHON_PATH=/usr/irissys/bin/
ENV PYTHONPATH="/usr/irissys/lib/python"
ENV PATH "/usr/irissys/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/home/irisowner/bin"

WORKDIR /home/irisowner/dev

# ------------------------------------------------------------------------------
# Copy application source and scripts
# ------------------------------------------------------------------------------

# Requirements for Python packages
COPY requirements.txt /home/irisowner/dev/requirements.txt

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
# Python environment setup
# ------------------------------------------------------------------------------

RUN python3 -m venv "/home/irisowner/.venvs/mcp-tools" && \
   "/home/irisowner/.venvs/mcp-tools/bin/python" -m pip install -r /home/irisowner/dev/requirements.txt --break-system-packages --target /usr/irissys/mgr/python && \
   "/home/irisowner/.venvs/mcp-tools/bin/python" -m pip install typing-extensions --upgrade --break-system-packages --target /usr/irissys/mgr/python

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

#!/bin/bash
set -e

# ─── Configuration ────────────────────────────────────────────────────────────
IRIS_INSTANCE="IRIS"
APP_DIR="/home/irisowner/dev"
LOG_DIR="${APP_DIR}/logs"
LOG_FILE="${LOG_DIR}/entrypoint.log"
SCRIPT_FILE="${APP_DIR}/iris.script"
# ──────────────────────────────────────────────────────────────────────────────

echo "entrypoint.sh started"

# Start IRIS in the background
iris start "${IRIS_INSTANCE}" quietly
echo "IRIS instance '${IRIS_INSTANCE}' started"

# Run the import script at each container start. 
#  - the second line after this is used to redirect log output to a log file (logs won't be shown on Docker Desktop console).
echo "Running iris.script session, logging to ${LOG_FILE}..."
iris session "${IRIS_INSTANCE}" < "${SCRIPT_FILE}" >> "${LOG_FILE}" 2>&1
echo "iris.script session completed"

# Tail the log so it's visible in Docker Desktop console
echo "=== ${LOG_FILE} content ==="
cat "${LOG_FILE}"
echo "=== end of ${LOG_FILE} ==="

# Stop background IRIS cleanly (optional, for clean start)
iris stop "${IRIS_INSTANCE}" quietly
echo "IRIS instance '${IRIS_INSTANCE}' stopped, handing off to iris-main"

# exec replaces this process — nothing after this line will ever run
exec /iris-main "$@"
# Note: The above script assumes that the IRIS instance is named "IRIS"
# and that the import script is located at /opt/irisapp/iris.script.
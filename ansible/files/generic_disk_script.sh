#!/bin/bash
set -euo pipefail

# Detect OS
uname_out="$(uname -s)"
case "${uname_out}" in
    Linux*)     os_type="Linux";;
    CYGWIN*|MINGW*|MSYS_NT*) os_type="Windows";;
    *)          os_type="UNKNOWN:${uname_out}";;
esac

# === Function: Collect disk metrics on Linux ===
collect_linux_metrics() {
    df -P | tail -n +2 | awk '
    {
        gsub(/%/, "", $5);
        gsub(/"/, "\\\"", $1);
        gsub(/"/, "\\\"", $6);
        printf "{\"device\": \"%s\", \"utilization_percent\": %d, \"mount_point\": \"%s\"}\n", $1, $5, $6;
    }' | sed '$!s/$/,/' | awk 'BEGIN{print "["} {print} END{print "]"}'
}

# === Function: Collect disk metrics on Windows ===
collect_windows_metrics() {
    powershell.exe -Command "& {
        \$data = Get-WmiObject -Class Win32_LogicalDisk | Where-Object { \$_.DriveType -eq 3 } |
            Select-Object DeviceID,
                @{Name='SizeGB';Expression={ [int](\$_.Size / 1GB) }},
                @{Name='FreeGB';Expression={ [int](\$_.FreeSpace / 1GB) }},
                @{Name='UsedPercent';Expression={ [int]((\$_.Size - \$_.FreeSpace) / \$_.Size * 100) }};
        \$data | ConvertTo-Json -Compress
    }"
}

# === Get instance metadata and metrics ===
INSTANCE_ID=""
ACCOUNT_ID=""
TIMESTAMP=""
METRICS_JSON=""

if [[ "$os_type" == "Linux" ]]; then
    INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id || echo "unknown-instance")
    ACCOUNT_ID=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | grep accountId | awk -F'"' '{print $4}' || echo "unknown-account")
    TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    METRICS_JSON=$(collect_linux_metrics)
elif [[ "$os_type" == "Windows" ]]; then
    INSTANCE_ID=$(powershell.exe -Command "(Invoke-RestMethod -Uri 'http://169.254.169.254/latest/meta-data/instance-id').Trim()" 2>$null)
    ACCOUNT_ID=$(powershell.exe -Command "(Invoke-RestMethod -Uri 'http://169.254.169.254/latest/dynamic/instance-identity/document' | ConvertFrom-Json).accountId" 2>$null)
    TIMESTAMP=$(powershell.exe -Command "(Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')" 2>$null)
    METRICS_JSON=$(collect_windows_metrics)
else
    echo "{\"error\": \"Unsupported OS: $os_type\"}" >&2
    exit 1
fi

# === Output final payload ===
cat <<EOF
{
  "instance_id": "$INSTANCE_ID",
  "account_id": "$ACCOUNT_ID",
  "timestamp": "$TIMESTAMP",
  "os_type": "$os_type",
  "metrics": $METRICS_JSON
}
EOF

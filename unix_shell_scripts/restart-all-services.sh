#!/bin/bash

# SmartOutlet POS - Start All Services Script
# This script only starts all services (does not stop them first)
#
# IMPORTANT:
# - Run this script in the foreground (./restart-all-services.sh) to keep services running.
# - If you want to run in the background, use:
#     nohup ./restart-all-services.sh > all-services.log 2>&1 &
#   This will keep services running even after you close the terminal.

echo "🚀 Starting SmartOutlet POS - All Services..."
echo "=============================================="

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "\nNow starting all services..."
"$SCRIPT_DIR/run-all-services.sh" 
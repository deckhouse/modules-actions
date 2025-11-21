#!/bin/bash

# Retry a command with configurable attempts
# Usage: retry.sh <max_retries> <description> <command> [args...]

MAX_RETRIES="$1"
DESCRIPTION="$2"
shift 2

MAX_ATTEMPTS=$((1 + MAX_RETRIES))
ATTEMPT=1

while [ $ATTEMPT -le $MAX_ATTEMPTS ]; do
  echo "Attempt $ATTEMPT of $MAX_ATTEMPTS..."
  if "$@"; then
    exit 0
  fi

  # Command failed
  ATTEMPT=$((ATTEMPT + 1))
  if [ $ATTEMPT -le $MAX_ATTEMPTS ]; then
    echo "Attempt failed, retrying in 5 seconds..."
    sleep 5
  else
    echo "Failed to $DESCRIPTION after $MAX_ATTEMPTS attempts"
    exit 1
  fi
done


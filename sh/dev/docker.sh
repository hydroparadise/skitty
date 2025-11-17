#!/bin/bash

# Check if docker exists, install if absent
if ! command -v docker >/dev/null 2>&1; then
  curl -fsSL https://get.docker.com | sh
fi

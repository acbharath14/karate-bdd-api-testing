#!/usr/bin/env bash
#
# Preflight checks for the Karate API testing showcase.
#
# Verifies Java 17+ and Maven are available, installing what is missing
# (macOS via MacPorts, Linux via apt). This repo tests an HTTP API, so no
# browser or driver is needed and none is checked.
#
# Runs automatically inside `mvn test` (bound to the `validate` phase in
# pom.xml, in the preflight-unix profile). Skip with:
#   mvn test -Dpreflight.skip=true
# or: PREFLIGHT_SKIP=true mvn test
#
set -u

SKIP="${PREFLIGHT_SKIP:-false}"
if [ "$SKIP" = "true" ]; then
  echo "preflight: skipped (PREFLIGHT_SKIP=true)"
  exit 0
fi

fail=0

have() { command -v "$1" >/dev/null 2>&1; }

echo "preflight: checking Java..."
if have java; then
  ver="$(java -version 2>&1 | head -1)"
  echo "  found: $ver"
  major="$(echo "$ver" | sed -E 's/.*version "([0-9]+).*/\1/')"
  if [ "${major:-0}" -lt 17 ]; then
    echo "  ERROR: Java 17+ is required (Karate 1.5.x needs Java 17)."
    fail=1
  fi
else
  echo "  Java not found."
  if have port; then
    echo "  installing via MacPorts (this needs sudo)..."
    sudo port install openjdk17 || fail=1
    if ! have java; then
      echo "  MacPorts installed the JDK but java is still not on PATH."
      echo "  Fix: check the MacPorts install, or download Temurin 17 from"
      echo "  https://adoptium.net/temurin/releases/ and add it to PATH."
      fail=1
    fi
  elif have apt-get; then
    echo "  installing via apt (this needs sudo)..."
    sudo apt-get update -qq && sudo apt-get install -y -qq openjdk-17-jdk || fail=1
  else
    echo "  Fix: install a Temurin 17 JDK from https://adoptium.net/temurin/releases/"
    fail=1
  fi
fi

echo "preflight: checking Maven..."
if have mvn; then
  echo "  found: $(mvn -version 2>&1 | head -1)"
else
  echo "  Maven not found."
  if have port; then
    echo "  installing via MacPorts (this needs sudo)..."
    sudo port install maven || fail=1
  elif have apt-get; then
    echo "  installing via apt (this needs sudo)..."
    sudo apt-get update -qq && sudo apt-get install -y -qq maven || fail=1
  else
    echo "  Fix: install Maven from https://maven.apache.org/download.cgi and add it to PATH"
    fail=1
  fi
fi

if [ "$fail" -ne 0 ]; then
  echo "preflight: FAILED. Fix the items above, then re-run."
  echo "  (Skip this check with: mvn test -Dpreflight.skip=true)"
  exit 1
fi

echo "preflight: OK"

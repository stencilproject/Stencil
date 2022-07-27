#!/bin/bash

PROJECT_DIR="${PROJECT_DIR:-`cd "$(dirname $0)/..";pwd`}"
SWIFTLINT="${PROJECT_DIR}/.build/swiftlint/swiftlint"
CONFIG="${PROJECT_DIR}/.swiftlint.yml"
if [ $CI ]; then
	REPORTER="--reporter github-actions-logging"
else
  REPORTER=
fi

# possible paths
paths_sources="Sources"
paths_tests="Tests/StencilTests"

# load selected group
if [ $# -gt 0 ]; then
  key="$1"
else
  echo "error: need group to lint."
  exit 1
fi

selected_path=`eval echo '$'paths_$key`
if [ -z "$selected_path" ]; then
  echo "error: need a valid group to lint."
  exit 1
fi

SUB_CONFIG="${PROJECT_DIR}/${selected_path}/.swiftlint.yml"
if [ -f "$SUB_CONFIG" ]; then
  "$SWIFTLINT" lint --strict --config "$SUB_CONFIG" $REPORTER "${PROJECT_DIR}/${selected_path}"
else
  "$SWIFTLINT" lint --strict --config "$CONFIG" $REPORTER "${PROJECT_DIR}/${selected_path}"
fi

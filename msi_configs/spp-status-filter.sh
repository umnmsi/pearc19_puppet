#!/bin/bash
if [[ "$1" =~ "being built" ]]; then
  exit 1
fi

#!/usr/bin/env bash
# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MIT


. "${root}/.ci/load-ci.sh"

export DEBIAN_FRONTEND="noninteractive"
export PATH="${PATH}:${root}/.ci"

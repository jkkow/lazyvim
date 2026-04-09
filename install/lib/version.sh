#!/usr/bin/env bash

version_ge() {
  dpkg --compare-versions "$1" ge "$2"
}

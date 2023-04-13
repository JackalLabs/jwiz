#!/bin/bash
set -x

export FOO="${VARIABLE:-v1.2.1}" 

echo $FOO
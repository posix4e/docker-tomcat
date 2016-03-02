#!/bin/bash

set -e

import-trusted-ssl-certs.sh

exec "$@"





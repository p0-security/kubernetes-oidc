#!/bin/bash

kubectl patch clientconfig default -n kube-public --type merge --patch-file client-config-patch.yaml


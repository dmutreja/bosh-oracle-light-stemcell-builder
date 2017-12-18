#!/usr/bin/env bash

set -e

cpi_release_name="bosh-oracle-cpi"
manifest_filename="bosh.yml"
state_filename="director-state.json"


#Outputs
deployment_dir="${PWD}/deployment"
mkdir -p ${deployment_dir}


#Inputs
cp ./cpi-release/*.tgz ${deployment_dir}/${cpi_release_name}.tgz
cp ./stemcell/*.tgz ${deployment_dir}/stemcell.tgz
cp ./director-env/director-env-vars.yml ${deployment_dir}

echo "Setting up artifacts..."
cp ./cpi-release-src/bosh-deployment/bosh.yml ${deployment_dir}/${manifest_filename}
cp ./cpi-release-src/bosh-deployment/cpi.yml ${deployment_dir}
cp ./cpi-release-src/bosh-deployment/remove-hm.yml ${deployment_dir}/

local_yml="local.yml"
cat >"${deployment_dir}/${local_yml}"<<EOF
---
- type: replace
  path: /releases/name=bosh-oracle-cpi
  value:
    name: bosh-oracle-cpi
    url: file://${cpi_release_name}.tgz

- type: replace
  path: /resource_pools/name=vms/stemcell?
  value:
    url: file://stemcell.tgz
EOF


pushd ${deployment_dir}
  function finish {
    echo "Director deployment state:"
    echo "=========================================="
    cat ${state_filename}
    echo "=========================================="
  }
  trap finish ERR

  echo "Using BOSH CLI version..."
  bosh -v

  ls -al 

  echo "Deploying BOSH Director..."
  bosh create-env --ops-file ./cpi.yml --ops-file ./${local_yml} -o ./remove-hm.yml --vars-store ./creds.yml --state ${state_filename} --vars-file ./director-env-vars.yml ${manifest_filename}

  trap - ERR
  finish
popd

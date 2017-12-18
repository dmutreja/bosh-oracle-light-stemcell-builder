#!/usr/bin/env bash

set -e

#Inputs
version=`cat cpi-release-semver/number`
cpi="${cpi_release_name}-${version}.tgz"

# Outputs
release_path=cpi-release


# Create OCI config
echo "Creating oci config..."
pwd=`pwd`
oci_dir="${pwd}/.oci"
oci_api_key="${oci_dir}/oci_api_key.pem"
oci_config="${oci_dir}/config"

mkdir -p ${oci_dir}
cat > ${oci_api_key} <<EOF
${oracle_apikey}
EOF

cat > ${oci_config} <<EOF
[DEFAULT]
user=${oracle_user}
tenancy=${oracle_tenancy}
region=${oracle_region}
key_file=${oci_api_key}
fingerprint=${oracle_fingerprint}
EOF

chmod 600 ${oci_api_key}
chmod 600 ${oci_config}

# Download CPI
oci --config-file ${oci_config} os object get -ns ${oracle_namespace} -bn ${oracle_bucket} --name ${cpi} --file ${release_path}/${cpi}

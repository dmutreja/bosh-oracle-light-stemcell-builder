#!/usr/bin/env bash

set -e

pwd=`pwd`

#Outputs
oci_config_dir="${pwd}/oci-config"
mkdir -p ${oci_config_dir}


# Prepare oci invocation environment
oci_api_key="${oci_config_dir}/oci_api_key.pem"
oci_config="$oci_config_dir/config"

cat > ${oci_api_key} <<EOF
${oracle_apikey}
EOF

cat > $oci_config <<EOF
[DEFAULT]
user=${oracle_user}
tenancy=${oracle_tenancy}
region=${oracle_region}
key_file=${oci_api_key}
fingerprint=${oracle_fingerprint}
EOF

chmod 600 ${oci_api_key}
chmod 600 ${oci_config}
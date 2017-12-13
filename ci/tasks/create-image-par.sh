#!/bin/bash

set -e

function check_param() {
  local name=$1
  local value=$(eval echo '$'$name)
  if [ "$value" == 'replace-me' ]; then
    echo "environment variable $name must be set"
    exit 1
  fi
}

check_param oracle_namespace
check_param oracle_stemcell_bucket

pwd=`pwd`

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


#Inputs
stemcell_version=$( cat version/number | sed 's/\.0$//;s/\.0$//' )
full_stemcell_dir=${pwd}/stemcell

#Outputs
image_par_dir=${pwd}/image-par


full_stemcell=`ls -1rt  ${full_stemcell_dir}/*.tgz  | head -1`
full_stemcell_name=`basename ${full_stemcell}`
qcow2_image_name="root.img"
versioned_image_name="root-${stemcell_version}.img"


#Already uploaded?
existing=`oci --config-file ${oci_config} os object list -ns ${oracle_namespace} -bn ${oracle_stemcell_bucket} | jq '.data | .[] | select(.name=="${versioned_image_name}") | .name'`

#No,
if [ "$existing" == "" ]; then
    workdir="${pwd}/tmp"
    mkdir -p $workdir

    # Extract .qcow2 and upload it
    pushd ${workdir}
       tar xzvf ${full_stemcell}
       tar xzvf image
       oci --config-file ${oci_config} os object put -ns ${oracle_namespace} -bn ${oracle_stemcell_bucket} --name ${versioned_image_name} --file ${qcow2_image_name}
    popd
else
    echo "${versioned_image_name} already uploaded to object store"
fi

# Create a preauth-request
resp_json= ${image_par_dir}/preauth-response.json
oci os preauth-request create-ns ${oracle_namespace} -bn ${oracle_stemcell_bucket} --access-type ObjectRead  --time-expires 2018-01-16 -on ${versioned_image_name} --name ${versioned_image_name} > ${resp_json}

# Create full url
access_uri=access_uri=`jq -r '.data."access-uri"' < ${resp_json}`
preauth_url="https://objectstorage.${oracle_region}.oraclecloud.com${access_uri}"
echo $preauth_url > ${image_par_dir}/{versioned_image_name}.url

cat ${image_par_dir}/{versioned_image_name}.url
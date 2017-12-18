#!/usr/bin/env bash

set -e

pwd=`pwd`

#Inputs
export TERRAFORM_OUTPUT=${pwd}/terraform-state/metadata
templates_path=${pwd}/light-stemcell-builder/ci/templates
keys=${pwd}/fixture-ssh-keys


#Output
output_dir=${pwd}/director-env
apikey_file_name=ocitest_api_key.pem

key_path=${output_dir}/${apikey_file_name}
cat > ${key_path} <<EOF
${oracle_apikey}
EOF
chmod 600 ${key_path}
# oracle_key_path relative to
# the config file
export oracle_apikey_path="./${apikey_file_name}"

cp -pr ${keys}/* ${output_dir}/

export userPublicKeyPath=${output_dir}/userkeys/id_rsa.pub
erb -T '-' -r json ${templates_path}/create-env-vars.erb >  ${output_dir}/director-env-vars.yml

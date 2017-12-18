#!/bin/sh

set -e

function check_param() {
  local name=$1
  local value=$(eval echo '$'$name)
  if [ "$value" == 'replace-me' ]; then
    echo "environment variable $name must be set"
    exit 1
  fi
}

function writeStemcellManifest() {
  cat > $1  <<MANIFEST
---
name: $2
version: $3
bosh_protocol: '1'
sha1: $4
operating_system: $5
cloud_properties:
   name: $2
   version: "$3"
   image-source-url: $6
MANIFEST

}
function createImageFile() {
  touch $1
}

check_param os
check_param name


pwd=`pwd`

#Inputs
stemcell_version=$( cat stemcell-semver/number | sed 's/\.0$//;s/\.0$//' )
stemcell_name=${name}
image_par_dir="image-par"

imageurl_filepath=`ls -1rt  ${image_par_dir}/*.url  | head -1`
image_src_url=`cat ${imageurl_filepath}`

#Outputs
light_stemcell_dir=${pwd}/light-stemcell

workdir=${light_stemcell_dir}/tmp
mkdir -p $workdir

## Create stemcell tarball structure
createImageFile "$workdir/image"
sha1=`sha1sum $workdir/image | cut -f1 -d" "`
writeStemcellManifest "$workdir/stemcell.MF" ${stemcell_name} ${stemcell_version} ${sha1}  ${os} ${image_src_url}

## Create the tarball
tar_filepath="${light_stemcell_dir}/${stemcell_name}-${stemcell_version}.tgz"
tar -C ${workdir} -zcf ${tar_filepath} image stemcell.MF

echo "Created ${tar_filepath}"

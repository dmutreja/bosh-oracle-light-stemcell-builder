# bosh-oracle-light-stemcell-builder

Repository to build and publish a BOSH light stemcell

#### Building a light stemcell manually on a development machine

 * Create the full stemcell from the bosh-linux-stemcell-builder project. In that repo
 ```
   $ cd ci/docker
   $ export DOCKER_IMAGE=dmutreja/os-image-stemcell-builder
   $ run os-image-stemcell-builder 

 ```
 * Build local OS and the Oracle stemcell inside the container following the instructions in bosh-linux-stemcell-builder
    ```bash
    $ echo $PWD
    /opt/bosh
    $ bundle install --local
    $ mkdir -p $PWD/tmp
    $ bundle exec rake stemcell:build_os_image[ubuntu,trusty,$PWD/tmp/ubuntu_base_image.tgz]
    $ CANDIDATE_BUILD_NUMBER=0004 bundle exec rake stemcell:build_with_local_os_image[oracle,kvm,ubuntu,trusty,$PWD/tmp/ubuntu_base_image.tgz]
    $  cp /mnt/stemcells/oracle/kvm/ubuntu/work/work/root.qcow2 tmp/
    ```
* From the host 
  * Upload the .qcow2 image to a storage bucket and create a PAR for it
  ```
   $ oci os object put -ns cloudfoundry -bn images --name v0004.qcow2  --file tmp/root.qcow2
   ```
   * Fly execute the build-light-stemcell task 
   ```
   $ echo 3445.7 > manual-build/version
   $ echo "https://objectstorage.us-phoenix-1.oraclecloud.com/p/qMODpf4LrFdnGeJ1l5B3UvxT0CVH1o_6psBp56wRb-Q/n/cloudfoundry/b/images/o/v0004.qcow2" > manual-build/candidate-0004-par.url 
   $ os=ubuntu-trusty name=light-oracle-ubuntu-trusty fly -t cpi execute -c ./ci/tasks/build-light-stemcell.yml -i stemcell-semver=manual-build -i image-par=manual-build -o light-stemcell=manual-build -i light-stemcell-builder=.

   ```
  
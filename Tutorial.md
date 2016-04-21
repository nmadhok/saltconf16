### Using majority of VMware cloud-driver's functionality:

1. Install `salt-cloud` packages:
    ```sh
    yum install -y salt-cloud
    ```
2. Install `pyVmomi`:
    ```sh
    pip install pyVmomi==5.5.0-2014.1.1
    ```
3. Configure `/etc/salt/cloud.providers.d/vmware.conf`:
    ```yaml
    vcenter01:
      driver: vmware
      user: 'DOMAIN\user'
      password: 'verybadpass'
      url: 'vcenter01.domain.com'
      protocol: 'https'
      port: 443
    ```
     [`vmware-sdb_setup.sh`](https://raw.githubusercontent.com/nmadhok/saltconf16/master/SAMPLES/vmware-sdb_setup.sh) script can also be used to configure the VMware cloud driver.
4. Test connection using VMware cloud driver:
   ```sh
    salt-cloud -f test_vcenter_connection vcenter01
   ```
   
##### Exiting an ESXi host out of maintenance mode:
```sh
salt-cloud -f exit_maintenance_mode vcenter01 host="host.domain.com" -l debug
```

##### Entering an ESXi host in maintenance mode:
```sh
salt-cloud -f enter_maintenance_mode vcenter01 host="host.domain.com" -l debug
```

##### Disconnecting an ESXi host:
```sh
salt-cloud -f disconnect_host vcenter01 host="host.domain.com" -l debug
```

##### Connecting an ESXi host:
```sh
salt-cloud -f connect_host vcenter01 host="host.domain.com" -l debug
```

##### Removing an ESXi host:
```sh
salt-cloud -f remove_host vcenter01 host="host.domain.com" -l debug
```

##### Creating a datacenter:
```sh
salt-cloud -f create_datacenter vcenter01 name="Test-Datacenter" -l debug
```

##### Creating a cluster:
```sh
salt-cloud -f create_cluster vcenter01 name="Test-Host-Cluster" datacenter="Test-Datacenter" -l debug
```

##### Creating a datastore cluster:
```sh
salt-cloud -f create_datastore_cluster vcenter01 name="Test-Datastore-Cluster" datacenter="Test-Datacenter" -l debug
```

##### Adding an ESXi host to a Cluster:
```sh
salt-cloud -f add_host vcenter01 host="host.domain.com" cluster="Test-Host-Cluster" -l debug
```

##### Adding an ESXi host as a Standalone Host in the datacenter:
```sh
salt-cloud -f add_host vcenter01 host="host.domain.com" datacenter="Test-Datacenter" -l debug
```

### Creating VMs/templates:
1. Create profile `/etc/salt/cloud.profiles.d/profiles.conf`:
    ```yaml
    distro-vcenter01:
      provider: vcenter01
      clonefrom: "mytemplate"
      datacenter: Test-Datacenter
      folder: Development
      cluster: Production
      datastore: Test-Datastore-Cluster
      devices:
        network:
          Network adapter 1:
            name: 10.20.30-123-Test
            switch_type: distributed
      domain: domain.com
      dns_servers:
        - 10.20.30.40
        - 10.20.30.41
      password: "somePassword"
      minion:
        master: salt-master.domain.com
    ```
    * `provider`: Specify the provider to use from `/etc/salt/cloud.providers.d/vmware.conf`  
    * `clonefrom`: Specify the VM/template to clone from. Use `salt-cloud --list-images vcenter01` to list available templates that can be cloned.
    * `datacenter`: Use `salt-cloud --list-locations vcenter01` or `salt-cloud -f list_datacenters vcenter01` to list available datacenters.
    * `folder`: Use `salt-cloud -f list_folders vcenter01` to list available folders.
    * `cluster`: Use `salt-cloud -f list_clusters vcenter01` to list available clusters.
    * `datastore`: Use `salt-cloud -f list_datastore_clusters vcenter01` to list available datastore clusters.
    * `devices`: Use `salt-cloud -f list_networks vcenter01` to list available networks.
    * `domain`: Specify the domain to use for the VM.
    * `dns_servers`: Specify the DNS servers to use for the VM.
    * `password`: Specify the password to use to ssh to the VM.
    * `minion`: Specify the minion configuration for the VM.
2. Use bootstrap script from develop branch:
    ```sh
    salt-cloud --update-bootstrap
    ```
3. Create VMs using profile:
    ```sh
    salt-cloud -p distro-vcenter01 testvm1
    ```
4. Create map file ``/etc/salt/cloud.maps.d/test.map``:
    ```yaml
    distro-vcenter01:
      - testvm1:
          num_cpus: 4
          memory: 8GB
      - testvm2:
          grains:
            role: test
      - testvm3:
          num_cpus: 2
          memory: 4GB
    ```
5. Create VMs using map file:
    ```sh
    salt-cloud -P -m /etc/salt/cloud.maps.d/test.map
    ```

### Destroying VMs/templates:
```sh
salt-cloud -d testvm1 -l debug
```
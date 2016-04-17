#!/bin/bash
#
# This script sets up SDB in salt master configuration and stores credentials used by the VMware cloud
# driver in a sqlite database. It also configures the cloud provider configuration for the VMware cloud
# driver. Salt-master, salt-cloud and salt-minion must be installed on the system to be able to use this
# script.
#
# Author Name:		Nitin Madhok
# Author Email:		nmadhok@clemson.edu
# Date Created:		Sunday, April 17, 2016
# Last Modified:	Sunday, April 17, 2016
#


####################################################################################################
###################################### User defined variables ######################################
####################################################################################################

ID='vcenter01'
USER='DOMAIN\USER'
PASSWORD='passwordForUser'
URL='vcenter01.domain.com'
ESXI_HOST_USER='root'
ESXI_HOST_PASSWORD='passwordForESXiHostUser'
SDB_PATH='/etc/salt/cloud.providers.d/vmware.sqlite'
VMWARE_CLOUD_CONFIG_FILE='/etc/salt/cloud.providers.d/vmware.conf'
VMWARE_SDB_CONFIG_FILE='/etc/salt/master.d/vmware_sdb.conf'


####################################################################################################
######################################## Main Script Begins ########################################
####################################################################################################

cat >$VMWARE_SDB_CONFIG_FILE <<EOL
${ID}:
  driver: sqlite3
  database: ${SDB_PATH}
  table: ${ID}
  create_table: True
EOL
master_restart=$(salt-call service.restart salt-master)
sleep 1
salt-run sdb.set "sdb://$ID/user" "$USER" &
salt-run sdb.set "sdb://$ID/password" "$PASSWORD" &
salt-run sdb.set "sdb://$ID/url" "$URL" &
salt-run sdb.set "sdb://$ID/esxi_host_user" "$ESXI_HOST_USER" &
salt-run sdb.set "sdb://$ID/esxi_host_password" "$ESXI_HOST_PASSWORD" &
wait
chmod 600 $SDB_PATH
cat >$VMWARE_CLOUD_CONFIG_FILE <<EOL
${ID}:
  driver: vmware
  user: 'sdb://$ID/user'
  password: 'sdb://$ID/password'
  url: 'sdb://$ID/url'
  esxi_host_user: 'sdb://$ID/esxi_host_user'
  esxi_host_password: 'sdb://$ID/esxi_host_password'
EOL
salt-cloud -f test_vcenter_connection $ID
exit 0

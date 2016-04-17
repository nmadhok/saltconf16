#!/bin/bash
#
# This script sets up SDB in salt master configuration and stores credentials used by the VMware cloud
# driver. Salt-master, salt-cloud and salt-minion must be installed and configured on the system to be
# able to use this script.
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
DB_FILE_PATH='/etc/salt/cloud.providers.d/vmware.sqlite'


####################################################################################################
######################################## Main Script Begins ########################################
####################################################################################################

cat >/etc/salt/master.d/vmware_sdb.conf <<EOL
${ID}:
  driver: sqlite3
  database: ${DB_FILE_PATH}
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
chmod 600 $DB_FILE_PATH
exit 0

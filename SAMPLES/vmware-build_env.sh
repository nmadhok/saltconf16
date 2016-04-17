#!/bin/bash
#
# This script uses salt-cloud VMware cloud driver to create a Datacenter, create a Host Cluster, add
# specified ESXi hosts either to the Host Cluster or add them as Standalone Hosts to the Datacenter.
# salt-cloud must be installed and VMware cloud provider must be configured on the system to be able
# to use this script.
#
# Author Name:		Nitin Madhok
# Author Email:		nmadhok@clemson.edu
# Date Created:		Sunday, April 17, 2016
# Last Modified:	Sunday, April 17, 2016
#


####################################################################################################
###################################### User defined variables ######################################
####################################################################################################

VCENTER_NAME="vcenter01"
DATACENTER_NAME="Test-Datacenter"
CLUSTER_NAME="Test-Host-Cluster"
CLUSTER_HOST_NAMES=(host001.domain.com host002.domain.com)
STANDALONE_HOST_NAMES=(host002.domain.com host003.domain.com)


####################################################################################################
######################################## Main Script Begins ########################################
####################################################################################################

salt-cloud -f create_datacenter $VCENTER_NAME name="$DATACENTER_NAME"
salt-cloud -f create_cluster $VCENTER_NAME name="$CLUSTER_NAME" datacenter="$DATACENTER_NAME"
for CLUSTER_HOST_NAME in ${CLUSTER_HOST_NAMES[@]}; do
    salt-cloud -f add_host $VCENTER_NAME host="$CLUSTER_HOST_NAME" cluster="$CLUSTER_NAME"
done
for STANDALONE_HOST_NAME in ${STANDALONE_HOST_NAMES[@]}; do
    salt-cloud -f add_host $VCENTER_NAME host="$STANDALONE_HOST_NAME" datacenter="$DATACENTER_NAME"
done
exit 0

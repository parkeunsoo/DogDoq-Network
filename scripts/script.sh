#!/bin/bash

echo
echo " ____    _____      _      ____    _____ "
echo "/ ___|  |_   _|    / \    |  _ \  |_   _|"
echo "\___ \    | |     / _ \   | |_) |   | |  "
echo " ___) |   | |    / ___ \  |  _ <    | |  "
echo "|____/    |_|   /_/   \_\ |_| \_\   |_|  "
echo
echo "Build your first network (BYFN) end-to-end test"
echo
CHANNEL_NAME1="$1"
CHANNEL_NAME2="$2"
CHANNEL_NAME3="$3"
CHANNEL_NAME4="$4"
DELAY="$5"
LANGUAGE="$6"
TIMEOUT="$7"
VERBOSE="$8"
: ${CHANNEL_NAME1:="channel1"}
: ${CHANNEL_NAME2:="channel2"}
: ${CHANNEL_NAME3:="channel3"}
: ${CHANNEL_NAME4:="channel4"}
: ${DELAY:="3"}
: ${LANGUAGE:="golang"}
: ${TIMEOUT:="10"}
: ${VERBOSE:="false"}
LANGUAGE=`echo "$LANGUAGE" | tr [:upper:] [:lower:]`
COUNTER=1
MAX_RETRY=10
CC_SRC_PATH4="github.com/chaincode/dogdoq/channel4/"
CC_SRC_PATH3="github.com/chaincode/dogdoq/channel3/"
CC_SRC_PATH2="github.com/chaincode/dogdoq/channel2/"
CC_SRC_PATH1="github.com/chaincode/dogdoq/channel1/"
if [ "$LANGUAGE" = "node" ]; then
	CC_SRC_PATH="/opt/gopath/src/github.com/chaincode/fabcar/node/"
fi

if [ "$LANGUAGE" = "java" ]; then
	CC_SRC_PATH="/opt/gopath/src/github.com/chaincode/fabcar/java/"
fi
echo $CC_SRC_PATH
echo "Channel name : "$CHANNEL_NAME1 $CHANNEL_NAME2 $CHANNEL_NAME3 $CHANNEL_NAME4

# import utils
. scripts/utils.sh

createChannel() {
	setGlobals 0 1

	if [ -z "$CORE_PEER_TLS_ENABLED" -o "$CORE_PEER_TLS_ENABLED" = "false" ]; then
                set -x
		peer channel create -o orderer.example.com:7050 -c $CHANNEL_NAME1 -f ./channel-artifacts/channel1.tx >&log.txt
		res=$?
                set +x
	else
				set -x
		peer channel create -o orderer.example.com:7050 -c $CHANNEL_NAME1 -f ./channel-artifacts/channel1.tx --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA >&log.txt
		res=$?
				set +x
	fi
	cat log.txt
	verifyResult $res "Channel creation failed"
	echo "===================== Channel '$CHANNEL_NAME1' created ===================== "
	echo

	if [ -z "$CORE_PEER_TLS_ENABLED" -o "$CORE_PEER_TLS_ENABLED" = "false" ]; then
                set -x
		peer channel create -o orderer.example.com:7050 -c $CHANNEL_NAME2 -f ./channel-artifacts/channel2.tx >&log.txt
		res=$?
                set +x
	else
				set -x
		peer channel create -o orderer.example.com:7050 -c $CHANNEL_NAME2 -f ./channel-artifacts/channel2.tx --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA >&log.txt
		res=$?
				set +x
	fi
	cat log.txt
	verifyResult $res "Channel creation failed"
	echo "===================== Channel '$CHANNEL_NAME2' created ===================== "
	echo

	if [ -z "$CORE_PEER_TLS_ENABLED" -o "$CORE_PEER_TLS_ENABLED" = "false" ]; then
                set -x
		peer channel create -o orderer.example.com:7050 -c $CHANNEL_NAME3 -f ./channel-artifacts/channel3.tx >&log.txt
		res=$?
                set +x
	else
				set -x
		peer channel create -o orderer.example.com:7050 -c $CHANNEL_NAME3 -f ./channel-artifacts/channel3.tx --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA >&log.txt
		res=$?
				set +x
	fi
	cat log.txt
	verifyResult $res "Channel creation failed"
	echo "===================== Channel '$CHANNEL_NAME3' created ===================== "
	echo

	if [ -z "$CORE_PEER_TLS_ENABLED" -o "$CORE_PEER_TLS_ENABLED" = "false" ]; then
                set -x
		peer channel create -o orderer.example.com:7050 -c $CHANNEL_NAME4 -f ./channel-artifacts/channel4.tx >&log.txt
		res=$?
                set +x
	else
				set -x
		peer channel create -o orderer.example.com:7050 -c $CHANNEL_NAME4 -f ./channel-artifacts/channel4.tx --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA >&log.txt
		res=$?
				set +x
	fi
	cat log.txt
	verifyResult $res "Channel creation failed"
	echo "===================== Channel '$CHANNEL_NAME4' created ===================== "
	echo
}

joinChannel () {
		joinChannelWithRetry 0 1
		joinChannelWithRetry 0 2
		joinChannelWithRetry 0 3
		joinChannelWithRetry 0 4
		echo "a"
	
}

## Create channel
echo "Creating channel..."
createChannel

## Join all the peers to the channel
echo "Having all peers join the channel..."
joinChannel

## Set the anchor peers for each org in the channel
echo "Updating anchor peers for org1..."
updateAnchorPeers 0 1
echo "Updating anchor peers for org2..."
updateAnchorPeers 0 2
echo "Updating anchor peers for org3..."
updateAnchorPeers 0 3
echo "Updating anchor peers for org4..."
updateAnchorPeers 0 4

## Install chaincode on peer0.org1 and peer0.org2
echo "Installing chaincode on peer0.org1..."
installChaincode 0 1
echo "Install chaincode on peer0.org2..."
installChaincode 0 2
echo "Installing chaincode on peer0.org3..."
installChaincode 0 3
echo "Install chaincode on peer0.org4..."
installChaincode 0 4
# Instantiate chaincode on peer0.org1
echo "Instantiating chaincode on peer0.org1..."
 instantiateChaincode 0 1 3
# Instantiate chaincode on peer0.org2
echo "Instantiating chaincode on peer0.org2..."
 instantiateChaincode 0 2 1
# Instantiate chaincode on peer0.org3
echo "Instantiating chaincode on peer0.org3..."
 instantiateChaincode 0 3 2
# Instantiate chaincode on peer0.org3
echo "Instantiating chaincode on peer0.org4..."
 instantiateChaincode 0 4 4
 

echo
echo "========= All GOOD, BYFN execution completed =========== "
echo

echo
echo " _____   _   _   ____   "
echo "| ____| | \ | | |  _ \  "
echo "|  _|   |  \| | | | | | "
echo "| |___  | |\  | | |_| | "
echo "|_____| |_| \_| |____/  "
echo

exit 0

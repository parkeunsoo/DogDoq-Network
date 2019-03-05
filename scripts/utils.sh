#
# Copyright IBM Corp All Rights Reserved
#
# SPDX-License-Identifier: Apache-2.0
#

# This is a collection of bash functions used by different scripts

ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
PEER0_ORG1_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
PEER0_ORG2_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
PEER0_ORG3_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org3.example.com/peers/peer0.org3.example.com/tls/ca.crt
PEER0_ORG4_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org4.example.com/peers/peer0.org4.example.com/tls/ca.crt

# verify the result of the end-to-end test
verifyResult() {
  if [ $1 -ne 0 ]; then
    echo "!!!!!!!!!!!!!!! "$2" !!!!!!!!!!!!!!!!"
    echo "========= ERROR !!! FAILED to execute End-2-End Scenario ==========="
    echo
    exit 1
  fi
}

# Set OrdererOrg.Admin globals
setOrdererGlobals() {
  CORE_PEER_LOCALMSPID="OrdererMSP"
  CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
  CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/users/Admin@example.com/msp
}

setGlobals() {
  PEER=$1
  ORG=$2
  if [ $ORG -eq 1 ]; then
    CORE_PEER_LOCALMSPID="Org1MSP"
    CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_ORG1_CA
    CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
    CORE_PEER_ADDRESS=peer0.org1.example.com:7051
    
  elif [ $ORG -eq 2 ]; then
    CORE_PEER_LOCALMSPID="Org2MSP"
    CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_ORG2_CA
    CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
    CORE_PEER_ADDRESS=peer0.org2.example.com:7051
   
  elif [ $ORG -eq 3 ]; then
    CORE_PEER_LOCALMSPID="Org3MSP"
    CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_ORG3_CA
    CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org3.example.com/users/Admin@org3.example.com/msp
    CORE_PEER_ADDRESS=peer0.org3.example.com:7051

  elif [ $ORG -eq 4 ]; then
    CORE_PEER_LOCALMSPID="Org4MSP"
    CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_ORG4_CA
    CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org4.example.com/users/Admin@org4.example.com/msp
    CORE_PEER_ADDRESS=peer0.org4.example.com:7051 
  else
    echo "================== ERROR !!! ORG Unknown =================="
  fi

  if [ "$VERBOSE" == "true" ]; then
    env | grep CORE
  fi
}

updateAnchorPeers() {
  PEER=$1
  ORG=$2
  setGlobals $PEER $ORG
  if [ $ORG -eq 1 ]; then
     if [ -z "$CORE_PEER_TLS_ENABLED" -o "$CORE_PEER_TLS_ENABLED" = "false" ]; then
        set -x
        peer channel update -o orderer.example.com:7050 -c $CHANNEL_NAME1 -f ./channel-artifacts/CH1Org1MSPanchors.tx >&log.txt
        res=$?
        set +x
        set -x
        peer channel update -o orderer.example.com:7050 -c $CHANNEL_NAME2 -f ./channel-artifacts/CH2Org1MSPanchors.tx >&log.txt
        res=$?
        set +x
        set -x
        peer channel update -o orderer.example.com:7050 -c $CHANNEL_NAME3 -f ./channel-artifacts/CH3Org1MSPanchorsanchors.tx >&log.txt
        res=$?
        set +x
         set -x
        peer channel update -o orderer.example.com:7050 -c $CHANNEL_NAME4 -f ./channel-artifacts/CH4Org1MSPanchorsanchors.tx >&log.txt
        res=$?
        set +x
     else
        set -x
        peer channel update -o orderer.example.com:7050 -c $CHANNEL_NAME1 -f ./channel-artifacts/CH1Org1MSPanchors.tx --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA >&log.txt
        res=$?
        set +x
        set -x
        peer channel update -o orderer.example.com:7050 -c $CHANNEL_NAME2 -f ./channel-artifacts/CH2Org1MSPanchors.tx --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA >&log.txt
        res=$?
        set +x
        set -x
        peer channel update -o orderer.example.com:7050 -c $CHANNEL_NAME3 -f ./channel-artifacts/CH3Org1MSPanchors.tx --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA >&log.txt
        res=$?
        set +x
         set -x
        peer channel update -o orderer.example.com:7050 -c $CHANNEL_NAME4 -f ./channel-artifacts/CH4Org1MSPanchors.tx --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA >&log.txt
        res=$?
        set +x
     fi
  cat log.txt
  verifyResult $res "Anchor1 peer update failed"
  echo "===================== Anchor peers updated for org '$CORE_PEER_LOCALMSPID' on channel '$CHANNEL_NAME1''$CHANNEL_NAME2''$CHANNEL_NAME3''$CHANNEL_NAME4' ===================== "
  sleep $DELAY
  echo

  elif [ $ORG -eq 2 ]; then
     if [ -z "$CORE_PEER_TLS_ENABLED" -o "$CORE_PEER_TLS_ENABLED" = "false" ]; then
        set -x
        peer channel update -o orderer.example.com:7050 -c $CHANNEL_NAME1 -f ./channel-artifacts/CH1Org2MSPanchors.tx >&log.txt
        res=$?
        set +x
        set -x
        peer channel update -o orderer.example.com:7050 -c $CHANNEL_NAME3 -f ./channel-artifacts/CH3Org2MSPanchors.tx >&log.txt
        res=$?
        set +x
    
     else
        set -x
        peer channel update -o orderer.example.com:7050 -c $CHANNEL_NAME1 -f ./channel-artifacts/CH1Org2MSPanchors.tx --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA >&log.txt
        res=$?
        set +x
        set -x
        peer channel update -o orderer.example.com:7050 -c $CHANNEL_NAME3 -f ./channel-artifacts/CH3Org2MSPanchors.tx --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA >&log.txt
        res=$?
        set +x
        
     fi
  cat log.txt
  verifyResult $res "Anchor2 peer update failed"
  echo "===================== Anchor peers updated for org '$CORE_PEER_LOCALMSPID' on channel '$CHANNEL_NAME1''$CHANNEL_NAME3' ===================== "
  sleep $DELAY
  echo

  elif [ $ORG -eq 3 ]; then
     if [ -z "$CORE_PEER_TLS_ENABLED" -o "$CORE_PEER_TLS_ENABLED" = "false" ]; then
        
        set -x
        peer channel update -o orderer.example.com:7050 -c $CHANNEL_NAME2 -f ./channel-artifacts/CH2Org3MSPanchors.tx >&log.txt
        res=$?
        set +x
        set -x
        peer channel update -o orderer.example.com:7050 -c $CHANNEL_NAME3 -f ./channel-artifacts/CH3Org3MSPanchorsanchors.tx >&log.txt
        res=$?
        set +x
     else
        
        set -x
        peer channel update -o orderer.example.com:7050 -c $CHANNEL_NAME2 -f ./channel-artifacts/CH2Org3MSPanchors.tx --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA >&log.txt
        res=$?
        set +x
        set -x
        peer channel update -o orderer.example.com:7050 -c $CHANNEL_NAME3 -f ./channel-artifacts/CH3Org3MSPanchors.tx --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA >&log.txt
        res=$?
       set +x
     fi
  cat log.txt
  verifyResult $res "Anchor3 peer update failed"
  echo "===================== Anchor peers updated for org '$CORE_PEER_LOCALMSPID' on channel '$CHANNEL_NAME2''$CHANNEL_NAME3' ===================== "
  sleep $DELAY
  echo

  elif [ $ORG -eq 4 ]; then
     if [ -z "$CORE_PEER_TLS_ENABLED" -o "$CORE_PEER_TLS_ENABLED" = "false" ]; then
        set -x
        peer channel update -o orderer.example.com:7050 -c $CHANNEL_NAME3 -f ./channel-artifacts/CH3Org4MSPanchorsanchors.tx >&log.txt
        res=$?
        set +x
        set -x
        peer channel update -o orderer.example.com:7050 -c $CHANNEL_NAME4 -f ./channel-artifacts/CH4Org4MSPanchorsanchors.tx >&log.txt
        res=$?
        set +x
     else
        set -x
        peer channel update -o orderer.example.com:7050 -c $CHANNEL_NAME3 -f ./channel-artifacts/CH3Org4MSPanchors.tx --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA >&log.txt
        res=$?
        set +x
        set -x
        peer channel update -o orderer.example.com:7050 -c $CHANNEL_NAME4 -f ./channel-artifacts/CH4Org4MSPanchors.tx --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA >&log.txt
        res=$?
        set +x
     fi
  cat log.txt
  verifyResult $res "Anchor4 peer update failed"
  echo "===================== Anchor peers updated for org '$CORE_PEER_LOCALMSPID' on channel '$CHANNEL_NAME3''$CHANNEL_NAME4' ===================== "
  sleep $DELAY
  echo
  fi
}

## Sometimes Join takes time hence RETRY at least 5 times
joinChannelWithRetry() {
  PEER=$1
  ORG=$2
  setGlobals $PEER $ORG
  if [ $ORG -eq 1 ]; then
     set -x
     peer channel join -b $CHANNEL_NAME1.block >&log.txt
     res=$?
     echo "===================== peer${peer}.org${org} joined channel '$CHANNEL_NAME1' ===================== "
     set +x
     set -x
     peer channel join -b $CHANNEL_NAME2.block >&log.txt
     res=$?
     echo "===================== peer${peer}.org${org} joined channel '$CHANNEL_NAME2' ===================== "
     set +x
     set -x
     peer channel join -b $CHANNEL_NAME3.block >&log.txt
     res=$?
     echo "===================== peer${peer}.org${org} joined channel '$CHANNEL_NAME3' ===================== "
     set +x
     set -x
     peer channel join -b $CHANNEL_NAME4.block >&log.txt
     res=$?
     echo "===================== peer${peer}.org${org} joined channel '$CHANNEL_NAME4' ===================== "
     set +x
  elif [ $ORG -eq 2 ]; then
     set -x
     peer channel join -b $CHANNEL_NAME1.block >&log.txt
     res=$?
     echo "===================== peer${peer}.org${org} joined channel '$CHANNEL_NAME1' ===================== "
     set +x
     set -x
     peer channel join -b $CHANNEL_NAME3.block >&log.txt
     res=$?
     echo "===================== peer${peer}.org${org} joined channel '$CHANNEL_NAME3' ===================== "
     set +x
  elif [ $ORG -eq 3 ]; then
     set -x
     peer channel join -b $CHANNEL_NAME2.block >&log.txt
     res=$?
     echo "===================== peer${peer}.org${org} joined channel '$CHANNEL_NAME2' ===================== "
     set +x
     set -x
     peer channel join -b $CHANNEL_NAME3.block >&log.txt
     res=$?
     echo "===================== peer${peer}.org${org} joined channel '$CHANNEL_NAME3' ===================== "
     set +x
  elif [ $ORG -eq 4 ]; then
     set -x
     peer channel join -b $CHANNEL_NAME3.block >&log.txt
     res=$?
     echo "===================== peer${peer}.org${org} joined channel '$CHANNEL_NAME3' ===================== "
     set +x
     set -x
     peer channel join -b $CHANNEL_NAME4.block >&log.txt
     res=$?
     echo "===================== peer${peer}.org${org} joined channel '$CHANNEL_NAME4' ===================== "
     set +x
  fi
  cat log.txt
  if [ $res -ne 0 -a $COUNTER -lt $MAX_RETRY ]; then
    COUNTER=$(expr $COUNTER + 1)
    echo "peer${PEER}.org${ORG} failed to join the channel, Retry after $DELAY seconds"
    sleep $DELAY
    joinChannelWithRetry $PEER $ORG
  else
    COUNTER=1
  fi
  verifyResult $res "After $MAX_RETRY attempts, peer${PEER}.org${ORG} has failed to join channel '$CHANNEL_NAME1' "
}

installChaincode() {
  PEER=$1
  ORG=$2
  setGlobals $PEER $ORG
  echo $CORE_PEER_LOCALMSPID
  echo $CORE_PEER_TLS_ROOTCERT_FILE
  echo $CORE_PEER_MSPCONFIGPATH
  VERSION=${3:-2.0}
  set -x
  if [ $ORG -eq 1 ]; then
     peer chaincode install -n channel1 -v $VERSION -l "golang" -p $CC_SRC_PATH1 >&log.txt
     peer chaincode install -n channel2 -v $VERSION -l "golang" -p $CC_SRC_PATH2 >&log.txt
     peer chaincode install -n channel3 -v $VERSION -l "golang" -p $CC_SRC_PATH3 >&log.txt
     peer chaincode install -n channel4 -v $VERSION -l "golang" -p $CC_SRC_PATH4 >&log.txt
  elif [ $ORG -eq 2 ]; then
     peer chaincode install -n channel1 -v $VERSION -l "golang" -p $CC_SRC_PATH1 >&log.txt
     peer chaincode install -n channel3 -v $VERSION -l "golang" -p $CC_SRC_PATH3 >&log.txt
  elif [ $ORG -eq 3 ]; then
     peer chaincode install -n channel2 -v $VERSION -l "golang" -p $CC_SRC_PATH2 >&log.txt
     peer chaincode install -n channel3 -v $VERSION -l "golang" -p $CC_SRC_PATH3 >&log.txt
  elif [ $ORG -eq 4 ]; then
     peer chaincode install -n channel3 -v $VERSION -l "golang" -p $CC_SRC_PATH3 >&log.txt
     peer chaincode install -n channel4 -v $VERSION -l "golang" -p $CC_SRC_PATH4 >&log.txt
  fi
  set +x
  cat log.txt
  echo "===================== Chaincode is installed on peer${PEER}.org${ORG} ===================== "
  echo
}

instantiateChaincode() {
  PEER=$1
  ORG=$2
  setGlobals $PEER $ORG
  CHA=$3
  VERSION=${4:-2.0}
  # while 'peer chaincode' command can get the orderer endpoint from the peer
  # (if join was successful), let's supply it directly as we know it using
  # the "-o" option
  if [ $CHA -eq 1 ]; then
     if [ -z "$CORE_PEER_TLS_ENABLED" -o "$CORE_PEER_TLS_ENABLED" = "false" ]; then
       set -x
       peer chaincode instantiate -o orderer.example.com:7050 -C $CHANNEL_NAME1 -n channel1 -l ${LANGUAGE} -v ${VERSION} -c '{"Args":[""]}' -P "AND ('Org1MSP.peer','Org2MSP.peer')" >&log.txt
       res=$?
       set +x
     else
       set -x
       peer chaincode instantiate -o orderer.example.com:7050 --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA -C $CHANNEL_NAME1 -n channel1 -l ${LANGUAGE} -v ${VERSION} -c  '{"Args":[""]}' -P "OR ('Org1MSP.peer','Org2MSP.peer')" >&log.txt
       res=$?
       set +x
     fi
     cat log.txt
     verifyResult $res "Chaincode instantiation on peer${PEER}.org${ORG} on channel '$CHANNEL_NAME1' failed"
     echo "===================== Chaincode is instantiated on peer${PEER}.org${ORG} on channel '$CHANNEL_NAME1' ===================== "
     echo
  elif [ $CHA -eq 2 ]; then
     if [ -z "$CORE_PEER_TLS_ENABLED" -o "$CORE_PEER_TLS_ENABLED" = "false" ]; then
       set -x
       peer chaincode instantiate -o orderer.example.com:7050 -C $CHANNEL_NAME2 -n channel2 -l ${LANGUAGE} -v ${VERSION} -c '{"Args":[""]}' -P "AND ('Org1MSP.peer','Org3MSP.peer')" >&log.txt
       res=$?
       set +x
     else
       set -x
       peer chaincode instantiate -o orderer.example.com:7050 --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA -C $CHANNEL_NAME2 -n channel2 -l ${LANGUAGE} -v ${VERSION} -c '{"Args":[""]}' -P "OR ('Org1MSP.peer','Org3MSP.peer')" >&log.txt
       res=$?
       set +x
     fi
     cat log.txt
     verifyResult $res "Chaincode instantiation on peer${PEER}.org${ORG} on channel '$CHANNEL_NAME2' failed"
     echo "===================== Chaincode is instantiated on peer${PEER}.org${ORG} on channel '$CHANNEL_NAME2' ===================== "
     echo
  elif [ $CHA -eq 3 ]; then
     if [ -z "$CORE_PEER_TLS_ENABLED" -o "$CORE_PEER_TLS_ENABLED" = "false" ]; then
       set -x
       peer chaincode instantiate -o orderer.example.com:7050 -C $CHANNEL_NAME3 -n channel3 -l ${LANGUAGE} -v ${VERSION} -c '{"Args":[""]}' -P "AND ('Org1MSP.peer','Org2MSP.peer','Org3MSP.peer','Org4MSP.peer')" >&log.txt
       res=$?
       set +x
     else
       set -x
       peer chaincode instantiate -o orderer.example.com:7050 --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA -C $CHANNEL_NAME3 -n channel3 -l ${LANGUAGE} -v ${VERSION} -c '{"Args":[""]}' -P "OR ('Org1MSP.peer','Org2MSP.peer','Org3MSP.peer','Org4MSP.peer')" >&log.txt
       res=$?
       set +x
     fi
     cat log.txt
     verifyResult $res "Chaincode instantiation on peer${PEER}.org${ORG} on channel '$CHANNEL_NAME4' failed"
     echo "===================== Chaincode is instantiated on peer${PEER}.org${ORG} on channel '$CHANNEL_NAME4' ===================== "
     echo
  elif [ $CHA -eq 4 ]; then
     if [ -z "$CORE_PEER_TLS_ENABLED" -o "$CORE_PEER_TLS_ENABLED" = "false" ]; then
       set -x
       peer chaincode instantiate -o orderer.example.com:7050 -C $CHANNEL_NAME4 -n channel4 -l ${LANGUAGE} -v ${VERSION} -c '{"Args":[""]}' -P "AND ('Org1MSP.peer','Org4MSP.peer')" >&log.txt
       res=$?
       set +x
     else
       set -x
       peer chaincode instantiate -o orderer.example.com:7050 --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA -C $CHANNEL_NAME4 -n channel4 -l ${LANGUAGE} -v ${VERSION} -c '{"Args":[""]}' -P "OR ('Org1MSP.peer','Org4MSP.peer')" >&log.txt
       res=$?
       set +x
     fi
     cat log.txt
     verifyResult $res "Chaincode instantiation on peer${PEER}.org${ORG} on channel '$CHANNEL_NAME4' failed"
     echo "===================== Chaincode is instantiated on peer${PEER}.org${ORG} on channel '$CHANNEL_NAME4' ===================== "
     echo
  fi
}

upgradeChaincode() {
  PEER=$1
  ORG=$2
  setGlobals $PEER $ORG

  set -x
  peer chaincode upgrade -o orderer.example.com:7050 --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA -C $CHANNEL_NAME -n fabcar -v 2.0 -c '{"Args":["init","a","90","b","210"]}' -P "AND ('Org1MSP.peer','Org2MSP.peer','Org3MSP.peer')"
  res=$?
  set +x
  cat log.txt
  verifyResult $res "Chaincode upgrade on peer${PEER}.org${ORG} has failed"
  echo "===================== Chaincode is upgraded on peer${PEER}.org${ORG} on channel '$CHANNEL_NAME' ===================== "
  echo
}

# chaincodeQuery() {
#   PEER=$1
#   ORG=$2
#   setGlobals $PEER $ORG
#   EXPECTED_RESULT=$3
#   echo "===================== Querying on peer${PEER}.org${ORG} on channel '$CHANNEL_NAME1'... ===================== "
#   local rc=1
#   local starttime=$(date +%s)

#   # continue to poll
#   # we either get a successful response, or reach TIMEOUT
#   while
#     test "$(($(date +%s) - starttime))" -lt "$TIMEOUT" -a $rc -ne 0
#   do
#     sleep $DELAY
#     echo "Attempting to Query peer${PEER}.org${ORG} ...$(($(date +%s) - starttime)) secs"
#     set -x
#     peer chaincode query -C $CHANNEL_NAME1 -n fabcar -c '{"Args":["query","a"]}' >&log.txt
#     res=$?
#     set +x
#     test $res -eq 0 && VALUE=$(cat log.txt | awk '/Query Result/ {print $NF}')
#     test "$VALUE" = "$EXPECTED_RESULT" && let rc=0
#     # removed the string "Query Result" from peer chaincode query command
#     # result. as a result, have to support both options until the change
#     # is merged.
#     test $rc -ne 0 && VALUE=$(cat log.txt | egrep '^[0-9]+$')
#     test "$VALUE" = "$EXPECTED_RESULT" && let rc=0
#   done
#   echo
#   cat log.txt
#   if test $rc -eq 0; then
#     echo "===================== Query successful on peer${PEER}.org${ORG} on channel '$CHANNEL_NAME1' ===================== "
#   else
#     echo "!!!!!!!!!!!!!!! Query result on peer${PEER}.org${ORG} is INVALID !!!!!!!!!!!!!!!!"
#     echo "================== ERROR !!! FAILED to execute End-2-End Scenario =================="
#     echo
#     exit 1
#   fi
# }

# fetchChannelConfig <channel_id> <output_json>
# Writes the current channel config for a given channel to a JSON file
fetchChannelConfig() {
  CHANNEL=$1
  OUTPUT=$2

  setOrdererGlobals

  echo "Fetching the most recent configuration block for the channel"
  if [ -z "$CORE_PEER_TLS_ENABLED" -o "$CORE_PEER_TLS_ENABLED" = "false" ]; then
    set -x
    peer channel fetch config config_block.pb -o orderer.example.com:7050 -c $CHANNEL --cafile $ORDERER_CA
    set +x
  else
    set -x
    peer channel fetch config config_block.pb -o orderer.example.com:7050 -c $CHANNEL --tls --cafile $ORDERER_CA
    set +x
  fi

  echo "Decoding config block to JSON and isolating config to ${OUTPUT}"
  set -x
  configtxlator proto_decode --input config_block.pb --type common.Block | jq .data.data[0].payload.data.config >"${OUTPUT}"
  set +x
}

# signConfigtxAsPeerOrg <org> <configtx.pb>
# Set the peerOrg admin of an org and signing the config update
signConfigtxAsPeerOrg() {
  PEERORG=$1
  TX=$2
  setGlobals 0 $PEERORG
  set -x
  peer channel signconfigtx -f "${TX}"
  set +x
}

# createConfigUpdate <channel_id> <original_config.json> <modified_config.json> <output.pb>
# Takes an original and modified config, and produces the config update tx
# which transitions between the two
createConfigUpdate() {
  CHANNEL=$1
  ORIGINAL=$2
  MODIFIED=$3
  OUTPUT=$4

  set -x
  configtxlator proto_encode --input "${ORIGINAL}" --type common.Config >original_config.pb
  configtxlator proto_encode --input "${MODIFIED}" --type common.Config >modified_config.pb
  configtxlator compute_update --channel_id "${CHANNEL}" --original original_config.pb --updated modified_config.pb >config_update.pb
  configtxlator proto_decode --input config_update.pb --type common.ConfigUpdate >config_update.json
  echo '{"payload":{"header":{"channel_header":{"channel_id":"'$CHANNEL'", "type":2}},"data":{"config_update":'$(cat config_update.json)'}}}' | jq . >config_update_in_envelope.json
  configtxlator proto_encode --input config_update_in_envelope.json --type common.Envelope >"${OUTPUT}"
  set +x
}

# parsePeerConnectionParameters $@
# Helper function that takes the parameters from a chaincode operation
# (e.g. invoke, query, instantiate) and checks for an even number of
# peers and associated org, then sets $PEER_CONN_PARMS and $PEERS
parsePeerConnectionParameters() {
  # check for uneven number of peer and org parameters
  if [ $(($# % 2)) -ne 0 ]; then
    exit 1
  fi

  PEER_CONN_PARMS=""
  PEERS=""
  while [ "$#" -gt 0 ]; do
    PEER="peer$1.org$2"
    PEERS="$PEERS $PEER"
    PEER_CONN_PARMS="$PEER_CONN_PARMS --peerAddresses $PEER.example.com:7051"
    if [ -z "$CORE_PEER_TLS_ENABLED" -o "$CORE_PEER_TLS_ENABLED" = "true" ]; then
      TLSINFO=$(eval echo "--tlsRootCertFiles \$PEER$1_ORG$2_CA")
      PEER_CONN_PARMS="$PEER_CONN_PARMS $TLSINFO"
    fi
    # shift by two to get the next pair of peer/org parameters
    shift
    shift
  done
  # remove leading space for output
  PEERS="$(echo -e "$PEERS" | sed -e 's/^[[:space:]]*//')"
}

# chaincodeInvoke <peer> <org> ...
# Accepts as many peer/org pairs as desired and requests endorsement from each
chaincodeInvoke() {
  parsePeerConnectionParameters $@
  res=$?
  verifyResult $res "Invoke transaction failed on channel '$CHANNEL_NAME3' due to uneven number of peer and org parameters "
  setGlobals 0 4
  echo "###############"
  echo $PEER_CONN_PARMS
  echo "###############"
  echo $CORE_PEER_LOCALMSPID
  echo $CORE_PEER_TLS_ROOTCERT_FILE
  echo $CORE_PEER_MSPCONFIGPATH
  echo "###############"
  # while 'peer chaincode' command can get the orderer endpoint from the
  # peer (if join was successful), let's supply it directly as we know
  # it using the "-o" option
  if [ -z "$CORE_PEER_TLS_ENABLED" -o "$CORE_PEER_TLS_ENABLED" = "false" ]; then
    set -x
    peer chaincode invoke -o orderer.example.com:7050 -C $CHANNEL_NAME3 -n channel3 $PEER_CONN_PARMS -c '{"function":"initLedger","Args":[""]}' >&log.txt
    res=$?
    set +x
  else
    set -x
    peer chaincode invoke -o orderer.example.com:7050 --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA -C $CHANNEL_NAME3 -n channel3 $PEER_CONN_PARMS -c '{"function":"initLedger","Args":[""]}' >&log.txt
    res=$?
    set +x
    
  fi
  cat log.txt
  verifyResult $res "Invoke execution on $PEERS failed "
  echo "===================== Invoke transaction successful on $PEERS on channel '$CHANNEL_NAME3' ===================== "
  echo
}
# chaincodeQuery() {
#   parsePeerConnectionParameters $@
#   res=$?
#   verifyResult $res "Invoke transaction failed on channel '$CHANNEL_NAME3' due to uneven number of peer and org parameters "
#   setGlobals 0 4
  
#   # while 'peer chaincode' command can get the orderer endpoint from the
#   # peer (if join was successful), let's supply it directly as we know
#   # it using the "-o" option
#   if [ -z "$CORE_PEER_TLS_ENABLED" -o "$CORE_PEER_TLS_ENABLED" = "false" ]; then
#     set -x
#     peer chaincode invoke -o orderer.example.com:7050 -C $CHANNEL_NAME3 -n channel3 $PEER_CONN_PARMS -c '{"function":"queryAllCars","Args":[""]}' >&log.txt
#     res=$?
#     set +x
#   else
#     set -x
#     peer chaincode invoke -o orderer.example.com:7050 --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA -C $CHANNEL_NAME3 -n channel3 $PEER_CONN_PARMS -c '{"function":"queryAllCars","Args":[""]}' >&log.txt
#     res=$?
#     set +x
    
#   fi
#   cat log.txt
#   verifyResult $res "Invoke execution on $PEERS failed "
#   echo "===================== Invoke transaction successful on $PEERS on channel '$CHANNEL_NAME3' ===================== "
#   echo
# }
chaincodeCreateHealthCare() {
  parsePeerConnectionParameters $@
  res=$?
  verifyResult $res "Invoke transaction failed on channel '$CHANNEL_NAME3' due to uneven number of peer and org parameters "
  setGlobals 0 4
  
  # while 'peer chaincode' command can get the orderer endpoint from the
  # peer (if join was successful), let's supply it directly as we know
  # it using the "-o" option
  if [ -z "$CORE_PEER_TLS_ENABLED" -o "$CORE_PEER_TLS_ENABLED" = "false" ]; then
    set -x
    peer chaincode invoke -o orderer.example.com:7050 -C $CHANNEL_NAME3 -n channel3 $PEER_CONN_PARMS -c '{"function":"createHealthcare","Args":["ABC001","HASHVALUE","ENCODINGSTRING"]}' >&log.txt
    res=$?
    set +x
  else
    set -x
    peer chaincode invoke -o orderer.example.com:7050 --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA -C $CHANNEL_NAME3 -n channel3 $PEER_CONN_PARMS -c '{"function":"createHealthcare","Args":["ABC001","HASHVALUE","ENCODINGSTRING"]}' >&log.txt
    res=$?
    set +x
    
  fi
  cat log.txt
  verifyResult $res "Invoke execution on $PEERS failed "
  echo "===================== Invoke transaction successful on $PEERS on channel '$CHANNEL_NAME3' ===================== "
  echo
}

chaincodeQueryHealthCare() {
  parsePeerConnectionParameters $@
  res=$?
  verifyResult $res "Invoke transaction failed on channel '$CHANNEL_NAME3' due to uneven number of peer and org parameters "
  setGlobals 0 4
  
  # while 'peer chaincode' command can get the orderer endpoint from the
  # peer (if join was successful), let's supply it directly as we know
  # it using the "-o" option
  if [ -z "$CORE_PEER_TLS_ENABLED" -o "$CORE_PEER_TLS_ENABLED" = "false" ]; then
    set -x
    peer chaincode invoke -o orderer.example.com:7050 -C $CHANNEL_NAME3 -n channel3 $PEER_CONN_PARMS -c '{"function":"queryHealthcare","Args":["ABC001"]}' >&log.txt
    res=$?
    set +x
  else
    set -x
    peer chaincode invoke -o orderer.example.com:7050 --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA -C $CHANNEL_NAME3 -n channel3 $PEER_CONN_PARMS -c '{"function":"queryHealthcare","Args":["ABC001"]}' >&log.txt
    res=$?
    set +x
    
  fi
  cat log.txt
  verifyResult $res "Invoke execution on $PEERS failed "
  echo "===================== Invoke transaction successful on $PEERS on channel '$CHANNEL_NAME3' ===================== "
  echo
}
chaincodeCreateHealthCare() {
  parsePeerConnectionParameters $@
  res=$?
  verifyResult $res "Invoke transaction failed on channel '$CHANNEL_NAME3' due to uneven number of peer and org parameters "
  setGlobals 0 3
  
  # while 'peer chaincode' command can get the orderer endpoint from the
  # peer (if join was successful), let's supply it directly as we know
  # it using the "-o" option
  if [ -z "$CORE_PEER_TLS_ENABLED" -o "$CORE_PEER_TLS_ENABLED" = "false" ]; then
    set -x
    peer chaincode invoke -o orderer.example.com:7050 -C $CHANNEL_NAME3 -n channel3 $PEER_CONN_PARMS -c '{"function":"createHealthcare","Args":["ABC001","HASHVALUE","ENCODINGSTRING"]}' >&log.txt
    res=$?
    set +x
  else
    set -x
    peer chaincode invoke -o orderer.example.com:7050 --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA -C $CHANNEL_NAME3 -n channel3 $PEER_CONN_PARMS -c '{"function":"createHealthcare","Args":["ABC001","HASHVALUE","ENCODINGSTRING"]}' >&log.txt
    res=$?
    set +x
    
  fi
  cat log.txt
  verifyResult $res "Invoke execution on $PEERS failed "
  echo "===================== Invoke transaction successful on $PEERS on channel '$CHANNEL_NAME3' ===================== "
  echo
}

chaincodeQueryHealthCare() {
  parsePeerConnectionParameters $@
  res=$?
  verifyResult $res "Invoke transaction failed on channel '$CHANNEL_NAME3' due to uneven number of peer and org parameters "
  setGlobals 0 4
  
  # while 'peer chaincode' command can get the orderer endpoint from the
  # peer (if join was successful), let's supply it directly as we know
  # it using the "-o" option
  if [ -z "$CORE_PEER_TLS_ENABLED" -o "$CORE_PEER_TLS_ENABLED" = "false" ]; then
    set -x
    peer chaincode invoke -o orderer.example.com:7050 -C $CHANNEL_NAME3 -n channel3 $PEER_CONN_PARMS -c '{"function":"queryHealthcare","Args":["ABC001"]}' >&log.txt
    res=$?
    set +x
  else
    set -x
    peer chaincode invoke -o orderer.example.com:7050 --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA -C $CHANNEL_NAME3 -n channel3 $PEER_CONN_PARMS -c '{"function":"queryHealthcare","Args":["ABC001"]}' >&log.txt
    res=$?
    set +x
    
  fi
  cat log.txt
  verifyResult $res "Invoke execution on $PEERS failed "
  echo "===================== Invoke transaction successful on $PEERS on channel '$CHANNEL_NAME3' ===================== "
  echo
}
chaincodeQueryHealthCare() {
  parsePeerConnectionParameters $@
  res=$?
  verifyResult $res "Invoke transaction failed on channel '$CHANNEL_NAME3' due to uneven number of peer and org parameters "
  setGlobals 0 3
  
  # while 'peer chaincode' command can get the orderer endpoint from the
  # peer (if join was successful), let's supply it directly as we know
  # it using the "-o" option
  if [ -z "$CORE_PEER_TLS_ENABLED" -o "$CORE_PEER_TLS_ENABLED" = "false" ]; then
    set -x
    peer chaincode invoke -o orderer.example.com:7050 -C $CHANNEL_NAME3 -n channel3 $PEER_CONN_PARMS -c '{"function":"queryHealthcare","Args":["ABC001"]}' >&log.txt
    res=$?
    set +x
  else
    set -x
    peer chaincode invoke -o orderer.example.com:7050 --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA -C $CHANNEL_NAME3 -n channel3 $PEER_CONN_PARMS -c '{"function":"queryHealthcare","Args":["ABC001"]}' >&log.txt
    res=$?
    set +x
    
  fi
  cat log.txt
  verifyResult $res "Invoke execution on $PEERS failed "
  echo "===================== Invoke transaction successful on $PEERS on channel '$CHANNEL_NAME3' ===================== "
  echo
}
chaincodeQueryHealthCare() {
  parsePeerConnectionParameters $@
  res=$?
  verifyResult $res "Invoke transaction failed on channel '$CHANNEL_NAME3' due to uneven number of peer and org parameters "
  setGlobals 0 2
  
  # while 'peer chaincode' command can get the orderer endpoint from the
  # peer (if join was successful), let's supply it directly as we know
  # it using the "-o" option
  if [ -z "$CORE_PEER_TLS_ENABLED" -o "$CORE_PEER_TLS_ENABLED" = "false" ]; then
    set -x
    peer chaincode invoke -o orderer.example.com:7050 -C $CHANNEL_NAME3 -n channel3 $PEER_CONN_PARMS -c '{"function":"queryHealthcare","Args":["ABC001"]}' >&log.txt
    res=$?
    set +x
  else
    set -x
    peer chaincode invoke -o orderer.example.com:7050 --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA -C $CHANNEL_NAME3 -n channel3 $PEER_CONN_PARMS -c '{"function":"queryHealthcare","Args":["ABC001"]}' >&log.txt
    res=$?
    set +x
    
  fi
  cat log.txt
  verifyResult $res "Invoke execution on $PEERS failed "
  echo "===================== Invoke transaction successful on $PEERS on channel '$CHANNEL_NAME3' ===================== "
  echo
}
chaincodeQueryHealthCare() {
  parsePeerConnectionParameters $@
  res=$?
  verifyResult $res "Invoke transaction failed on channel '$CHANNEL_NAME3' due to uneven number of peer and org parameters "
  setGlobals 0 1
  
  # while 'peer chaincode' command can get the orderer endpoint from the
  # peer (if join was successful), let's supply it directly as we know
  # it using the "-o" option
  if [ -z "$CORE_PEER_TLS_ENABLED" -o "$CORE_PEER_TLS_ENABLED" = "false" ]; then
    set -x
    peer chaincode invoke -o orderer.example.com:7050 -C $CHANNEL_NAME3 -n channel3 $PEER_CONN_PARMS -c '{"function":"queryHealthcare","Args":["ABC001"]}' >&log.txt
    res=$?
    set +x
  else
    set -x
    peer chaincode invoke -o orderer.example.com:7050 --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA -C $CHANNEL_NAME3 -n channel3 $PEER_CONN_PARMS -c '{"function":"queryHealthcare","Args":["ABC001"]}' >&log.txt
    res=$?
    set +x
    
  fi
  cat log.txt
  verifyResult $res "Invoke execution on $PEERS failed "
  echo "===================== Invoke transaction successful on $PEERS on channel '$CHANNEL_NAME3' ===================== "
  echo
}
chaincodeCreateBloodline() {
  parsePeerConnectionParameters $@
  res=$?
  verifyResult $res "Invoke transaction failed on channel '$CHANNEL_NAME3' due to uneven number of peer and org parameters "
  setGlobals 0 3
  
  # while 'peer chaincode' command can get the orderer endpoint from the
  # peer (if join was successful), let's supply it directly as we know
  # it using the "-o" option
  if [ -z "$CORE_PEER_TLS_ENABLED" -o "$CORE_PEER_TLS_ENABLED" = "false" ]; then
    set -x
    peer chaincode invoke -o orderer.example.com:7050 -C $CHANNEL_NAME3 -n channel3 $PEER_CONN_PARMS -c '{"function":"createBloodline","Args":["ABC001","HASHVALUE","ENCODINGSTRING"]}' >&log.txt
    res=$?
    set +x
  else
    set -x
    peer chaincode invoke -o orderer.example.com:7050 --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA -C $CHANNEL_NAME3 -n channel3 $PEER_CONN_PARMS -c '{"function":"createBloodline","Args":["ABC001","HASHVALUE","ENCODINGSTRING"]}' >&log.txt
    res=$?
    set +x
    
  fi
  cat log.txt
  verifyResult $res "Invoke execution on $PEERS failed "
  echo "===================== Invoke transaction successful on $PEERS on channel '$CHANNEL_NAME3' ===================== "
  echo
}

chaincodeQueryBloodline() {
  parsePeerConnectionParameters $@
  res=$?
  verifyResult $res "Invoke transaction failed on channel '$CHANNEL_NAME3' due to uneven number of peer and org parameters "
  setGlobals 0 3
  
  # while 'peer chaincode' command can get the orderer endpoint from the
  # peer (if join was successful), let's supply it directly as we know
  # it using the "-o" option
  if [ -z "$CORE_PEER_TLS_ENABLED" -o "$CORE_PEER_TLS_ENABLED" = "false" ]; then
    set -x
    peer chaincode invoke -o orderer.example.com:7050 -C $CHANNEL_NAME3 -n channel3 $PEER_CONN_PARMS -c '{"function":"queryBloodline","Args":["ABC001"]}' >&log.txt
    res=$?
    set +x
  else
    set -x
    peer chaincode invoke -o orderer.example.com:7050 --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA -C $CHANNEL_NAME3 -n channel3 $PEER_CONN_PARMS -c '{"function":"queryBloodline","Args":["ABC001"]}' >&log.txt
    res=$?
    set +x
    
  fi
  cat log.txt
  verifyResult $res "Invoke execution on $PEERS failed "
  echo "===================== Invoke transaction successful on $PEERS on channel '$CHANNEL_NAME3' ===================== "
  echo
}

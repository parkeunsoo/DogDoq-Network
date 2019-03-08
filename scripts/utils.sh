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
    echo "========= ERROR !!! FAILED to execute  ==========="
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


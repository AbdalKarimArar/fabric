#!/bin/bash
source base_parameters.sh

export CORE_PEER_MSPCONFIGPATH="${FABRIC_CFG_PATH}"/crypto-config/peerOrganizations/"${PEER_DOMAIN}"/users/Admin@"${PEER_DOMAIN}"/msp
export CORE_PEER_LOCALMSPID=Org1MSP

index=$1
remainder=$2
count=0
e_idx=0

while [[ ${remainder} -gt 0 ]]
do
    if [[ ${#ENDORSER_ADDRESS[@]} -eq 0 ]]
    then
        endorsers=("${FAST_PEER_ADDRESS}")
    else
        endorsers=("${ENDORSER_ADDRESS[@]}")
    fi

    i=$((e_idx % ${#endorsers[@]}))
    e_idx=$((e_idx + 1))

    CORE_PEER_ADDRESS="$(get_correct_peer_address "${endorsers[${i}]}")":7051
    export CORE_PEER_ADDRESS

    if [[ ${remainder} -gt 100000 ]]
    then
        count=100000
    else
        count=${remainder}
    fi
    remainder=$((remainder - count))

    a="'{\"Args\":[\"init\",\"$index\", \"$count\", \"$3\"]}'"
    echo "Instantiating accounts ${index} to $((index + count -1 ))"

    echo peer chaincode invoke -o "$(get_correct_orderer_address)":7050 -C "${CHANNEL}" -n "${CHAINCODE}" -c "${a}" | bash
    index=$((index + count))
done
echo All done!
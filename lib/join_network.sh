#!/bin/bash

source qm.variables
source lib/common.sh

function readParameters() {

    POSITIONAL=()
    while [[ $# -gt 0 ]]
    do
        key="$1"

        case $key in
            -n|--name)
            sNode="$2"
            shift # past argument
            shift # past value
            ;;
            --oip)
            pMainIp="$2"
            shift # past argument
            shift # past value
            ;;
            --onm)
            mgoPort="$2"
            shift # past argument
            shift # past value
            ;;
            --tip)
            pCurrentIp="$2"
            shift # past argument
            shift # past value
            ;;
            -r|--rpc)
            rPort="$2"
            shift # past argument
            shift # past value
            ;;
            -w|--whisper)
            wPort="$2"
            shift # past argument
            shift # past value
            ;;
            -c|--constellation)
            cPort="$2"
            shift # past argument
            shift # past value
            ;;
            --nm)
            tgoPort="$2"
            shift # past argument
            shift # past value
            ;;
            --ws)
            wsPort="$2"
            shift # past argument
            shift # past value
            ;;
            -t|--tessera)
            tessera="true"
            shift # past argument
            shift # past value
            ;;
            -pk|--privKey)
            pKey="$2"
            shift # past argument
            shift # past value
            ;;
            -cid|--chainId)
            chainId="$2"
            shift # past argument
            shift # past value
            ;;
            -en|--ethnet)
            ethNetwork="$2"
            shift # past argument
            shift # past value
            ;;
            --validator)
            validator="true"
            shift # past argument
            shift # past value
            ;;
            *)    # unknown option
            POSITIONAL+=("$1") # save it in an array for later
            shift # past argument
            ;;
        esac
    done
    set -- "${POSITIONAL[@]}" # restore positional parameters

    if [[ -z "$sNode" && -z "$pMainIp" && -z "$mgoPort" && -z "$pCurrentIp" && -z "$rPort" && -z "$wPort" && -z "$cPort" && -z "$tgoPort" && -z "$wsPort" && -z "$chainId" && -z "$ethNetwork" ]]; then
        return
    fi

    if [[ -z "$sNode" || -z "$pMainIp" || -z "$mgoPort" || -z "$pCurrentIp" || -z "$rPort" || -z "$wPort" || -z "$cPort" || -z "$tgoPort" || -z "$wsPort" || -z "$chainId" || -z "$ethNetwork" ]]; then
        help
    fi

    NON_INTERACTIVE=true
}

function readInputs(){

    if [ -z "$NON_INTERACTIVE" ]; then
        selectEthNetwork    'Please select ethereum network' ethNetwork $YELLOW
        getInputWithDefault 'Please enter IP Address of existing node' "" pMainIp $RED
        getInputWithDefault 'Please enter Node Manager Port of existing node' 22003 mgoPort $YELLOW
        getInputWithDefault 'Please enter IP Address of this node' "" pCurrentIp $RED
        getInputWithDefault 'Please enter RPC Port of this node' 22000 rPort $GREEN
        getInputWithDefault 'Please enter Network Listening Port of this node' $((rPort+1)) wPort $GREEN
        getInputWithDefault 'Please enter Constellation Port of this node' $((wPort+1)) cPort $GREEN
        getInputWithDefault 'Please enter Node Manager Port of this node' $((cPort+1)) tgoPort $BLUE
        getInputWithDefault 'Please enter WS Port of this node' $((tgoPort+1)) wsPort $GREEN
        getInputWithDefault 'Please enter private key of this node(Empty->new key is generated)' "" pKey $RED
        getInputWithDefault 'Please enter existing chainId to connect to' "" chainId $RED
    fi

}

#function to generate keyPair for node
 function generateKeyPair(){
    echo -ne "\n" | constellation-node --generatekeys=${sNode} 1>>/dev/null

    echo -ne "\n" | constellation-node --generatekeys=${sNode}a 1>>/dev/null

    mv ${sNode}*.*  ${sNode}/node/keys/.

 }

#function to create node initialization script
function createInitNodeScript(){
    cat lib/slave/init_template.sh > ${sNode}/init.sh
    chmod +x ${sNode}/init.sh
}

#function to generate enode and create static-nodes.json file
function generateEnode(){
    if [[ -z "$pKey" ]]; then
        bootnode -genkey nodekey
    else
        echo ${pKey} > nodekey
    fi

    nodekey=$(cat nodekey)
    bootnode -nodekey nodekey 2>enode.txt &
    enode=$(bootnode -nodekey nodekey -writeaddress)

    Enode1='enode://'$enode'@'$pCurrentIp:$wPort?'discport=0'
    cp lib/slave/static-nodes_template.json ${sNode}/node/qdata/static-nodes.json
    # PATTERN="s|#eNode#|${Enode1}|g"
    # sed -i $PATTERN ${sNode}/node/qdata/static-nodes.json
    echo $Enode1 > ${sNode}/node/enode.txt
    cp nodekey ${sNode}/node/qdata/geth/.
    chmod o+r ${sNode}/node/qdata/geth/nodekey
    rm enode.txt
    rm nodekey
}

#function to create node accout and append it into genesis.json file
function createAccount(){
    sAccountAddress="$(geth --datadir datadir --password lib/slave/passwords.txt account new 2>> /dev/null)"
    re="\{([^}]+)\}"
    if [[ $sAccountAddress =~ $re ]];
    then
        sAccountAddress="0x"${BASH_REMATCH[1]};
    fi
    mv datadir/keystore/* ${sNode}/node/qdata/keystore/${sNode}key
    rm -rf datadir
}

#function to import node accout and append it into genesis.json file
function importAccount(){
    echo ${pKey} > temp_key
    sAccountAddress="$(geth --datadir datadir --password lib/slave/passwords.txt account import temp_key 2>> /dev/null)"
    re="\{([^}]+)\}"
    if [[ $sAccountAddress =~ $re ]];
    then
        sAccountAddress="0x"${BASH_REMATCH[1]};
    fi
    mv datadir/keystore/* ${sNode}/node/qdata/keystore/${sNode}key
    rm -rf datadir
    rm -rf temp_key
}

#function to create start node script without --raftJoinExisting flag
function copyScripts(){
    cp lib/slave/start_powerchain_template.sh ${sNode}/node/start_${sNode}.sh

    cp lib/slave/start_template.sh ${sNode}/start.sh

    chmod +x ${sNode}/start.sh
    chmod +x ${sNode}/node/start_${sNode}.sh

    cp lib/slave/pre_start_check_template.sh ${sNode}/node/pre_start_check.sh

    cp lib/common.sh  ${sNode}/node

    cp lib/slave/constellation_template.conf ${sNode}/node/${sNode}.conf

    cp lib/master/tessera-migration.properties ${sNode}/node/qdata

    cp lib/master/empty_h2.mv.db ${sNode}/node/qdata/${sNode}.mv.db

    cp lib/slave/migrate_to_tessera.sh ${sNode}/node
    PATTERN="s/#mNode#/${sNode}/g"
    sed -i $PATTERN ${sNode}/node/migrate_to_tessera.sh
}

function createSetupConf() {
    echo 'NODENAME='${sNode} > ${sNode}/setup.conf
    echo 'ACC_PUBKEY='${sAccountAddress} >> ${sNode}/setup.conf
    if [ $ethNetwork == "ropsten" ]; then
      echo 'INFURA_URL=wss://ropsten.infura.io/ws' >> ${sNode}/setup.conf
      echo 'CONTRACT_ADDRESS=0xfc80ab40bbf9cf9faacad6407a9768e7d3ae92a3' >> ${sNode}/setup.conf
    elif [ $ethNetwork == "mainnet" ]; then
      echo 'INFURA_URL=wss://mainnet.infura.io/ws' >> ${sNode}/setup.conf
      echo 'CONTRACT_ADDRESS=0x7a79868b8375131B4c6A681b112109A51EEa0a6C' >> ${sNode}/setup.conf
    else
      echo "Invalid ethereum network option: $ethNetwork. Possible values: [ropsten, mainnet]"
      exit 1
    fi
    echo 'CHAIN_ID='${chainId} >> ${sNode}/setup.conf
    echo 'MASTER_IP='${pMainIp} >> ${sNode}/setup.conf
    echo 'WHISPER_PORT='${wPort} >> ${sNode}/setup.conf
    echo 'RPC_PORT='${rPort} >> ${sNode}/setup.conf
    echo 'CONSTELLATION_PORT='${cPort} >> ${sNode}/setup.conf
    echo 'THIS_NODEMANAGER_PORT='${tgoPort} >> ${sNode}/setup.conf
    echo 'MAIN_NODEMANAGER_PORT='${mgoPort} >> ${sNode}/setup.conf
    echo 'WS_PORT='${wsPort} >> ${sNode}/setup.conf
    echo 'CURRENT_IP='${pCurrentIp} >> ${sNode}/setup.conf
    echo 'REGISTERED=' >> ${sNode}/setup.conf

    if [ ! -z $validator ]; then
        echo 'ROLE=validator' >> ${sNode}/setup.conf
    else
        echo 'ROLE=non-validator' >> ${sNode}/setup.conf
    fi

    if [ ! -z $tessera ]; then
        echo 'TESSERA=true' >> ${sNode}/setup.conf
    fi
}

function cleanup() {
    echo $sNode > .nodename
    rm -rf ${sNode}
    mkdir -p ${sNode}/node/keys
    mkdir -p ${sNode}/node/contracts
    mkdir -p ${sNode}/node/qdata
    mkdir -p ${sNode}/node/qdata/{keystore,geth,logs}
    cp qm.variables $sNode
}

function main(){

    readParameters $@

    if [ -z "$NON_INTERACTIVE" ]; then
        getInputWithDefault 'Please enter node name' "" sNode $GREEN
    fi

    cleanup
    readInputs
    generateKeyPair
    createInitNodeScript
    generateEnode
    copyScripts

    if [[ -z "$pKey" ]]; then
        createAccount
    else
        importAccount
    fi

    createSetupConf
}

main $@

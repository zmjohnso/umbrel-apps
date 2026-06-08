export APP_BITCOIN_COMMONS_NODE_IP="10.21.21.119"
export APP_BITCOIN_COMMONS_TOR_PROXY_IP="10.21.22.119"
export APP_BITCOIN_COMMONS_I2P_DAEMON_IP="10.21.22.120"

export APP_BITCOIN_COMMONS_DATA_DIR="${EXPORTS_APP_DIR}/data/blvm"
export APP_BITCOIN_COMMONS_RPC_PORT="8332"
export APP_BITCOIN_COMMONS_P2P_PORT="8333"
# Additional inbound P2P listener granting whitelisted permissions (whitebind) to this port; for trusted internal apps only; do not publish externally
export APP_BITCOIN_COMMONS_P2P_WHITEBIND_PORT="8335"
export APP_BITCOIN_COMMONS_TOR_PORT="8334"
export APP_BITCOIN_COMMONS_ZMQ_RAWBLOCK_PORT="38332"
export APP_BITCOIN_COMMONS_ZMQ_RAWTX_PORT="38333"
export APP_BITCOIN_COMMONS_ZMQ_HASHBLOCK_PORT="38334"
export APP_BITCOIN_COMMONS_ZMQ_SEQUENCE_PORT="38335"
export APP_BITCOIN_COMMONS_ZMQ_HASHTX_PORT="38336"

export APP_BITCOIN_COMMONS_NETWORK="mainnet"

# Check for an existing settings.json file to override APP_BITCOIN_COMMONS_NETWORK with user's choice
{
	COMMONS_APP_CONFIG_FILE="${EXPORTS_APP_DIR}/data/app/settings.json"
	if [[ -f "${COMMONS_APP_CONFIG_FILE}" ]]
	then
		commons_app_network=$(jq -r '.chain' "${COMMONS_APP_CONFIG_FILE}")
		case $commons_app_network in
			"main")
				APP_BITCOIN_COMMONS_NETWORK="mainnet";;
			"test")
				APP_BITCOIN_COMMONS_NETWORK="testnet";;
			"testnet4")
				APP_BITCOIN_COMMONS_NETWORK="testnet4";;
			"signet")
				APP_BITCOIN_COMMONS_NETWORK="signet";;
			"regtest")
				APP_BITCOIN_COMMONS_NETWORK="regtest";;
			*)
				if [[ -n "$commons_app_network" ]] && [[ "$commons_app_network" != "null" ]]; then
					echo "Warning (${EXPORTS_APP_ID}): Invalid network '${commons_app_network}' in settings.json. Exporting APP_BITCOIN_COMMONS_NETWORK as default 'mainnet'."
				fi;;
		esac
	fi
} > /dev/null || true

COMMONS_ENV_FILE="${EXPORTS_APP_DIR}/.env"

if [[ ! -f "${COMMONS_ENV_FILE}" ]]; then

	if [[ -z ${BITCOIN_COMMONS_RPC_USER+x} ]] || [[ -z ${BITCOIN_COMMONS_RPC_PASS+x} ]]; then
		BITCOIN_COMMONS_RPC_USER="umbrel"
		BITCOIN_COMMONS_RPC_DETAILS=$("${EXPORTS_APP_DIR}/scripts/rpcauth.py" "${BITCOIN_COMMONS_RPC_USER}")
		BITCOIN_COMMONS_RPC_PASS=$(echo "$BITCOIN_COMMONS_RPC_DETAILS" | tail -1)
	fi

	echo "export APP_BITCOIN_COMMONS_RPC_USER='${BITCOIN_COMMONS_RPC_USER}'"	>> "${COMMONS_ENV_FILE}"
	echo "export APP_BITCOIN_COMMONS_RPC_PASS='${BITCOIN_COMMONS_RPC_PASS}'"	>> "${COMMONS_ENV_FILE}"
fi

. "${COMMONS_ENV_FILE}"

rpc_hidden_service_file="${EXPORTS_TOR_DATA_DIR}/app-${EXPORTS_APP_ID}-rpc/hostname"
p2p_hidden_service_file="${EXPORTS_TOR_DATA_DIR}/app-${EXPORTS_APP_ID}-p2p/hostname"
export APP_BITCOIN_COMMONS_RPC_HIDDEN_SERVICE="$(cat "${rpc_hidden_service_file}" 2>/dev/null || echo "notyetset.onion")"
export APP_BITCOIN_COMMONS_P2P_HIDDEN_SERVICE="$(cat "${p2p_hidden_service_file}" 2>/dev/null || echo "notyetset.onion")"

# electrs compatible network param
export APP_BITCOIN_COMMONS_NETWORK_ELECTRS=$APP_BITCOIN_COMMONS_NETWORK
if [[ "${APP_BITCOIN_COMMONS_NETWORK_ELECTRS}" = "mainnet" ]]; then
	APP_BITCOIN_COMMONS_NETWORK_ELECTRS="bitcoin"
fi

for var in \
    NODE_IP \
    TOR_PROXY_IP \
    I2P_DAEMON_IP \
    DATA_DIR \
    RPC_PORT \
    P2P_PORT \
    P2P_WHITEBIND_PORT \
    TOR_PORT \
    ZMQ_RAWBLOCK_PORT \
    ZMQ_RAWTX_PORT \
    ZMQ_HASHBLOCK_PORT \
    ZMQ_SEQUENCE_PORT \
    ZMQ_HASHTX_PORT \
    NETWORK \
    RPC_USER \
    RPC_PASS \
    RPC_HIDDEN_SERVICE \
    P2P_HIDDEN_SERVICE \
    NETWORK_ELECTRS
do
    bitcoin_var="APP_BITCOIN_${var}"
    commons_var="APP_BITCOIN_COMMONS_${var}"
    if [ -n "${!commons_var-}" ]; then
        export "$bitcoin_var"="${!bitcoin_var:=${!commons_var}}"
    else
        echo "Warning: $commons_var is unset or empty"
    fi
done

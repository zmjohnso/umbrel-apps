export APP_FRIGATE_ELECTRUM_IP="10.21.22.201"
export APP_FRIGATE_ELECTRUM_NODE_IP="10.21.21.201"

export APP_FRIGATE_ELECTRUM_NODE_PORT="50003"

# APP_BITCOIN_* vars are automatically correct for both Bitcoin Core and Bitcoin
# Knots — the bitcoin-knots app aliases APP_BITCOIN_KNOTS_* into APP_BITCOIN_*
# if Core is not installed, so no detection is needed here.

export APP_FRIGATE_ELECTRUM_BACKEND_ELECTRUM_SERVER="${APP_ELECTRS_NODE_IP}:${APP_ELECTRS_NODE_PORT}"

rpc_hidden_service_file="${EXPORTS_TOR_DATA_DIR}/app-${EXPORTS_APP_ID}-rpc/hostname"
export APP_FRIGATE_ELECTRUM_RPC_HIDDEN_SERVICE="$(cat "${rpc_hidden_service_file}" 2>/dev/null || echo "notyetset.onion")"

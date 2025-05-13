default: build

# Variables
DSPONSOR_FACTORY = CB334WURH6W3MQIE3NUL4DGXS7NDUMSEQ234EB2YNXMCMXLJS6P4MQ2I
DSPONSOR_ADMIN = CCHLMFB5BOUWWA6YWSCM33P7IXLDJSBRK2AQYFSBHPXMT3EJ7YUH5IU5
NFT_CONTRACT = CAP6CNBYGE7D6LVPIWNIHQX5QTR3IFCGGYMVZTCSLCC5VVLE43NT4WUF
SOURCE_ACCOUNT = siborg
FEE_RECIPIENT = siborg
NATIVE_XLM=CDLZFC3SYJYDZT7K67VZ75HPJVIEUVNIXF47ZG2FB2RMQQVU2HHGCYSC
NETWORK = testnet

all: test deploy-factory deploy

test: build
	cargo test

build:
	cd dsponsor && cargo build --target wasm32-unknown-unknown --release
	cd dsponsor-factory && cargo build --target wasm32-unknown-unknown --release
	cd dsponsor-admin && cargo build --target wasm32-unknown-unknown --release

fmt:
	cargo fmt

clean:
	cargo clean
	rm -rf target/
	make build
	make test

deploy: 
	stellar contract deploy \
 	--wasm target/wasm32-unknown-unknown/release/dsponsor_admin.wasm \
	--source ${SOURCE_ACCOUNT} \
	--network testnet 

deploy-factory: 
	stellar contract deploy \
 	--wasm target/wasm32-unknown-unknown/release/dsponsor_factory.wasm \
	--source ${SOURCE_ACCOUNT} \
	--network testnet \

deploy-simple-nft: 
	stellar contract deploy \
 	--wasm target/wasm32-unknown-unknown/release/dsponsor.wasm \
	--source ${SOURCE_ACCOUNT} \
	--network testnet \

# Initialize the contract
initialize:
	stellar contract invoke \
		--id $(DSPONSOR_ADMIN) \
		--source $(SOURCE_ACCOUNT) \
		--network $(NETWORK) \
		-- \
		initialize \
		--nft_factory $(DSPONSOR_FACTORY) \
		--fee_recipient $(FEE_RECIPIENT) \
		--native_xlm $(NATIVE_XLM) \
		--bps 100 \
		--admin $(SOURCE_ACCOUNT) \

create_offer:
	stellar contract invoke \
		--id $(DSPONSOR_ADMIN) \
		--source $(SOURCE_ACCOUNT) \
		--network $(NETWORK) \
		-- \
		create_dsponsor_nft_and_offer \
		

create_nft_contract:
	stellar contract invoke \
		--id $(DSPONSOR_ADMIN) \
		--source $(SOURCE_ACCOUNT) \
		--network $(NETWORK) \
		-- \
		create_dsponsor_nft \
		--init_params $() \
		--native_xlm $(NATIVE_XLM) \
		--salt 0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef \



get_offers:
	stellar contract invoke \
		--id $(DSPONSOR_ADMIN) \
		--source $(SOURCE_ACCOUNT) \
		--network $(NETWORK) \
		-- \
		get_all_offers \

get_nft_tokens:
	stellar contract invoke \
		--id $(NFT_CONTRACT) \
		--source $(SOURCE_ACCOUNT) \
		--network $(NETWORK) \
		-- \
		get_user_tokens \
		--user GDBCM52LC5QLPN4LRCRU22DYAKRUYLRJMTMBOQKK7RNZIQUZHSAEUMON \

approve_native_xlm:
	stellar contract invoke \
		--id $(NATIVE_XLM) \
		--source $(SOURCE_ACCOUNT) \
		--network $(NETWORK) \
		-- \
		approve \
		--from $(SOURCE_ACCOUNT) \
		--spender $(DSPONSOR_ADMIN) \
		--amount 1000000000000000000 \
		--expiration-ledger 
		
sdk-gen: 
	soroban contract bindings typescript \
  --rpc-url https://soroban-testnet.stellar.org:443 \
  --network-passphrase "Test SDF Network ; September 2015" \
  --contract-id $(DSPONSOR_ADMIN) \
  --output-dir ../sdk \
  --overwrite


admin-ready: 
	make initialize
	make sdk-gen

.PHONY: default all test build build-debug fmt clean

# soroban contract asset id --asset native --network testnet
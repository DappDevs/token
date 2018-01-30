TARGETS=DappDevToken.sol
contracts.json: $(TARGETS)
	solc --combined-json abi,bin,bin-runtime $^ > $@

contracts.min.json: contracts.json | $(TARGETS)
	python3 minify_contracts.py $< $| > $@

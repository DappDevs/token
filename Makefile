TARGETS =contracts/DappDevToken.sol
TARGETS+=contracts/DappDevMint.sol
contracts.json: $(TARGETS)
	solc --optimize --combined-json abi,bin,bin-runtime $^ > $@

contracts.min.json: contracts.json | $(TARGETS)
	python3 minify_contracts.py $< $| > $@

.PHONY: clean
clean:
	rm -f contracts.json
	rm -f contracts.min.json

SHELL := /bin/bash

bin/mage: src/mage.go ## build mage
	go build -o bin/mage src/mage.go

help: ## Prints help for targets with comments
	@grep -E '^[.0-9a-zA-Z_-/]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

all:
	go build -o bin/template-reader src/tmplate-reader.go src/functions.go

bin/mage-quant: src/mage-quant.go src/functions.go ## bin/mage-quant
	go build -o bin/mage-quant src/mage-quant.go src/functions.go



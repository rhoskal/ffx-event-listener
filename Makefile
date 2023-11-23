# Build configuration
# -------------------

APP_NAME := `node -p "require('./package.json').name"`
GIT_BRANCH :=`git rev-parse --abbrev-ref HEAD`
GIT_REVISION := `git rev-parse HEAD`

# Introspection targets
# ---------------------

.PHONY: help
help: header targets

.PHONY: header
header:
	@printf "\n\033[34mEnvironment\033[0m\n"
	@printf "\033[34m---------------------------------------------------------------\033[0m\n"
	@printf "\033[33m%-23s\033[0m" "APP_NAME"
	@printf "\033[35m%s\033[0m" $(APP_NAME)
	@echo ""
	@printf "\033[33m%-23s\033[0m" "GIT_BRANCH"
	@printf "\033[35m%s\033[0m" $(GIT_BRANCH)
	@echo ""
	@printf "\033[33m%-23s\033[0m" "GIT_REVISION"
	@printf "\033[35m%s\033[0m" $(GIT_REVISION)
	@echo ""

.PHONY: targets
targets:
	@printf "\n\033[34mTargets\033[0m\n"
	@printf "\033[34m---------------------------------------------------------------\033[0m\n"
	@perl -nle'print $& if m{^[a-zA-Z_-]+:.*?## .*$$}' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-22s\033[0m %s\n", $$1, $$2}'

# Build targets
# -------------------

.PHONY: clean
clean: ## Remove build artifacts
	pnpm rimraf dist

.PHONY: build
build: compile-ts ## Make a production build
	pnpm vite build

.PHONY: compile-ts
compile-ts: elm-ports ## Run Typscript compiler
	pnpm tsc

# Development targets
# -------------------

.PHONY: deps
deps: ## Install all dependencies
	pnpm install

.PHONY: preview
preview: build ## See what the production build will look like
	pnpm vite preview --https

.PHONY: run
run: ## Run web app
	pnpm vite --port 4001

# Check, lint, format and test targets
# ------------------------------------

.PHONY: format
format: format-elm format-ts ## Format everything

.PHONY: format-elm
format-elm: ## Format Elm files
	elm-format src/ review/ tests/ --yes

.PHONY: format-ts
format-ts: ## Format Typescript files
	pnpm prettier --write '{e2e,src}/**/*.{css,json,js,ts,mjs,mts}'

.PHONY: lint
lint: lint-elm lint-ts ## Lint everything

.PHONY: lint-elm
lint-elm: ## Lint elm files
	elm-review

.PHONY: lint-ts
lint-ts: ## Lint ts files
	pnpm eslint '{e2e,src}/**/*.{js,ts,mjs,mts}'

.PHONY: lint-fix
lint-fix: lint-elm-fix lint-ts-fix ## Lint fix everything

.PHONY: lint-elm-fix
lint-elm-fix: ## Lint fix all Elm files
	elm-review --fix-all

.PHONY: lint-ts-fix
lint-ts-fix: ## Lint fix all Typescript files
	pnpm eslint '{e2e,src}/**/*.{js,ts,mjs,mts}' --fix

.PHONY: test
test: test-elm ## Test code

.PHONY: test-elm
test-elm: ## Test Elm code
	elm-test

.PHONY: test-e2e
test-e2e: ## Test e2e w/o UI
	NODE_ENV=test pnpm playwright test

.PHONY: test-e2e-ui
test-e2e-ui: ## Test e2e with UI
	NODE_ENV=test pnpm playwright test --ui

# Other targets
# -------------------

.PHONY: elm-ports
elm-ports: ## Generate type declaration file for typescript interop
	pnpm elm-ts-interop -o src/Main.elm.d.ts

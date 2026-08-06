.PHONY: fmt validate plan

fmt:
	terraform fmt -recursive

validate:
	./scripts/validate.sh

plan:
	./scripts/plan.sh

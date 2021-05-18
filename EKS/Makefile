all: demostack dns
.PHONY: all doormat_creds doormat_aws deploy destroy console
TFC_ORG = jonaa
WORKSPACE_DEMOSTACK = Test-Workspace
check_creds = $(shell doormat --smoke-test 1>&2 2>/dev/null; echo $$?)
doormat_creds:
ifneq ($(check_creds), 0)
	doormat --refresh
endif
testeks: doormat_creds
	doormat aws --account se_demos_dev \
		--tf-push --tf-organization $(TFC_ORG) \
		--tf-workspace $(WORKSPACE_DEMOSTACK)
plan: doormat_aws
	terraform init -upgrade && terraform plan
deploy: doormat_aws
	terraform init -upgrade && terraform apply -auto-approve
destroy: doormat_aws
	terraform init -upgrade && terraform destroy -auto-approve
console: doormat_creds
	doormat aws --account se_demos_dev --console
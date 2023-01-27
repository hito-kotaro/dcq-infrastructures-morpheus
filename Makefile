TEMPLATE_FILE = src/cloudformation-template.yml
PARAMS = src/params/parameters.json
STACK_NAME = morpheus
BUCKET = cfn-build-objects
PREFIX = morpheus
PROFILE = tohi.work-admin

package:
	mkdir -p build
	aws cloudformation package \
		--template-file $(TEMPLATE_FILE) \
		--s3-bucket $(BUCKET) \
		--s3-prefix $(PREFIX) \
		--output-template-file build/cloudformation-template.yml \
		--region ap-northeast-1 --profile $(PROFILE)

deploy:
	aws cloudformation deploy \
		--template-file ./build/cloudformation-template.yml \
		--stack-name $(STACK_NAME) \
		--parameter-overrides "file://$(PARAMS)" \
		--capabilities CAPABILITY_NAMED_IAM CAPABILITY_AUTO_EXPAND \
		--region ap-northeast-1 \
		--profile $(PROFILE)

all: package deploy

confirm:
	@read -p "Delete $(STACK_NAME) ?[y/N]: " ans; \
        if [ "$$ans" != y ]; then \
                exit 1; \
        fi

delete: confirm
	aws cloudformation delete-stack --stack-name $(STACK_NAME) --region ap-northeast-1 --profile $(PROFILE)

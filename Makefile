TEMPLATE_FILE = src/cloudformation-template.yml
PARAMS = src/params
DEF = src/definitions
STACK_NAME = morpheus
BUCKET = cfn-build-objects
PREFIX = morpheus
PROFILE = tohi.work-admin

CONTAINER_NAME = morpheus-container
CONTAINER_IMAGE = image-arn
TASK_NAME = morpheus-api-task

package:
	mkdir -p build
	aws cloudformation package \
		--template-file $(TEMPLATE_FILE) \
		--s3-bucket $(BUCKET) \
		--s3-prefix $(PREFIX) \
		--output-template-file build/cloudformation-template.yml \
		--region ap-northeast-1 --profile $(PROFILE)

taskDef:
	sed -e 's/<CONTAINER_NAME>/$(CONTAINER_NAME)/' \
		-e 's/<CONTAINER_IMAGE>/$(CONTAINER_IMAGE)/' \
		-e 's/<TASK_NAME>/$(TASK_NAME)/g' \
		./src/def/task-def.json > ./build/task-def.json

	jq . ./build/task-def.json
	

create-ecr:
	aws ecr create-repository \
		--cli-input-json "file://$(DEF)/ecr-def.json"\
		--profile $(PROFILE)

deploy:
	aws cloudformation deploy \
		--template-file ./build/cloudformation-template.yml \
		--stack-name $(STACK_NAME) \
		--parameter-overrides "file://$(PARAMS)/parameters.json" \
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
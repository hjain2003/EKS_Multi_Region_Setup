pipeline {
    agent any

    environment {
        BUILD_TAG = "${env.BUILD_NUMBER}"
        IMAGE_NAME = "multi-cloud-app"

        // AWS
        AWS_REGION = 'us-east-1'
        AWS_ACCOUNT_ID = '302263069749'
        AWS_ECR_REPO = 'phase1-demo'
        ECS_CLUSTER = 'multi-cloud-aws-cluster'
        ECS_SERVICE = 'node-app-aws-service'
        ECS_TASK_FAMILY = 'node-app-aws'

        // Azure
        AZURE_SUBSCRIPTION = '4fa9bf7f-28c6-4c1b-814b-3d7209e59c23'
        AZURE_TENANT = 'dbc0019f-be99-46c2-aaac-7864fc838f87'
        AZURE_RESOURCE_GROUP = 'test'
        AZURE_ACR = 'azureACRRegistry'
        AZURE_CONTAINER_APP = 'azure-container-app'
        AZURE_IMAGE_TAG = "${BUILD_TAG}"
    }

    stages {
        stage('Build Docker Image') {
            steps {
                sh 'docker build --no-cache -t ${IMAGE_NAME}:${BUILD_TAG} -f server/Dockerfile server'
            }
        }

        stage('Deploy to Clouds') {
            parallel {
                stage('AWS') {
                    steps {
                        withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-creds']]) {
                            sh '''
                            # Push to ECR
                            aws ecr get-login-password --region $AWS_REGION \
                            | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com

                            IMAGE_URI=$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$AWS_ECR_REPO:$BUILD_TAG
                            docker tag ${IMAGE_NAME}:${BUILD_TAG} $IMAGE_URI
                            docker push $IMAGE_URI

                            # Deploy to ECS
                            aws ecs describe-task-definition --region $AWS_REGION --task-definition $ECS_TASK_FAMILY --query taskDefinition > taskdef.json

                            cat taskdef.json | jq \
                              --arg IMAGE "$IMAGE_URI" \
                              '.containerDefinitions[0].image=$IMAGE
                               | del(.taskDefinitionArn,.revision,.status,.requiresAttributes,.compatibilities,.registeredAt,.registeredBy)' \
                              > new-taskdef.json

                            aws ecs register-task-definition --region $AWS_REGION --cli-input-json file://new-taskdef.json
                            aws ecs update-service --region $AWS_REGION --cluster $ECS_CLUSTER --service $ECS_SERVICE --force-new-deployment
                            '''
                        }
                    }
                }

                stage('Azure') {
                    steps {
                        withCredentials([usernamePassword(credentialsId: 'azure-sp-cred', usernameVariable: 'AZ_CLIENT_ID', passwordVariable: 'AZ_CLIENT_SECRET')]) {
                            sh '''
                            # Push to ACR
                            az login --service-principal -u $AZ_CLIENT_ID -p $AZ_CLIENT_SECRET --tenant $AZURE_TENANT
                            az acr login --name $AZURE_ACR

                            AZURE_IMAGE_URI=$AZURE_ACR.azurecr.io/${IMAGE_NAME}:${BUILD_TAG}
                            docker tag ${IMAGE_NAME}:${BUILD_TAG} $AZURE_IMAGE_URI
                            docker push $AZURE_IMAGE_URI

                            # Deploy to Container App
                            az containerapp update \
                              --name $AZURE_CONTAINER_APP \
                              --resource-group $AZURE_RESOURCE_GROUP \
                              --image $AZURE_IMAGE_URI \
                              --environment $AZURE_CONTAINER_APP-env
                            '''
                        }
                    }
                }
            }
        }
    }
}

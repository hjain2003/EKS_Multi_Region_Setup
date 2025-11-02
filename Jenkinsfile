pipeline {
    agent any

    environment {
        AWS_ACCOUNT_ID        = '302263069749'                // your AWS account
        IMAGE_EAST            = 'east-post'
        IMAGE_WEST            = 'west-post'
        ECR_REPO_EAST         = "${AWS_ACCOUNT_ID}.dkr.ecr.ap-south-1.amazonaws.com/${IMAGE_EAST}"
        ECR_REPO_WEST         = "${AWS_ACCOUNT_ID}.dkr.ecr.us-west-1.amazonaws.com/${IMAGE_WEST}"
        PRIMARY_REGION        = 'ap-south-1'
        SECONDARY_REGION      = 'us-west-1'
        K8S_DIR               = 'k8s'                         // path to your manifests
    }

    stages {

        stage('Checkout Code') {
            steps {
                git branch: 'master', url: 'https://github.com/hjain2003/EKS_Multi_Region_Setup'
            }
        }

        stage('Login to AWS') {
            steps {
                sh "aws sts get-caller-identity"
            }
        }

        stage('Build Docker Images') {
            steps {
                script {
                    sh """
                    docker build -t ${IMAGE_EAST}:latest .
                    docker tag ${IMAGE_EAST}:latest ${IMAGE_WEST}:latest
                    """
                }
            }
        }

        stage('Push to ECR - Primary (East)') {
            steps {
                script {
                    sh """
                    aws ecr get-login-password --region ${PRIMARY_REGION} | docker login --username AWS --password-stdin ${ECR_REPO_EAST}
                    docker tag ${IMAGE_EAST}:latest ${ECR_REPO_EAST}:latest
                    docker push ${ECR_REPO_EAST}:latest
                    """
                }
            }
        }

        stage('Push to ECR - Secondary (West)') {
            steps {
                script {
                    sh """
                    aws ecr get-login-password --region ${SECONDARY_REGION} | docker login --username AWS --password-stdin ${ECR_REPO_WEST}
                    docker tag ${IMAGE_WEST}:latest ${ECR_REPO_WEST}:latest
                    docker push ${ECR_REPO_WEST}:latest
                    """
                }
            }
        }

        stage('Deploy to EKS - Primary (East)') {
            steps {
                script {
                    sh """
                    aws eks update-kubeconfig --region ${PRIMARY_REGION} --name mern-eks-cluster-east
                    kubectl apply -f ${K8S_DIR}/
                    """
                }
            }
        }

        stage('Approval for Secondary (West)') {
            steps {
                input message: "Approve deployment to Secondary (us-west-1)?"
            }
        }

        stage('Deploy to EKS - Secondary (West)') {
            steps {
                script {
                    sh """
                    aws eks update-kubeconfig --region ${SECONDARY_REGION} --name mern-eks-cluster-west
                    kubectl apply -f ${K8S_DIR}/
                    """
                }
            }
        }
    }

    post {
        failure {
            echo "Pipeline failed. Fix it before your clusters start missing each other."
        }
        success {
            echo "Both east-post and west-post images deployed successfully."
        }
    }
}

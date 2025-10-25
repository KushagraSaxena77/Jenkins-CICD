pipeline {
    agent any

    environment {
        IMAGE_NAME = "kushagrasaxena77/demo-app"
        DOCKER_REGISTRY = "docker.io"
        // Expects a Jenkins username/password credential with id 'docker-hub-credentials-id'
        DOCKER_HUB_CREDENTIALS = credentials('docker-hub-credentials-id')
    }

    stages {
        stage('Checkout') {
            steps {
                echo "Checking out code..."
                deleteDir()
                checkout scm
            }
        }

        stage('Set Image Tag') {
            steps {
                script {
                    // Use short git SHA + build number for immutability
                    def shortSha = sh(script: "git rev-parse --short HEAD", returnStdout: true).trim()
                    env.IMAGE_TAG = "${shortSha}-${env.BUILD_NUMBER}"
                    echo "IMAGE_TAG=${env.IMAGE_TAG}"
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                echo "Building Docker image ${IMAGE_NAME}:${IMAGE_TAG}..."
                sh "docker build -t ${IMAGE_NAME}:${IMAGE_TAG} ."
            }
        }

        stage('Push Docker Image') {
            steps {
                echo "Pushing Docker image to ${DOCKER_REGISTRY}..."
                sh '''
                    echo ${DOCKER_HUB_CREDENTIALS_PSW} | docker login -u ${DOCKER_HUB_CREDENTIALS_USR} --password-stdin ${DOCKER_REGISTRY}
                    docker push ${IMAGE_NAME}:${IMAGE_TAG}
                    docker logout ${DOCKER_REGISTRY}
                '''
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                echo "Deploying ${IMAGE_NAME}:${IMAGE_TAG} to Kubernetes..."
                // Requires a Jenkins file credential containing kubeconfig with id 'kubeconfig'
                withCredentials([file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG_FILE')]) {
                    sh '''
                        export KUBECONFIG=$KUBECONFIG_FILE
                        export IMAGE_NAME='${IMAGE_NAME}'
                        export IMAGE_TAG='${IMAGE_TAG}'
                        # Use envsubst so deployment.yaml can include ${IMAGE_NAME}:${IMAGE_TAG}
                        envsubst < deployment.yaml | kubectl apply -f -
                        kubectl rollout status deployment/demo-app --timeout=120s
                    '''
                }
            }
        }

        stage('Smoke Test') {
            steps {
                echo 'Running cluster-side smoke test'
                withCredentials([file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG_FILE')]) {
                    sh '''
                        export KUBECONFIG=$KUBECONFIG_FILE
                        # Run a temporary pod that curls the service inside the cluster
                        kubectl run curl-test --rm --restart=Never --image=curlimages/curl --command -- curl -sS http://demo-app-svc:3000
                    '''
                }
            }
        }
    }

    post {
        always {
            echo "Pipeline finished."
            // best-effort cleanup of dangling images on agent
            sh 'docker image prune -f || true'
        }
        failure {
            echo "Pipeline failed. Check logs for details."
        }
    }
}

pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "myapp:latest"
        APP_NAME = "demo-app"
    }

    stages {
        stage('Checkout') {
            steps {
                echo "Checking out code from GitHub..."
                git branch: 'main', url: 'https://github.com/KushagraSaxena77/Jenkins-CICD.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                echo "Building Docker image..."
                sh "docker build -t ${DOCKER_IMAGE} ."
            }
        }

        stage('Run Docker Container') {
            steps {
                echo "Running Docker container..."
                sh """
                docker stop ${APP_NAME} || true
                docker rm ${APP_NAME} || true
                docker run -d --name ${APP_NAME} -p 8081:80 ${DOCKER_IMAGE}
                """
            }
        }

        stage('Test Container') {
            steps {
                echo "Checking running container..."
                sh "docker ps | grep ${APP_NAME}"
            }
        }
    }

    post {
        success {
            echo "Pipeline completed successfully!"
        }
        failure {
            echo "Pipeline failed!"
        }
        always {
            echo "Cleaning workspace..."
            cleanWs()
        }
    }
}

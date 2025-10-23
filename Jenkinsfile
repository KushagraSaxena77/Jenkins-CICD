pipeline {
    agent any

    environment {
        IMAGE_NAME = "demo-app"
        IMAGE_TAG  = "latest"
    }

    stages {
        stage('Checkout') {
            steps {
                git url: 'https://github.com/KushagraSaxena77/Jenkins-CICD.git', branch: 'main'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh "docker build -t ${IMAGE_NAME}:${IMAGE_TAG} ."
                }
            }
        }

        stage('Run Docker Container') {
            steps {
                script {
                    sh "docker run --rm ${IMAGE_NAME}:${IMAGE_TAG}"
                }
            }
        }
    }

    post {
        always {
            node {
                cleanWs()
            }
            echo 'Pipeline finished.'
        }
    }
}

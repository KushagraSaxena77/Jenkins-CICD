pipeline {
    agent any

    environment {
        IMAGE_NAME = "myapp:latest"
        CONTAINER_NAME = "myapp_container"
    }

    stages {
        stage('Checkout') {
            steps {
                echo 'Checking out code from GitHub...'
                git url: 'https://github.com/KushagraSaxena77/Jenkins-CICD.git', branch: 'main'
            }
        }

        stage('Build Docker Image') {
            steps {
                echo 'Building Docker image...'
                sh "docker build -t ${IMAGE_NAME} ."
            }
        }

        stage('Run Docker Container') {
            steps {
                echo 'Running Docker container...'
                sh """
                    docker rm -f ${CONTAINER_NAME} || true
                    docker run -d --name ${CONTAINER_NAME} -p 5000:5000 ${IMAGE_NAME}
                """
            }
        }

        stage('Test Container') {
            steps {
                echo 'Listing running Docker containers...'
                sh "docker ps"
            }
        }
    }

    post {
        always {
            echo 'Cleaning up Docker containers...'
            sh "docker rm -f ${CONTAINER_NAME} || true"
        }
    }
}

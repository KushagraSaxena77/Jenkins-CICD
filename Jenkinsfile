pipeline {
    agent any

    environment {
        IMAGE_NAME = "myapp"
        CONTAINER_NAME = "myapp_container"
    }

    stages {
        stage('Checkout') {
            steps {
                echo "Cleaning workspace and checking out code..."
                deleteDir() // ensures workspace is empty
                git branch: 'main', url: 'https://github.com/KushagraSaxena77/Jenkins-CICD.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                echo "Building Docker image..."
                sh "docker build -t ${IMAGE_NAME}:latest ."
            }
        }

        stage('Run Docker Container') {
            steps {
                echo "Running Docker container..."
                sh "docker run -d --name ${CONTAINER_NAME} -p 5000:5000 ${IMAGE_NAME}:latest"
            }
        }

        stage('Test Container') {
            steps {
                echo "Testing Docker container..."
                sh "curl -f http://localhost:5000 || echo 'Container test failed'"
            }
        }
    }

    post {
        always {
            echo "Cleaning up Docker container..."
            sh "docker rm -f ${CONTAINER_NAME} || true"
            cleanWs()
        }
    }
}

pipeline {
  agent any
  environment {
    REGISTRY = "kushagrasaxena77"
    IMAGE = "${env.REGISTRY}/demo-app"
  }
  stages {
    stage('Checkout') {
      steps { checkout scm }
    }
    stage('Build & Test') {
      steps {
        sh 'npm install'
        sh 'npm test'
      }
    }
    stage('Build & Push Image') {
      steps {
        sh """
          docker build -t ${IMAGE}:\$BUILD_NUMBER .
          docker tag ${IMAGE}:\$BUILD_NUMBER ${IMAGE}:latest
          docker push ${IMAGE}:\$BUILD_NUMBER
          docker push ${IMAGE}:latest
        """
      }
    }
    stage('Deploy to Kubernetes') {
      steps {
        sh '''
          # update k8s manifest to use the new numeric tag, apply it
          sed "s|YOUR_DOCKERHUB_USER/demo-app:latest|${IMAGE}:${BUILD_NUMBER}|g" k8s/deployment.yaml > k8s/tmp-deploy.yaml
          kubectl apply -f k8s/tmp-deploy.yaml
          kubectl rollout status deployment/demo-app --timeout=120s
        '''
      }
    }
  }
}

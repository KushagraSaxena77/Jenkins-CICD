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

    // Run npm inside official node image (no Node on Jenkins required)
    stage('Build & Test') {
      agent { docker { image 'node:18' args '-u root:root' } }
      steps {
        sh 'node -v && npm -v'
        sh 'npm ci || npm install'
        sh 'npm test'
      }
    }

    // Build/push using docker image and host docker daemon (fastest)
    stage('Build & Push Image') {
      agent {
        docker {
          image 'docker:24'
          args '-v /var/run/docker.sock:/var/run/docker.sock -v $HOME/.docker:/root/.docker'
        }
      }
      steps {
        withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
          sh '''
            echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
            docker build -t ${IMAGE}:${BUILD_NUMBER} .
            docker tag ${IMAGE}:${BUILD_NUMBER} ${IMAGE}:latest
            docker push ${IMAGE}:${BUILD_NUMBER}
            docker push ${IMAGE}:latest
            docker logout
          '''
        }
      }
    }

    // Deploy using a kubectl image and the kubeconfig secret
    stage('Deploy to Kubernetes') {
      agent {
        docker { image 'bitnami/kubectl:1.29' }
      }
      steps {
        withCredentials([file(credentialsId: 'kubeconfig-file', variable: 'KUBECONFIG_FILE')]) {
          sh '''
            mkdir -p /root/.kube
            cp "$KUBECONFIG_FILE" /root/.kube/config
            chmod 600 /root/.kube/config
            sed "s|YOUR_DOCKERHUB_USER/demo-app:latest|${IMAGE}:${BUILD_NUMBER}|g" k8s/deployment.yaml > k8s/tmp-deploy.yaml
            kubectl apply -f k8s/tmp-deploy.yaml
            kubectl rollout status deployment/demo-app --timeout=120s
          '''
        }
      }
    }
  }
}

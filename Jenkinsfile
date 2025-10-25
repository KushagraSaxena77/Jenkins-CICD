// Declarative Jenkins pipeline to build, push Docker image and deploy to Kubernetes
pipeline {
  agent any

  environment {
    // Set defaults, can be overridden from Jenkins job parameters
    IMAGE_NAME = "${params.IMAGE_NAME ?: 'kushagrasaxena77/demo-app'}"
    NAMESPACE = "${params.NAMESPACE ?: 'default'}"
  }

  parameters {
    string(name: 'IMAGE_NAME', defaultValue: 'kushagrasaxena77/demo-app', description: 'Full image name (e.g. user/repo)')
    string(name: 'IMAGE_TAG', defaultValue: '', description: 'Optional tag (defaults to short-git-sha-BUILD_NUMBER)')
    string(name: 'NAMESPACE', defaultValue: 'default', description: 'Kubernetes namespace')
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Set image tag') {
      steps {
        script {
          SHORT_SHA = sh(returnStdout: true, script: 'git rev-parse --short HEAD || echo local').trim()
          if (!params.IMAGE_TAG?.trim()) {
            IMAGE_TAG = "${SHORT_SHA}-${env.BUILD_NUMBER}"
          } else {
            IMAGE_TAG = params.IMAGE_TAG
          }
          echo "Using image: ${IMAGE_NAME}:${IMAGE_TAG}"
        }
      }
    }

    stage('Build') {
      steps {
        sh 'docker build -t ${IMAGE_NAME}:${IMAGE_TAG} .'
      }
    }

    stage('Push') {
      environment {
        // Expect a Username/Password credential with id 'docker-hub-credentials-id'
      }
      steps {
        withCredentials([usernamePassword(credentialsId: 'docker-hub-credentials-id', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
          sh 'echo ${DOCKER_PASS} | docker login -u ${DOCKER_USER} --password-stdin'
          sh 'docker push ${IMAGE_NAME}:${IMAGE_TAG}'
          sh 'docker logout || true'
        }
      }
    }

    stage('Deploy to Kubernetes') {
      steps {
        // Use the kubeconfig file stored as a secret file credential (id: kubeconfig)
        withCredentials([file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG_FILE')]) {
          sh '''
          mkdir -p $WORKSPACE/.kube
          cp "$KUBECONFIG_FILE" $WORKSPACE/.kube/config
          export KUBECONFIG=$WORKSPACE/.kube/config
          echo "Deploying ${IMAGE_NAME}:${IMAGE_TAG} to namespace ${NAMESPACE}"
          envsubst < deployment.yaml | kubectl apply -n ${NAMESPACE} -f -
          kubectl rollout status deployment/demo-app -n ${NAMESPACE} --timeout=120s
          '''
        }
      }
    }

    stage('Smoke test') {
      steps {
        withCredentials([file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG_FILE')]) {
          sh '''
          export KUBECONFIG=$KUBECONFIG_FILE
          kubectl run curl-test --rm --restart=Never --image=curlimages/curl --namespace ${NAMESPACE} --command -- curl -sS http://demo-app-svc:3000
          '''
        }
      }
    }
  }

  post {
    always {
      echo "Pipeline finished"
      sh 'docker image prune -f || true'
    }
    failure {
      echo "Pipeline failed. Check logs for details."
    }
  }
}

<<<<<<< HEAD
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
    }
  }
=======
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
>>>>>>> 9eac8d7a082bd601510aacec7907fc0f38a7e069
}

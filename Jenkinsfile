pipeline {
  agent any

  environment {
    IMAGE = "vidya125/html-ci:latest"
    DOCKERHUB_CREDS = "docker_creds"       // replace with actual Jenkins credential id
    KUBECONFIG_FILE = "kubeconfig-file"       // replace with actual Jenkins file cred id
  }

  stages {

    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Build Docker Image') {
      steps {
        script {
          sh "docker build -t ${env.IMAGE} ."
        }
      }
    }

    stage('Login & Push Image') {
      steps {
        withCredentials([usernamePassword(credentialsId: env.DOCKERHUB_CREDS, usernameVariable: 'DH_USER', passwordVariable: 'DH_PASS')]) {
          sh '''
            echo "$DH_PASS" | docker login -u "$DH_USER" --password-stdin
            docker push ${IMAGE}
          '''
        }
      }
    }

    stage('Deploy to Kubernetes') {
      steps {
        // write secret-file kubeconfig to $KUBECONFIG and use kubectl
        withCredentials([file(credentialsId: env.KUBECONFIG_FILE, variable: 'KCFG')]) {
          sh '''
            export KUBECONFIG=${KCFG}
            # Replace image in manifest and apply
            sed "s#YOUR_DOCKERHUB_ID/html-ci:latest#${IMAGE}#g" k8s-deploy.yaml > /tmp/manifest.yaml
            kubectl apply -f /tmp/manifest.yaml
            kubectl rollout status deployment/html-ci --timeout=120s || kubectl describe deployment/html-ci
          '''
        }
      }
    }
  }

  post {
    always {
      sh 'kubectl get pods -o wide || true'
    }
  }
}

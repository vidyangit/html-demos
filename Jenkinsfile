pipeline {
    agent any

    stages {

        stage('Clone Code') {
            steps {
                checkout scm
            }
        }

        stage('Build Image with Commit Tag') {
            steps {
                script {
                    COMMIT = sh(
                        script: "git rev-parse --short HEAD",
                        returnStdout: true
                    ).trim()

                    env.IMAGE = "vidya125/html-ci:${COMMIT}"

                    sh "docker build -t ${IMAGE} ."
                }
            }
        }

        stage('Push to Docker Hub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'USER', passwordVariable: 'PASS')]) {
                    sh """
                        echo "$PASS" | docker login -u "$USER" --password-stdin
                        docker push ${IMAGE}
                    """
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                withCredentials([file(credentialsId: 'kubeconfig-file', variable: 'KCFG')]) {
                    sh """
                        export KUBECONFIG=$KCFG
                        kubectl set image deployment/html-ci html-ci=${IMAGE}
                        kubectl rollout status deployment/html-ci
                    """
                }
            }
        }
    }
}

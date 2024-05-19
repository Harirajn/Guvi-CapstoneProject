pipeline {
    agent any

    environment {
        DOCKER_DEV_REPO = 'harirajn/dev'
        DOCKER_PROD_REPO = 'harirajn/prod'
        DOCKER_CREDENTIALS_ID = 'harirajn-dockerhub'
        EC2_SSH_CREDENTIALS_ID = 'ec2-instance-ssh'
        EC2_HOST = '52.39.1.129'
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
                    def branch = env.GIT_BRANCH.split('/').last()
                    if (branch == 'dev' || branch == 'master') {
                        dockerImage = docker.build("${DOCKER_DEV_REPO}:${env.BUILD_NUMBER}")
                    }
                }
            }
        }

        stage('Push Docker Image to Dev Repo') {
            when {
                branch 'dev'
            }
            steps {
                script {
                    docker.withRegistry('https://index.docker.io/v1/', DOCKER_CREDENTIALS_ID) {
                        dockerImage.push("${env.BUILD_NUMBER}")
                    }
                }
            }
        }

        stage('Push Docker Image to Prod Repo') {
            when {
                branch 'master'
            }
            steps {
                script {
                    docker.withRegistry('https://index.docker.io/v1/', DOCKER_CREDENTIALS_ID) {
                        def prodImage = docker.build("${DOCKER_PROD_REPO}:${env.BUILD_NUMBER}")
                        prodImage.push("${env.BUILD_NUMBER}")
                    }
                }
            }
        }

        stage('Deploy to EC2') {
            when {
                branch 'master'
            }
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: DOCKER_CREDENTIALS_ID, usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                        sshagent(credentials: [EC2_SSH_CREDENTIALS_ID]) {
                            sh """
                            ssh -o StrictHostKeyChecking=no ubuntu@${EC2_HOST} 'echo "${DOCKER_PASSWORD}" | docker login -u "${DOCKER_USERNAME}" --password-stdin'
                            ssh -o StrictHostKeyChecking=no ubuntu@${EC2_HOST} 'docker pull ${DOCKER_PROD_REPO}:${env.BUILD_NUMBER}'
                            ssh -o StrictHostKeyChecking=no ubuntu@${EC2_HOST} 'docker stop online-store || true'
                            ssh -o StrictHostKeyChecking=no ubuntu@${EC2_HOST} 'docker rm online-store || true'
                            ssh -o StrictHostKeyChecking=no ubuntu@${EC2_HOST} 'docker run -d --name online-store -p 80:80 ${DOCKER_PROD_REPO}:${env.BUILD_NUMBER}'
                            """
                        }
                    }
                }
            }
        }
    }

    post {
        always {
            cleanWs()
        }
        failure {
            script {
                echo "Build failed! Cleaning up Docker images."
                sh "docker rmi ${DOCKER_DEV_REPO}:${env.BUILD_NUMBER} || true"
                sh "docker rmi ${DOCKER_PROD_REPO}:${env.BUILD_NUMBER} || true"
            }
        }
    }
}

pipeline {
    agent any

    stages {
        stage('Build and Push Dev Image') {
            when {
                branch 'dev'
            }
            steps {
                script {
                    docker.build("harirajn/dev:${env.BUILD_NUMBER}")
                    docker.withRegistry('https://registry.hub.docker.com', 'harirajn-dockerhub') {
                        docker.image("harirajn/dev:${env.BUILD_NUMBER}").push()
                    }
                }
            }
        }
    }

    post {
        success {
            script {
                if (env.BRANCH_NAME == 'master') {
                    docker.build("harirajn/prod:${env.BUILD_NUMBER}")
                    docker.withRegistry('https://registry.hub.docker.com', 'harirajn-dockerhub') {
                        docker.image("harirajn/prod:${env.BUILD_NUMBER}").push()
                    }
                }
            }
        }
    }
}

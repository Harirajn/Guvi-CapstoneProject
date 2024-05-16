pipeline {
    agent any

    stages {
        stage('Build and Push Dev Image') {
            when {
                branch 'dev'
            }
            steps {
                script {
                    docker.build("dev/online-store:${env.BUILD_NUMBER}")
                    docker.withRegistry('https://registry.hub.docker.com', 'harirajn-dockerhub') {
                        docker.image("dev/online-store:${env.BUILD_NUMBER}").push()
                    }
                }
            }
        }
    }

    post {
        success {
            script {
                if (env.BRANCH_NAME == 'master') {
                    docker.build("prod/online_store:${env.BUILD_NUMBER}")
                    docker.withRegistry('https://registry.hub.docker.com', 'harirajn-dockerhub') {
                        docker.image("prod/online_store:${env.BUILD_NUMBER}").push()
                    }
                }
            }
        }
    }
}

pipeline {
    agent any

    stages {
        stage('Build and Push Dev Image') {
            when {
                branch 'dev'
            }
            steps {
                script {
                    docker.build("yourdevrepository/yourapp:${env.BUILD_NUMBER}")
                    docker.withRegistry('https://registry.hub.docker.com', 'harirajn-dockerhub') {
                        docker.image("harirajn/dev:${env.BUILD_NUMBER}").push()
                    }
                }
            }
        }
        stage('Deploy to Prod') {
            when {
                expression { 
                    return (env.BRANCH_NAME == 'master' && currentBuild.changeSets.any { it.branch == 'origin/dev' })
                }
            }
            steps {
                script {
                    docker.withRegistry('https://registry.hub.docker.com', 'harirajn-dockerhub') {
                        docker.image("harirajn/prod:${env.BUILD_NUMBER}").push()
                    }
                }
            }
        }
    }
}

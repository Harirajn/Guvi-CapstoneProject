pipeline {
    agent any
    environment {
        DOCKER_HUB_CREDENTIALS = 'harirajn-dockerhub'
    }
    stages {
        stage('Build and Push Dev Image') {
            when {
                branch 'dev'
            }
            steps {
                script {
                    def devImage = docker.build("harirajn/dev:${env.BUILD_NUMBER}")
                    docker.withRegistry('https://registry.hub.docker.com', "${DOCKER_HUB_CREDENTIALS}") {
                        devImage.push()
                    }
                }
            }
        }
        stage('Deploy to Prod') {
            when {
                branch 'master'
            }
            steps {
                script {
                    // Check if the merge commit contains changes from the dev branch
                    def isMergedFromDev = false
                    currentBuild.changeSets.each { changeSet ->
                        changeSet.items.each { item ->
                            if (item.affectedFiles.any { it.path.contains('dev') }) {
                                isMergedFromDev = true
                            }
                        }
                    }
                    
                    if (isMergedFromDev) {
                        def prodImage = docker.image("harirajn/dev:${env.BUILD_NUMBER}")
                        prodImage.tag("harirajn/prod:${env.BUILD_NUMBER}")
                        docker.withRegistry('https://registry.hub.docker.com', "${DOCKER_HUB_CREDENTIALS}") {
                            prodImage.push("harirajn/prod:${env.BUILD_NUMBER}")
                        }
                    } else {
                        echo "No changes from dev branch detected in this merge to master."
                    }
                }
            }
        }
    }
}
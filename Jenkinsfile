pipeline {
    agent any
    environment {
        DOCKER_HUB_CREDENTIALS = 'harirajn-dockerhub'
        EC2_INSTANCE_IP = '18.246.241.76'
        EC2_INSTANCE_USER = 'ubuntu'
        EC2_INSTANCE_KEY = 'ec2-instance-ssh'
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

                        // SSH into the EC2 instance and deploy the prod image
                        sshagent(credentials: [EC2_INSTANCE_KEY]) {
                            sh """
                                ssh -o StrictHostKeyChecking=no ${EC2_INSTANCE_USER}@${EC2_INSTANCE_IP} '
                                    docker pull harirajn/prod:${env.BUILD_NUMBER} &&
                                    docker stop my_container && docker rm my_container || true &&
                                    docker run -d --name my_container -p 80:80 harirajn/prod:${env.BUILD_NUMBER}
                                '
                            """
                        }
                    } else {
                        echo "No changes from dev branch detected in this merge to master."
                        sshagent(['EC2_INSTANCE_KEY']) {
                            sh "ssh -o StrictHostKeyChecking=no -i ${EC2_INSTANCE_KEY} ${EC2_INSTANCE_USER}@${EC2_INSTANCE_IP} 'docker pull harirajn/prod:${env.BUILD_NUMBER}'"
                            sh "ssh -o StrictHostKeyChecking=no -i ${EC2_INSTANCE_KEY} ${EC2_INSTANCE_USER}@${EC2_INSTANCE_IP} 'docker stop <container_id> && docker rm <container_id> || true'"
                            sh "ssh -o StrictHostKeyChecking=no -i ${EC2_INSTANCE_KEY} ${EC2_INSTANCE_USER}@${EC2_INSTANCE_IP} 'docker run -d --name my_container -p 80:80 harirajn/prod:${env.BUILD_NUMBER}'"
                        }
                    } else {
                        echo "No changes from dev branch detected in this merge to master brach."
                    }
                }
            }
        }
    }
}

pipeline {
    agent {label 'ubuntu_1'}
    environment{
        // --- Nexus Settings ---
        NEXUS_REPO_URL = 'http://34.174.105.234:8081/repository/maven-releases/' // Replace with your Nexus releases repo URL
        //NEXUS_SNAPSHOT_REPO_URL = 'http://your-nexus-ip:8081/repository/maven-snapshots' // Replace with your Nexus snapshots repo URL
        NEXUS_CREDENTIAL_ID = 'nexus-jenkins'

        // --- Docker Settings ---
        DOCKER_IMAGE_NAME = "hello-world-app" // e.g., "myuser/my-java-app"
        DOCKER_REGISTRY_URL = '34.174.105.234:8082/repository/docker-demo' // Or your private registry URL, e.g., 'your-private-registry:5000'
        //DOCKER_REGISTRY_CRED_ID = 'docker-server' // Jenkins credential ID for Docker Hub/Registry
        DOCKER_IMAGE_VERSION = '1.1.4'
        DOCKER_IMAGE_FULL_VERSION_TAG = "${DOCKER_REGISTRY_URL}/${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_VERSION}"
    }

    stages {
        stage ('Checkout SCM'){
            steps {
                cleanWs()
                echo 'checkout process'

                git branch: 'dev-jenkins', url: 'https://github.com/devopspractise-25/maven-demo.git'
                sh 'ls -l'     
            }

            
        }

        stage ('Build'){
            steps {
            echo 'maven build'
            withMaven(globalMavenSettingsConfig: '', jdk: '', maven: 'maven', mavenSettingsConfig: '6a8c26a2-0584-48f1-9a26-507a9479831a', traceability: true) {
            sh 'mvn clean install -DskipTests'  
            } 
            }
        }
        stage ('SonarQube Scan'){
            steps{
                echo "SonarQube Scanning started"
                withSonarQubeEnv(installationName: 'sonar', credentialsId: 'admin-sonar') {
                    sh """
                        sonar-scanner \\
                        -Dsonar.projectKey=hello-world-war \\
                        -Dsonar.sources=. \\
                        -Dsonar.token=${env.SONAR_AUTH_TOKEN} \\
                        -Dsonar.host.url=${env.SONAR_HOST_URL} \\
                        -Dsonar.java.binaries=target/classes
                        # Add other properties as needed, e.g., -Dsonar.java.binaries=target/classes
                    """
                }
            }
        }
        stage ('Docker Build'){
            steps {
                script {
                    sh 'ls -lrth'
                    def customImage = docker.build(DOCKER_IMAGE_FULL_VERSION_TAG, '.')
                    echo "Built Docker image: ${customImage.id}"
                }
            }
        }
        stage('Push Docker Image to Nexus') {
            steps {
                script {
                    // Authenticate with Nexus Docker Registry using Jenkins credentials
                    echo "pushing docker image to nexus regsitry"
                    //docker.withRegistry("http://${DOCKER_REGISTRY_URL}", ${NEXUS_CREDENTIAL_ID}) {
                    docker.withRegistry("http://${DOCKER_REGISTRY_URL}", 'nexus-jenkins') {
                        // Build the image again (or reference the previously built one if using an 'agent none' for stages)
                        // For simplicity, let's assume agent any, so we rebuild for this stage
                        def customImage = docker.build(DOCKER_IMAGE_FULL_VERSION_TAG, '.')

                        // Push the uniquely tagged image
                        customImage.push()
                        echo "Pushed Docker image: ${DOCKER_IMAGE_FULL_VERSION_TAG}"

                        // Optionally, tag and push as 'latest'
                        // customImage.addTag('latest')
                        // customImage.push('latest')
                        // echo "Also tagged and pushed as: ${DOCKER_IMAGE_VERSION}"
                    }
                }
            }
        }
        stage ('Kubernetes Deploy') {
            steps {
                sh 'chmod +x ./kube_deploy.sh'
                sh './kube_deploy.sh'
            }
        }
        // stage ('Nexus .war Upload'){
        //     steps{
        //         echo "Uploading artifact to nexus repository"
        //         nexusArtifactUploader artifacts: [[artifactId: 'hello-world-war-1.1.4', classifier: '', file: 'target/hello-world-war-1.1.4.war', type: 'war']], credentialsId: 'nexus-jenkins', groupId: 'com.efsavage', nexusUrl: '34.174.105.234:8081', nexusVersion: 'nexus3', protocol: 'http', repository: 'maven-releases', version: '1.1.4'
        //         //withCredentials([usernamePassword(credentialsId: env.NEXUS_CREDENTIAL_ID, passwordVariable: 'NEXUS_PASSWORD', usernameVariable: 'NEXUS_USERNAME')]) {
        //             // This uses mvn deploy. Ensure your pom.xml has <distributionManagement> configured
        //             // Or you can use -DaltDeploymentRepository as shown below (replace placeholders)
        //             //sh "mvn deploy -DskipTests -DaltDeploymentRepository=nexus-releases::default::${env.NEXUS_REPO_URL} -DrepositoryId=nexus-releases"
        //         //}
        //     }
        // }
        // stage ('Nexus docker image Upload'){
        //     steps{
        //         echo "Uploading artifact to nexus repository"
        //         nexusArtifactUploader artifacts: [[artifactId: 'hello-world-war-1.1.4', classifier: '', file: 'target/hello-world-war-1.1.4.war', type: 'war']], credentialsId: 'nexus-jenkins', groupId: 'com.efsavage', nexusUrl: '34.174.105.234:8081', nexusVersion: 'nexus3', protocol: 'http', repository: 'maven-releases', version: '1.1.4'
        //         //withCredentials([usernamePassword(credentialsId: env.NEXUS_CREDENTIAL_ID, passwordVariable: 'NEXUS_PASSWORD', usernameVariable: 'NEXUS_USERNAME')]) {
        //             // This uses mvn deploy. Ensure your pom.xml has <distributionManagement> configured
        //             // Or you can use -DaltDeploymentRepository as shown below (replace placeholders)
        //             //sh "mvn deploy -DskipTests -DaltDeploymentRepository=nexus-releases::default::${env.NEXUS_REPO_URL} -DrepositoryId=nexus-releases"
        //         //}
        //     }
        // }
    }
}
pipeline {
    agent {label 'ubuntu_1'}

    stages {
        stage ('Checkout SCM'){
            steps {
                cleanWs()
                echo 'checkout process'

                git 'https://github.com/devopspractise-25/maven-demo.git'    
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
                echo "SonarQube Scannin started"
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
        stage ('Nexus Upload'){
            steps{
                echo "Uploading artifact to nexus repository"
                nexusArtifactUploader credentialsId: 'nexus-jenkins', groupId: 'com.efsavage', nexusUrl: '34.174.105.234:8081', nexusVersion: 'nexus3', protocol: 'http', repository: 'maven-releases', version: '1.1.4'
            }
        }
    }
}
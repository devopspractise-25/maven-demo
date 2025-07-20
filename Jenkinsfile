// Jenkinsfile

pipeline {
    agent { label 'ubuntu_1' } // Or a specific agent if you have labels (e.g., agent { label 'minikube-agent' })

    environment {
        // --- General Settings ---
        GIT_REPO_URL = 'https://github.com/devopspractise-25/maven-demo.git' // Replace with your GitHub repo URL
        //GIT_CREDENTIAL_ID = 'GitHub_Jenkins' // Jenkins credential ID for GitHub (Username/Password or SSH Key)

        // --- Maven Settings ---
        MAVEN_SETTINGS_XML = 'MyNexusSettings' // Jenkins Config File Provider ID for settings.xml if needed for Nexus auth
        MAVEN_TOOL_NAME = 'Maven 3.8.8' // Replace with your Maven tool name configured in Jenkins Global Tool Configuration

        // --- SonarQube Settings ---
        SONARQUBE_SERVER_ID = 'sonar' // Name of your SonarQube server configured in Jenkins
        // SONAR_PROJECT_KEY = 'your-org_your-project' // Optional: If you want to explicitly define the project key

        // --- Nexus Settings ---
        NEXUS_REPO_URL = 'http://34.174.105.234:8081/repository/maven-releases/' // Replace with your Nexus releases repo URL
        //NEXUS_SNAPSHOT_REPO_URL = 'http://your-nexus-ip:8081/repository/maven-snapshots' // Replace with your Nexus snapshots repo URL
        NEXUS_CREDENTIAL_ID = 'nexus-jenkins' // Jenkins credential ID for Nexus (Username/Password)

        // --- Docker Settings ---
        DOCKER_IMAGE_NAME = "devopspractise25/hello-world-app" // e.g., "myuser/my-java-app"
        DOCKER_REGISTRY_URL = '34.174.105.234:8082/repository/docker-demo' // Or your private registry URL, e.g., 'your-private-registry:5000'
        DOCKER_REGISTRY_CRED_ID = 'docker-server' // Jenkins credential ID for Docker Hub/Registry

        // --- Kubernetes Settings ---
        K8S_DEPLOYMENT_FILE = 'my-app-deployment.yaml' // Path to your K8s deployment file in your repo
        K8S_SERVICE_FILE = 'my-app-service.yaml' // Path to your K8s service file in your repo
        MINIKUBE_EXTERNAL_PORT = '80' // The port on the GCP VM you want to expose
        MINIKUBE_NODE_PORT = '30000' // Your Kubernetes NodePort
    }

    stages {
        stage('Checkout SCM') {
            steps {
                echo 'Checking out code from GitHub...'
                git branch: 'main', credentialsId: env.GIT_CREDENTIAL_ID, url: env.GIT_REPO_URL
            }
        }

        stage('Maven Build') {
            steps {
                echo 'Building .jar file with Maven...'
                withMaven(maven: env.MAVEN_TOOL_NAME, mavenSettingsConfig: env.MAVEN_SETTINGS_XML) { // Use mavenSettingsConfig if you have a custom settings.xml for Nexus
                    sh 'mvn clean install -DskipTests'
                }
            }
        }

        stage('SonarQube Scan') {
            steps {
                echo 'Running SonarQube analysis...'
                // Ensure SonarQube Scanner for Jenkins plugin is installed and configured
                // The 'withSonarQubeEnv' step injects necessary environment variables
                withSonarQubeEnv(env.SONARQUBE_SERVER_ID) {
                    sh "mvn org.sonarsource.scanner.maven:sonar-maven-plugin:sonar -Dsonar.projectKey=${env.JOB_NAME} -Dsonar.sources=."
                    // Adjust sonar.projectKey as needed, JOB_NAME is a Jenkins built-in var
                }
            }
            post {
                always {
                    echo 'Checking SonarQube Quality Gate status (optional, but recommended).'
                    // This step pauses the pipeline until Quality Gate status is retrieved or timeout
                    // Requires SonarQube Scanner for Jenkins plugin
                    script {
                        def qualityGate = waitForQualityGate()
                        if (qualityGate.status != 'OK') {
                            error "SonarQube Quality Gate failed: ${qualityGate.status}"
                        }
                    }
                }
            }
        }

        stage('Upload Artifact to Nexus') {
            steps {
                echo 'Uploading .jar artifact to Nexus...'
                withCredentials([usernamePassword(credentialsId: env.NEXUS_CREDENTIAL_ID, passwordVariable: 'NEXUS_PASSWORD', usernameVariable: 'NEXUS_USERNAME')]) {
                    // This uses mvn deploy. Ensure your pom.xml has <distributionManagement> configured
                    // Or you can use -DaltDeploymentRepository as shown below (replace placeholders)
                    sh "mvn deploy -DskipTests -DaltDeploymentRepository=nexus-releases::default::${env.NEXUS_REPO_URL} -DrepositoryId=nexus-releases"
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                echo 'Building Docker image from artifact...'
                script {
                    def appImage = docker.build("${env.DOCKER_IMAGE_NAME}:${env.BUILD_NUMBER}", ".")
                    // Push image to registry (e.g., Docker Hub)
                    docker.withRegistry(env.DOCKER_REGISTRY_URL, env.DOCKER_REGISTRY_CRED_ID) {
                        appImage.push()
                        appImage.push('latest') // Optional: push as latest too
                    }
                    // You might want to tag the image with the Git commit hash for better traceability
                    // def gitCommit = sh(returnStdout: true, script: 'git rev-parse HEAD').trim()
                    // docker.build("${env.DOCKER_IMAGE_NAME}:${gitCommit}", ".").push()
                }
            }
        }

        stage('Deploy to Kubernetes (Minikube)') {
            steps {
                echo 'Ensuring Minikube is ready and deploying to Kubernetes...'
                script {
                    // IMPORTANT: Running delete/start in every pipeline build is SLOW and resource-intensive.
                    // For production, you'd typically have a persistent Minikube, or use a cloud K8s.
                    // However, for clean state given past issues, we'll include it.

                    sh "minikube stop || true" // Stop if running, ignore error if not
                    sh "minikube delete --all --purge || true" // Delete, ignore errors
                    sh "rm -rf ~/.minikube ~/.kube || true" // Clean up local config, ignore errors

                    // Start Minikube with the port mapping that worked: Host Port 80 -> Container Port 30000
                    sh "minikube start --driver=docker --ports ${MINIKUBE_EXTERNAL_PORT}:${MINIKUBE_NODE_PORT}"

                    // Wait for Minikube to be fully ready (optional, but good for robustness)
                    sh 'kubectl wait --for=condition=ready pod -l k8s-app=kube-proxy -n kube-system --timeout=300s'
                    sh 'kubectl wait --for=condition=ready pod -l k8s-app=kube-dns -n kube-system --timeout=300s'

                    // Apply Kubernetes Deployment and Service
                    sh "kubectl apply -f ${K8S_DEPLOYMENT_FILE}"
                    sh "kubectl apply -f ${K8S_SERVICE_FILE}"

                    // Wait for deployment rollout to complete (optional, but recommended)
                    sh "kubectl rollout status deployment/your-application-deployment-name --timeout=300s"
                    // Replace 'your-application-deployment-name' with the actual name from your deployment.yaml
                }
            }
        }
    }

    post {
        always {
            echo 'Pipeline finished.'
            // You can add cleanup steps here, e.g., notify slack, archive artifacts
        }
        failure {
            echo 'Pipeline failed. Check logs for details.'
        }
        success {
            echo 'Pipeline succeeded!'
        }
    }
}
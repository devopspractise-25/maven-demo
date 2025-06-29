pipeline {
   agent {label 'Slave1'}
    stages {
        stage('Git Clone') {
            steps {
                // git 'https://github.com/c4devops/maven-helloworld.git'
                //git 'https://github.com/tejesh-be/maven-helloworld.git'
                git 'https://github.com/devopspractise-25/maven-demo.git'
            }
            
        }
        stage('Maven Build') {
            steps {
                sh 'mvn clean package' 
            }
            
        }
        stage('Deploying to Tomcat') {
            steps {
                // deploy adapters: [tomcat9(credentialsId: 'jenkins', path: '', url: 'http://34.125.40.9:8090/')], contextPath: 'pipeline', war: '**/*.war'
                //deploy adapters: [tomcat9(credentialsId: 'tomcat', path: '', url: 'http://34.133.143.255:8080/')], contextPath: 'pipeline', war: '**/*.war'
                deploy adapters: [tomcat9(credentialsId: 'Jenkins', path: '', url: 'http://34.31.94.92:8080/')], contextPath: 'devopsdemo1', war: '**/*.war'
           }
            
        }
        
    }
    
}

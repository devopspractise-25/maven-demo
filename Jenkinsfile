pipeline {
    agent {label 'Ubuntu_1'}

    stages {
        stage ('Checkout SCM'){
            git 'https://github.com/devopspractise-25/maven-demo.git'
        }

        stage ('Build'){
            echo 'maven build'
            withMaven(globalMavenSettingsConfig: '', jdk: '', maven: 'maven', mavenSettingsConfig: '6a8c26a2-0584-48f1-9a26-507a9479831a', traceability: true) {
            sh 'mvn clean install -DskipTests'   
            }
        }
    }
}
pipeline {
    agent any
    
    tools {
        maven 'M2_HOME'
        jdk 'JAVA_HOME'
    }
    
    stages {
        stage('Checkout') {
            steps {
                // REPOSITORY PUBLIC GARANTI
                git branch: 'main', 
                    url: 'https://github.com/spring-projects/spring-petclinic'
            }
        }
        
        stage('Build') {
            steps {
                sh 'mvn clean compile -DskipTests'
            }
        }
        
        stage('Package') {
            steps {
                sh 'mvn package -DskipTests'
                sh 'ls -la target/*.jar'
            }
        }
        
        stage('Archive') {
            steps {
                archiveArtifacts 'target/*.jar'
                echo '📦 JAR créé avec succès!'
            }
        }
    }
    
    post {
        success {
            echo '🎉 PIPELINE RÉUSSI! Votre JAR est prêt.'
        }
    }
}

pipeline {
    agent any
    
    tools {
        maven 'M2_HOME'
        jdk 'JAVA_HOME'
    }
    
    environment {
       
        DOCKERHUB_USERNAME = "oussa100"          // 🔁 Mets ton username Docker Hub
        IMAGE_NAME = "student-management"          // 🔁 Mets le nom de ton image
    }
    
    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', 
                    url: 'https://github.com/oussa100/student-management'
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
            }
        }
        
        stage('Archive JAR') {
            steps {
                archiveArtifacts 'target/*.jar'
                
                script {
                    def jarCount = sh(
                        script: 'find target -name "*.jar" -type f | wc -l',
                        returnStdout: true
                    ).trim()
                    
                    echo "🎉 JAR GÉNÉRÉ : ${jarCount} fichier(s)"
                    
                    def jarFiles = sh(
                        script: 'ls -la target/*.jar',
                        returnStdout: true
                    ).trim()
                    
                    echo "📦 Contenu du dossier target/:"
                    echo "${jarFiles}"
                }
            }
        }
        
        /* 🔥🔥🔥 AJOUT DOCKER ICI 🔥🔥🔥 */
        
        stage('Build Docker Image') {
            steps {
                sh """
                    docker build -t $DOCKERHUB_USERNAME/$IMAGE_NAME:latest .
                """
            }
        }
        
        stage('Login to Docker Hub') {
            steps {
                sh """
                    echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin
                """
            }
        }
        
        stage('Push Docker Image') {
            steps {
                sh """
                    docker push $DOCKERHUB_USERNAME/$IMAGE_NAME:latest
                """
            }
        }
    }
    
    post {
        success {
            echo '🚀 SUCCÈS ! Application Spring Boot construite.'
            echo '📦 JAR archivé + Image Docker envoyée sur Docker Hub.'
        }
        failure {
            echo '❌ Échec - Vérifiez la configuration.'
        }
    }
}

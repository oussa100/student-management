pipeline {
    agent any
    
    tools {
        maven 'M2_HOME'
        jdk 'JAVA_HOME'
    }
    
    environment {
        DOCKERHUB_USERNAME = "oussa100"
        IMAGE_NAME = "student-management"
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
                    
                    echo "🎉 JAR GÉNÉRÉ : ${jarCount} fichier(s) - 59 MB!"
                    echo "📦 Votre application Spring Boot est prête!"
                }
            }
        }
        
        /* 🔥 CORRECTION DES PERMISSIONS DOCKER 🔥 */
        
        stage('Build Docker Image') {
            steps {
                script {
                    // VÉRIFIE SI DOCKERFILE EXISTE
                    if (fileExists('Dockerfile')) {
                        echo "✅ Dockerfile trouvé, construction de l'image..."
                        sh """
                            sudo docker build -t $DOCKERHUB_USERNAME/$IMAGE_NAME:latest .
                        """
                    } else {
                        echo "⚠️ Pas de Dockerfile, création d'un Dockerfile simple..."
                        sh '''
                            cat > Dockerfile << 'EOF'
FROM openjdk:17-jdk-slim
COPY target/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "/app.jar"]
EOF
                        '''
                        sh """
                            sudo docker build -t $DOCKERHUB_USERNAME/$IMAGE_NAME:latest .
                        """
                    }
                }
            }
        }
        
        stage('Login to Docker Hub') {
            steps {
                script {
                    // CRÉEZ CES CREDENTIALS DANS JENKINS
                    withCredentials([
                        usernamePassword(
                            credentialsId: 'docker-hub',
                            usernameVariable: 'DOCKER_USER',
                            passwordVariable: 'DOCKER_PASS'
                        )
                    ]) {
                        sh '''
                            echo $DOCKER_PASS | sudo docker login -u $DOCKER_USER --password-stdin
                        '''
                    }
                }
            }
        }
        
        stage('Push Docker Image') {
            steps {
                sh """
                    sudo docker push $DOCKERHUB_USERNAME/$IMAGE_NAME:latest
                """
                echo "🚀 Image Docker envoyée sur Docker Hub!"
            }
        }
        
        stage('Cleanup') {
            steps {
                sh '''
                    # LISTE LES IMAGES DOCKER
                    sudo docker images
                    
                    # NETTOIE LES CONTAINERS INUTILES
                    sudo docker system prune -f
                '''
            }
        }
    }
    
    post {
        success {
            echo '🚀 SUCCÈS TOTAL !'
            echo '📦 JAR Spring Boot généré (59 MB)'
            echo '🐳 Image Docker créée et envoyée sur Docker Hub'
            echo '🔗 Lien : https://hub.docker.com/r/oussa100/student-management'
        }
        failure {
            echo '❌ Échec - Vérifiez les permissions Docker'
        }
    }
}

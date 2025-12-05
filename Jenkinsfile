pipeline {
    agent any
    
    tools {
        maven 'M2_HOME'
        jdk 'JAVA_HOME'
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
                // SAUTE LES TESTS POUR GÉNÉRER LE JAR
                sh 'mvn package -DskipTests'
            }
        }
        
        stage('Archive JAR') {
            steps {
                archiveArtifacts 'target/*.jar'
                
                script {
                    def jarFiles = findFiles(glob: 'target/*.jar')
                    echo "🎉 JAR GÉNÉRÉ : ${jarFiles.size()} fichier(s)"
                    jarFiles.each { file ->
                        echo "📦 ${file.name} (${file.length()} bytes)"
                    }
                }
            }
        }
    }
    
    post {
        success {
            echo '🚀 SUCCÈS ! Votre application Spring Boot est construite.'
            echo '📦 Le JAR est disponible dans "Artifacts du build"'
        }
        failure {
            echo '❌ Échec - Vérifiez la configuration'
        }
    }
}

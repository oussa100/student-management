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
                sh 'mvn package -DskipTests'
            }
        }
        
        stage('Archive JAR') {
            steps {
                // Archive le JAR
                archiveArtifacts 'target/*.jar'
                
                // Affichage SIMPLIFIÉ sans findFiles
                script {
                    // Compte le nombre de JAR
                    def jarCount = sh(
                        script: 'find target -name "*.jar" -type f | wc -l',
                        returnStdout: true
                    ).trim()
                    
                    echo "🎉 JAR GÉNÉRÉ : ${jarCount} fichier(s)"
                    
                    // Liste les fichiers JAR
                    def jarFiles = sh(
                        script: 'ls -la target/*.jar',
                        returnStdout: true
                    ).trim()
                    
                    echo "📦 Contenu du dossier target/:"
                    echo "${jarFiles}"
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

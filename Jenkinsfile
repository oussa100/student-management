pipeline {
    agent any
    
    tools {
        maven 'M2_HOME'
        jdk 'JAVA_HOME'
    }
    
    environment {
        // Variable pour le token SonarQube (à configurer dans Jenkins Credentials)
        SONAR_TOKEN = credentials('sonarqube-token')
        
        // Variables SonarQube (ajustez selon votre configuration)
        SONAR_HOST_URL = 'http://localhost:9000'
        SONAR_PROJECT_KEY = 'spring-petclinic-jenkins'
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
        
        stage('Tests') {
            steps {
                // Exécution des tests avec JaCoCo pour la couverture
                sh 'mvn test -Djacoco.skip=false'
            }
        }
        
        stage('SonarQube Analysis') {
            steps {
                // Analyse du code avec SonarQube
                withSonarQubeEnv('SonarQube') {
                    sh """
                    mvn sonar:sonar \
                      -Dsonar.projectKey=${SONAR_PROJECT_KEY} \
                      -Dsonar.projectName='Spring PetClinic' \
                      -Dsonar.host.url=${SONAR_HOST_URL} \
                      -Dsonar.login=${SONAR_TOKEN} \
                      -Dsonar.java.coveragePlugin=jacoco \
                      -Dsonar.jacoco.reportPaths=target/jacoco.exec \
                      -Dsonar.sources=src/main/java \
                      -Dsonar.tests=src/test/java \
                      -Dsonar.sourceEncoding=UTF-8
                    """
                }
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
        
        stage('Quality Gate Check') {
            steps {
                // Attendre et vérifier le résultat de l'analyse SonarQube
                timeout(time: 10, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
                echo '✅ Quality Gate passed!'
            }
        }
    }
    
    post {
        success {
            echo '🎉 PIPELINE RÉUSSI! Votre JAR est prêt et le code a été analysé par SonarQube.'
        }
        failure {
            echo '❌ PIPELINE ÉCHOUÉ! Vérifiez les logs pour plus de détails.'
        }
    }
}

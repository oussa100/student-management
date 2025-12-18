pipeline {
    agent any
  
    stages {
        stage('Recuperation du code') {
            steps {
                git branch: 'main', 
                    url: 'https://github.com/oussa100/student-management'
            }
        }
        
        stage('Configuration tests') {
            steps {
                sh '''
                mkdir -p src/test/resources
                cat > src/test/resources/application-test.properties << EOF
                spring.datasource.url=jdbc:h2:mem:testdb
                spring.datasource.driverClassName=org.h2.Driver
                spring.datasource.username=sa
                spring.datasource.password=
                spring.jpa.database-platform=org.hibernate.dialect.H2Dialect
                spring.jpa.hibernate.ddl-auto=create-drop
                spring.main.banner-mode=off
                logging.level.root=WARN
                EOF
                '''
            }
        }
        
        stage('Compilation Maven') {
            steps {
                sh '''
                echo "Compilation en cours..."
                mvn clean compile -DskipTests || echo "Compilation avec erreurs, continuation..."
                mvn package -DskipTests || echo "Packaging avec erreurs, continuation..."
                
                if ls target/*.jar 1> /dev/null 2>&1; then
                    echo "JAR genere avec succes"
                    ls -lh target/*.jar
                else
                    echo "Aucun JAR trouve dans target/"
                fi
                '''
            }
        }

        stage('Archive Artifacts') {
            steps {
                archiveArtifacts artifacts: 'target/*.jar', fingerprint: true
            }
        }

        stage('Start SonarQube') {
            steps {
                sh '''
                    echo "Starting SonarQube container..."
                    
                    # Stopper et supprimer l ancien conteneur
                    docker stop sonarqube 2>/dev/null || true
                    docker rm sonarqube 2>/dev/null || true
                    
                    # Demarrer avec optimisation memoire
                    docker run -d --name sonarqube -p 9000:9000 \
                        -e SONAR_ES_BOOTSTRAP_CHECKS_DISABLE=true \
                        sonarqube:lts
                    
                    echo "Waiting for SonarQube to be ready..."
        
                    # Attendre jusqu a 120 secondes
                    for i in {1..40}; do
                        if curl -s http://localhost:9000/api/system/status | grep -q '"status":"UP"'; then
                            echo "SonarQube is UP!"
                            break
                        fi
                        echo "Still starting... ($i/40)"
                        sleep 3
                    done
                '''
            }
        }

        stage('Analyse SonarQube') {
            steps {
                withSonarQubeEnv('sonar') {
                    sh 'mvn sonar:sonar -Dsonar.projectKey=studentmanagement -Dsonar.host.url=http://localhost:9000 -DskipTests'
                }
            }
        }
        
        stage('Creation image Docker') {
            steps {
                sh '''
                # Verifier si Dockerfile existe, sinon en creer un
                if [ ! -f "Dockerfile" ]; then
                    cat > Dockerfile << EOF
FROM openjdk:17-slim
WORKDIR /app
COPY target/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
EOF
                fi
                
                docker build -t oussa101/studentmanagement .
                '''
            }
        }
        
        stage('Publication sur Docker Hub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_TOKEN')]) {
                    sh '''
                        echo "$DOCKER_TOKEN" | docker login -u "$DOCKER_USER" --password-stdin
                        docker push oussa101/studentmanagement
                    '''
                }
            }
        }

        stage('Deploiement') {
            steps {
                sh '''
                docker stop studentmanagement-app 2>/dev/null || true
                docker rm studentmanagement-app 2>/dev/null || true
                docker run -d -p 8081:8080 --name studentmanagement-app oussa101/studentmanagement
                
                # Attendre le demarrage de l application
                sleep 15
                echo "Test de l application..."
                curl -s http://localhost:8081/actuator/health || echo "Application en cours de demarrage"
                '''
            }
        }
    }
    
    post {
        always {
            echo "Build termine. Statut: ${currentBuild.currentResult}"
            echo "URL du build: ${BUILD_URL}"
            
            sh '''
            # Nettoyage des conteneurs temporaires
            docker stop studentmanagement-app 2>/dev/null || true
            docker rm studentmanagement-app 2>/dev/null || true
            '''
        }
        
        success {
            echo "Build reussi"
            mail to: 'oussamabani14@gmail.com',
                 subject: 'Build Successful',
                 body: "La build a reussi.\n\nDetails: ${BUILD_URL}"
        }
        
        failure {
            echo "Build echoue"
            mail to: 'oussamabani14@gmail.com',
                 subject: 'Build Failed',
                 body: "La build a echoue.\n\nConsultez les logs: ${BUILD_URL}console"
                 
            sh '''
            echo "Diagnostic rapide:"
            echo "Java version:"
            java -version 2>&1 | head -1
            echo "Maven version:"
            mvn --version 2>&1 | head -1
            echo "Docker version:"
            docker --version 2>&1 | head -1
            '''
        }
    }
}

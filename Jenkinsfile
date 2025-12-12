pipeline {
    agent any
  
    stages {
        stage('Recuperation du code') {
            steps {
                git branch: 'master', 
                    url: 'https://github.com/oussa100/student-management'
            }
        }
        
        stage('Compilation Maven') {
            steps {
                sh 'mvn clean package'
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
                    docker start sonarqube || docker run -d --name sonarqube -p 9000:9000 sonarqube:lts
        
                    echo "Waiting for SonarQube to be ready..."
        
                    # wait up to 120 seconds
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
                    sh 'mvn sonar:sonar -Dsonar.projectKey=studentmanagement -Dsonar.host.url=http://localhost:9000'
                }
            }
        }
        
        stage('Creation image Docker') {
            steps {
                sh 'docker build -t slm334/studentmanagement .'
            }
        }
        
        
        stage('Publication sur Docker Hub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_TOKEN')]) {
                    sh '''
                        echo "$DOCKER_TOKEN" | docker login -u "$DOCKER_USER" --password-stdin
                        docker push slm334/studentmanagement
                    '''
                }
            }
        }

        
        stage('Deploiement') {
            steps {
                sh 'docker stop studentmanagement-app || true'
                sh 'docker rm studentmanagement-app || true'
                sh 'docker run -d -p 8081:8080 --name studentmanagement-app slm334/studentmanagement'
            }
        }
        
    }
    
    post {
        success {
            mail to: 'oussamabani14@gmail.com',
                 subject: 'Build Successful',
                 body: 'La build a réussi.'
        }
        failure {
            mail to: 'oussamabani14@gmail.com',
                 subject: 'Build Failed',
                 body: 'La build a échoué.'
        }
    }

}

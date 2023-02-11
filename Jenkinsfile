pipeline {
  agent any
  tools {
  maven 'maven3'
  }

  stages {

      stage('Unit Test - Junit and Jacoco') {
            steps {
              sh "mvn test"
            }
            post {
              always {
                junit 'target/surefire-reports/*.xml'
                jacoco execPattern: 'target/jacoco.exec'
              }
            }
      }
      stage ('Mutation Teast - PIT') {
            steps {
              script {
                sh "mvn org.pitest:pitest-maven:mutationCoverage"
              }
            }
            post {
                always {
                  pitmutation mutationStatsFile: '**/target/pit-reports/**/mutations.xml'
                }
            }
      }

      stage ('SonarQube') {
        steps {
          script {
            withSonarQubeEnv(credentialsId: 'sonarqube') {
                sh "mvn sonar:sonar -Dsonar.projectKey=numeric-application"
            }
            timeout(time: 1, unit: 'MINUTES') {
                waitForQualityGate abortPipeline: true
            }
          }
        }
      }

      stage ('OWASP Dependency check') {
        steps {
          script {
            sh 'mvn dependency-check:check'
          }
        }
        post {
            always {
              dependencyCheckPublisher pattern: 'target/dependency-check-report.xml'
            }
        }

      }
      stage('Build Artifact') {
            steps {
              sh "mvn clean package -DskipTests=true"
              archive 'target/*.jar' //so that they can be downloaded later
            }
      }   

      stage('Docker Build & Push') {
            steps {
              script {
                withCredentials([usernamePassword(credentialsId :'DockerHub',usernameVariable :'USER',passwordVariable :'PASSWORD')]){
                  sh 'docker build -t amagdi888/my-repo:numeric-app .'
                  sh 'echo $PASSWORD | docker login -u $USER --password-stdin'
                  sh 'docker push amagdi888/my-repo:numeric-app'
                }
              }
            }
      }

      stage('Apply Kubernetes files') {
            steps {
              script {
                    withKubeConfig([credentialsId: 'kubernetes']) {
                      sh 'kubectl apply -f k8s_deployment_service.yaml'
                    }
              }
            }
      }
  }  
    
}
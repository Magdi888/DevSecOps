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
      }
      stage ('Mutation Teast - PIT') {
            steps {
              script {
                sh "mvn org.pitest:pitest-maven:mutationCoverage"
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

      stage ('OWASP Dependency check & Image Scanning') {
        steps {
          parallel ( 

            'OWASP Dependency check': {
              sh 'mvn dependency-check:check'
            },
            'Trivy Image Scanning': {
              sh 'bash trivy-scan.sh'
            },
            'OPA Conftest': {
              sh 'conftest test --policy dockerfile-security-check.rego Dockerfile'
            }
          )
          }
        }
      
      // stage('Build Artifact') {
      //       steps {
      //         sh "mvn clean package -DskipTests=true"
      //         archive 'target/*.jar' //so that they can be downloaded later
      //       }
      // }   

      // stage('Docker Build & Push') {
      //       steps {
      //         script {
      //           withCredentials([usernamePassword(credentialsId :'DockerHub',usernameVariable :'USER',passwordVariable :'PASSWORD')]){
      //             sh 'docker build -t amagdi888/my-repo:numeric-app .'
      //             sh 'echo $PASSWORD | docker login -u $USER --password-stdin'
      //             sh 'docker push amagdi888/my-repo:numeric-app'
      //           }
      //         }
      //       }
      // }

      // stage('Apply Kubernetes files') {
      //       steps {
      //         script {
      //               withKubeConfig([credentialsId: 'kubernetes']) {
      //                 sh 'kubectl apply -f k8s_deployment_service.yaml'
      //               }
      //         }
      //       }
      // }
  }

  post {
      always {
           junit 'target/surefire-reports/*.xml'
           jacoco execPattern: 'target/jacoco.exec'
           pitmutation mutationStatsFile: '**/target/pit-reports/**/mutations.xml'
           dependencyCheckPublisher pattern: 'target/dependency-check-report.xml'
      }
  }  
    
}
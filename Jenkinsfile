pipeline {
  agent any
  tools {
  maven 'maven3'
  }
  environment {
    imageName = "amagdi888/my-repo:numeric-app-${env.BUILD_NUMBER}"
    serviceName = "devsecops-svc"
    appURL = "http://192.168.56.3"

  }

  stages {

      stage('Build Artifact') {
            steps {
                sh "mvn clean package -DskipTests=true"
                archive 'target/*.jar' //so that they can be downloaded later
            }
      }   


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

      // stage ('SonarQube') {
      //   steps {
      //     script {
      //       withSonarQubeEnv(credentialsId: 'sonarqube') {
      //           sh "mvn sonar:sonar -Dsonar.projectKey=numeric-application"
      //       }
      //       timeout(time: 1, unit: 'MINUTES') {
      //           waitForQualityGate abortPipeline: true
      //       }
      //     }
      //   }
      // }

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
      

      stage('Docker Build & Push') {
            steps {
              script {
                withCredentials([usernamePassword(credentialsId :'DockerHub',usernameVariable :'USER',passwordVariable :'PASSWORD')]){
                  sh "docker build -t ${imageName} ."
                  sh 'echo $PASSWORD | docker login -u $USER --password-stdin'
                  sh "docker push ${imageName}"
                }
              }
            }
      }

      stage ('K8S Vulnerabilities - Scan') {
            steps {
              parallel (
                'OPA Conftest for K8S': {
                  sh 'conftest test --policy k8s-security.rego k8s_deployment_service.yaml'
                },
                'Kubesec Scan': {
                  sh 'bash kubesec.sh'
                }
              )
              } 
      }

      stage('Apply Kubernetes files') {
            steps {
              script {
                    sh "bash replacement.sh"
              }
            }
      }

      stage('commit version update') {
          steps {
              script {
                  withCredentials([usernamePassword(credentialsId: 'git-token', passwordVariable: 'PASS', usernameVariable: 'USER')]) {
                      // git config here for the first time run
                      sh 'git config --global user.email "jenkins@example.com"'
                      sh 'git config --global user.name "jenkins"'

                      sh "git remote set-url origin https://${USER}:${PASS}@github.com/Magdi888/DevSecOps.git"
                      sh 'git add .'
                      sh 'git commit -m "update image tag"'
                      sh 'git push -u origin HEAD:master'
                  }
              }
          }
      }

      stage('OWASP ZAP - DAST') {
          steps {
              script {
                  withKubeConfig([credentialsId: 'kubernetes']) {
                        sh 'bash OWASP-ZAP.sh'
                      }
              }
          }
      }





  }

  post {
      always {
           junit 'target/surefire-reports/*.xml'
           jacoco execPattern: 'target/jacoco.exec'
           pitmutation mutationStatsFile: '**/target/pit-reports/**/mutations.xml'
           dependencyCheckPublisher pattern: 'target/dependency-check-report.xml'
           publishHTML([allowMissing: false, alwaysLinkToLastBuild: true, keepAll: true, reportDir: 'owasp-zap-report', reportFiles: 'zap_report.html', reportName: 'OWAZP ZAP HTML Report', reportTitles: 'OWAZP ZAP HTML Report', useWrapperFileDirectly: true])
      }
  }  
    
}

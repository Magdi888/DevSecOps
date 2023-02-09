pipeline {
  agent any
  tools {
  maven 'maven3'
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
            post {
              always {
                junit 'target/surefire-reports/*.xml'
                jacoco execPattern: 'target/jacoco.exec'
              }
            }
        }
      stage(Docker Build & Push) {
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
    }
}
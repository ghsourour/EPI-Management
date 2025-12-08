pipeline{
    agent any
    triggers {
        pollSCM('H/2 * * * *')  
    }
    environment{
        DOCKERHUB_ID = "ghsourour"
        IMAGE_NAME = "epi-management_springboot-app"
        IMAGE_TAG = "latest"

    }
    

    
    stages{

    stage('Checkout') {
     steps {
        git branch: 'main',
            url: 'https://github.com/ghsourour/EPI-Management.git'
        sh "ls -la"
       }
      }
        stage('build image'){
            steps{
                script{
                    sh "docker build -t ${DOCKERHUB_ID}/$IMAGE_NAME:$IMAGE_TAG ."
                }

            }
        }
        stage('Scan image with Trivy') {
            steps {
                sh """
                    trivy image --severity HIGH,CRITICAL --exit-code 0 --no-progress ${DOCKERHUB_ID}/${IMAGE_NAME}:${IMAGE_TAG} || true
                """
            }
        }
        stage('push to dockerhub'){
            steps{
                script{
                    withCredentials([usernamePassword(
                        credentialsId: 'docker-hub-credentials',  
                        usernameVariable: 'DOCKER_USER',         
                        passwordVariable: 'DOCKER_PASS' 
                    )]){
                        sh '''
                        echo "🔐 Authentification sur Docker Hub..."
                        echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
                        docker push ${DOCKERHUB_ID}/${IMAGE_NAME}:${IMAGE_TAG}
                      '''
                    }
                }
            }
        }
   
    }
}

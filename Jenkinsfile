pipeline{
     options {
        timeout(time: 45, unit: 'MINUTES')
    }
    

    agent any
    triggers {
        pollSCM('H/2 * * * *')  
    }
    environment{
        DOCKERHUB_ID = "ghsourour"
        IMAGE_NAME = "epi-management_springboot-app"
        IMAGE_TAG = "${env.BUILD_NUMBER}"
        GITHUB_TOKEN = credentials('github-token')

    }
    

    
    stages{

    stage('Checkout') {
     steps {
        git branch: 'main',
            url: 'https://github.com/ghsourour/EPI-Management.git'
        sh "ls -la"
       }
      }
        stage('semgrep test'){
            steps{
                sh """
                echo "Running Semgrep..."
                semgrep --config=auto --json --output semgrep-report.json || true
                """
            }
        }     
        stage('Publish Report'){
            steps{
                archiveArtifacts artifacts: 'semgrep-report.json', fingerprint: true
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
                trivy image --scanners vuln  --no-progress ${DOCKERHUB_ID}/$IMAGE_NAME:$IMAGE_TAG || true
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
                        echo " Authentification sur Docker Hub..."
                        echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
                        docker push ${DOCKERHUB_ID}/${IMAGE_NAME}:${IMAGE_TAG}
                      '''
                    }
                }
            }
        }
        stage('Update K8s Manifests'){
            steps{
                script{
                 withCredentials([string(credentialsId: 'github-token', variable: 'GITHUB_TOKEN')]){
                    sh """       
                      sed -i "s|image:.*${env.IMAGE_NAME}:.*|image: ${env.DOCKERHUB_ID}/${env.IMAGE_NAME}:${env.IMAGE_TAG}|g" k8s/springboot-deployment.yaml
                      git config user.email "sourourghannem7@gmail.com"
                      git config user.name "ghsourour"
                      git add  k8s/springboot-deployment.yaml
                      git commit -m "Update image tag  [skip ci]" || echo "Nothing to commit"
                      export GIT_ASKPASS=$(mktemp)
                      echo "echo $GITHUB_TOKEN" > $GIT_ASKPASS
                      chmod +x $GIT_ASKPASS
                      git push https://github.com/ghsourour/EPI-Management.git main
                    """
                 }
                           

                  
                }
            }
        }
         

   
    }
}
 
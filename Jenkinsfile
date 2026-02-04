pipeline {
    agent any

    environment {
        PROJECT_ID = "project-ca896fcb-d1a8-4e3c-94d"
        REGION     = "us-central1"
        REPO       = "docker-repo"
        IMAGE      = "demo-app"
        TAG        = "${BUILD_NUMBER}"
        IMAGE_URI  = "us-central1-docker.pkg.dev/${PROJECT_ID}/${REPO}/${IMAGE}:${TAG}"
    }

    stages {

        stage('Checkout') {
            steps {
                git branch: 'Docker',
                    url: 'https://github.com/anila87/Jenkins'
            }
        }

        stage('GCP Auth') {
            steps {
                withCredentials([file(credentialsId: 'gcp-sa', variable: 'GCP_KEY')]) {
                    sh '''
                      gcloud auth activate-service-account --key-file=$GCP_KEY
                      gcloud config set project $PROJECT_ID
                      gcloud auth configure-docker us-central1-docker.pkg.dev --quiet
                    '''
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                sh '''
                  docker build -t $IMAGE_URI .
                '''
            }
        }

        stage('Push to Artifact Registry') {
            steps {
                sh '''
                  docker push $IMAGE_URI
                '''
            }
        }

        stage('Terraform Deploy Container') {
            steps {
                withCredentials([file(credentialsId: 'gcp-sa.json', variable: 'GCP_KEY')]) {
                    dir('terraform') {
                        sh '''
                          export GOOGLE_APPLICATION_CREDENTIALS=$GCP_KEY
                          terraform init
                          terraform apply -auto-approve \
                            -var="image_uri=${IMAGE_URI}"
                        '''
                    }
                }
            }
        }
    }

    post {
        success {
            echo "🚀 Deployed successfully"
        }
        failure {
            echo "❌ Pipeline failed"
        }
    }
}

pipeline {
    agent any

    environment {
        REPO_URL = 'https://us-central1-maven.pkg.dev/project-ca896fcb-d1a8-4e3c-94d/test-jenkins'
    }

    tools {
        maven 'maven'
        jdk 'java21'
    }

    stages {

        stage('Checkout') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/anila87/Jenkins'
            }
        }

        stage('Build & Test') {
            steps {
                // 🔧 CHANGE: Single configFileProvider used once
                configFileProvider([
                    configFile(
                        fileId: '7dd8ddf7-d1fc-44c7-9b86-f26fd1fa7697',
                        variable: 'MAVEN_SETTINGS'
                    )
                ]) {
                    sh '''
                      mvn clean test package -s $MAVEN_SETTINGS
                    '''
                }
            }
        }

        stage('Publish to GCP Artifact Registry') {
            steps {
                // 🔧 CHANGE: configFileProvider ADDED here (this was missing)
                configFileProvider([
                    configFile(
                        fileId: '7dd8ddf7-d1fc-44c7-9b86-f26fd1fa7697',
                        variable: 'MAVEN_SETTINGS'
                    )
                ]) {
                    withCredentials([
                        file(credentialsId: 'gcp-sa.json', variable: 'GCP_KEY')
                    ]) {
                        sh '''
                          gcloud auth activate-service-account --key-file=$GCP_KEY
                          export ACCESS_TOKEN=$(gcloud auth print-access-token)

                          mvn deploy:deploy-file \
                            -DgroupId=com.demo \
                            -DartifactId=jenkins-demo \
                            -Dversion=1.0 \
                            -Dpackaging=jar \
                            -Dfile=target/jenkins-demo-1.0.jar \
                            -DrepositoryId=artifact-registry \
                            -Durl=$REPO_URL \
                            -s $MAVEN_SETTINGS
                        '''
                    }
                }
            }
        }
    }

    post {
        success {
            echo 'Build successful 🎉'
            archiveArtifacts artifacts: 'target/*.jar'
        }
        failure {
            echo 'Build failed ❌'
        }
    }
}

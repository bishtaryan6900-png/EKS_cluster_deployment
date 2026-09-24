pipeline {
    agent any

    environment {
        AWS_ACCESS_KEY_ID     = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
        REGION                = "us-east-1"
    }

    stages {
        stage('Checkout SCM') {
            steps {
                script {
                    checkout scmGit(
                        branches: [[name: '*/main']],
                        extensions: [],
                        userRemoteConfigs: [[url: 'https://github.com/bishtaryan6900-png/EKS_cluster_deployment.git']]
                    )
                }
            }
        }

        stage('Terraform Initialize') {
            steps {
                script {
                    dir('EKS') {
                        sh 'terraform init'
                    }
                }
            }
        }

        stage('Terraform Format') {
            steps {
                script {
                    dir('EKS') {
                        sh 'terraform fmt -recursive'
                    }
                }
            }
        }

        stage('Terraform Validate') {
            steps {
                script {
                    dir('EKS') {
                        sh 'terraform validate'
                    }
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                script {
                    dir('EKS') {
                        sh 'terraform plan -out=tfplan'
                    }
                }
            }
        }

        /* 
        // Uncomment this stage if you want Jenkins to pause for manual approval before applying
        stage('Approval Gate') {
            steps {
                input message: 'Do you want to apply these infrastructure changes to AWS?', ok: 'Apply'
            }
        }
        *

        stage('Terraform Apply') {
            steps {
                script {
                    dir('EKS') {
                        sh 'terraform apply -input=false tfplan'
                    }
                }
            }
        }
    }

    post {
        always {
            cleanWs()
        }
        failure {
            echo 'Pipeline failed. Please check the logs above for details.'
        }
    }
}

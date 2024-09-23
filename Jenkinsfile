pipeline {
    agent any
    environment {
        // Define AWS credentials as environment variables
        AWS_ACCESS_KEY_ID     = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
        REGION                = 'us-east-1'
    }

    stages {
        stage('Checkout') {
            steps {
                // Check out the repository with Terraform code
                git branch: 'main', 
                    url: 'https://github.com/Pravesh2201/project_terraform_code.git'
            }
        }

        stage('Terraform Init') {
            steps {
                // Change to the project directory before running Terraform commands
                dir('project_terraform_code') {
                    // Initialize the Terraform backend (S3 and DynamoDB for state locking)
                    sh '''
                        terraform init \
                        -backend-config="bucket=elasticsearch-tool" \
                        -backend-config="key=terraform/state" \
                        -backend-config="region=${REGION}" \
                        -backend-config="dynamodb_table=terraform-lock-table"
                    '''
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                // Change to the project directory before running Terraform commands
                dir('project_terraform_code') {
                    // Show the Terraform plan with lock disabled
                    sh 'terraform plan -lock=false -out=tfplan'
                }
            }
        }
        
        stage('User Approval') {
            steps {
                // Change to the project directory before waiting for user input
                dir('project_terraform_code') {
                    input message: 'Do you want to apply the Terraform changes?', ok: 'Yes, apply'
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                // Change to the project directory before applying Terraform changes
                dir('project_terraform_code') {
                    // Apply the Terraform changes with lock disabled
                    sh 'terraform apply -auto-approve -lock=false'
                }
            }
        }
    }

    // post {
    //     always {
    //         // Cleanup workspace after the build
    //         cleanWs()
    //     }
    // }
}

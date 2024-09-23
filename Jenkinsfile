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

        stage('Install Terraform') {
            steps {
                script {
                    // Install Terraform on Jenkins agent (only if not preinstalled)
                    sh '''
                        curl -o /tmp/terraform.zip \
                        https://releases.hashicorp.com/terraform/1.4.5/\
                        terraform_1.4.5_linux_amd64.zip
                        unzip /tmp/terraform.zip -d /usr/local/bin/
                        terraform -v
                    '''
                }
            }
        }

        stage('Terraform Init') {
            steps {
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

        stage('Terraform Plan') {
            steps {
                // Show the Terraform plan with lock disabled
                sh 'terraform plan -lock=false -out=tfplan'
            }
        }

        stage('User Approval') {
            input {
                message 'Do you want to apply the Terraform changes?'
                ok 'Yes, apply'
            }
        }

        stage('Terraform Apply') {
            steps {
                // Apply the Terraform changes with lock disabled
                sh 'terraform apply -auto-approve -lock=false'
            }
        }
    }

    post {
        always {
            // Cleanup workspace after the build
            cleanWs()
        }
    }
}

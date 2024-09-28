pipeline {
    agent any
    parameters {
        choice(name: 'ACTION', choices: ['apply', 'destroy'], description: 'Select action: apply or destroy')
    }
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
   
                    sh 'terraform plan -lock=false' 

            }
        }
        
        // stage('User Approval') {
        //     steps {

        //             input message: 'Do you want to apply the Terraform changes?', ok: 'Yes, apply'
              
        //     }
        // }

        stage('Terraform Apply') {
            steps {
  
                    sh 'terraform apply -auto-approve -lock=false'
                
            }
        }
        stage('Approval for Destroy') {
            when {
                expression { params.ACTION == 'destroy' }
            }
            steps {
                // Prompt for approval before destroying resources
                input "Do you want to Terraform Destroy?"
            }
        }

            stage('Terraform Destroy') {
                when {
                    expression { params.ACTION == 'destroy' }
                }
                steps {
                // Destroy Infra
                    sh 'terraform destroy -auto-approve'
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

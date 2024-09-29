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
                dir('terraform_es') {

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
                   dir('terraform_es') {
                       sh 'terraform plan -lock=false'
                   }

            }
        }
        
        stage('Terraform Apply') {
            steps {
                   dir('terraform_es') {
                       sh 'terraform apply -auto-approve -lock=false'

                   }
                
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
                       dir('terraform_es') {
                           sh 'terraform destroy -auto-approve'
                       }
                }
                post {
                    always {
                    // Cleanup workspace after the build
                        cleanWs()
                    }
                }
            }
            
            stage('Ansible Playbook Execution') {
                when {
                    expression { params.ACTION == 'apply' }
                    }
                    
                    steps {
                        dir('elasticsearch') {
                        
                        // Run the Ansible playbook using dynamic inventory (aws_ec2.yml)
                        
                        
                            withCredentials([sshUserPrivateKey(credentialsId: 'my-ssh-key', keyFileVariable: 'SSH_KEY')]) {
                                sh '''
                                // ansible-playbook -i aws_ec2.yml playbook.yml --private-key AWS.pem
                                ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook playbook.yml
                                '''
                            }
                        }
                                
                    }
             }        
                
    }

}

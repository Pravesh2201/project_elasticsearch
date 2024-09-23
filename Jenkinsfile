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
        
        stage('User Approval') {
            steps {

                    input message: 'Do you want to apply the Terraform changes?', ok: 'Yes, apply'
              
            }
        }

        stage('Terraform Apply') {
            steps {

                sh '''
                        terraform apply -auto-approve -lock=false
                        public_ip=$(terraform output -json public_instance_ip | jq -r '.value')
                        private_ip=$(terraform output -json private_instance_ip | jq -r '.value')
                        echo "PUBLIC_IP=$public_ip" > ip_outputs.txt
                        echo "PRIVATE_IP=$private_ip" >> ip_outputs.txt
                    ''' 
            }    
        }

        stage('Archive IPs') {
            steps {
                // Archive the IPs to pass to the downstream job
                archiveArtifacts artifacts: 'ip_outputs.txt', allowEmptyArchive: false
            }
        }

        stage('Trigger Downstream Job') {
            steps {
                // Trigger downstream job and pass IPs as parameters
                build job: 'elasticsearch', 
                      parameters: [
                          file('ip_outputs.txt')
                      ]
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

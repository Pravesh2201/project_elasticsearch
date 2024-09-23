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
                script {
                    sh '''
                        terraform apply -auto-approve -lock=false
                //     '''

                //     // Capture the public and private IPs
                //     def public_ip = sh(script: 'terraform output -json public_ip | jq -r .value', returnStdout: true).trim()
                //     def private_ip = sh(script: 'terraform output -json private_ip | jq -r .value', returnStdout: true).trim()

                //     echo "PUBLIC_IP=${public_ip}" > ip_outputs.txt
                //     echo "PRIVATE_IP=${private_ip}" >> ip_outputs.txt
                // }
            }    
        }

        // stage('Archive IPs') {
        //     steps {
        //         // Archive the IPs to pass to the downstream job
        //         archiveArtifacts artifacts: 'ip_outputs.txt', allowEmptyArchive: false
        //     }
        // }

        // stage('Trigger Downstream Job') {
        //     steps {
        //         // Trigger downstream job and pass IPs as parameters
        //         build job: 'elasticsearch', 
        //               parameters: [
        //                   string(name: 'PUBLIC_IP', value: sh(script: "cat ip_outputs.txt | grep PUBLIC_IP | cut -d '=' -f2", returnStdout: true).trim()),
        //                   string(name: 'PRIVATE_IP', value: sh(script: "cat ip_outputs.txt | grep PRIVATE_IP | cut -d '=' -f2", returnStdout: true).trim())
        //               ]
        //     }
        // }
    }

    // post {
    //     always {
    //         // Cleanup workspace after the build
    //         cleanWs()
    //     }
    // }
}

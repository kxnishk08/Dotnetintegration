pipeline {
        agent any

        environment {
            AZURE_CREDENTIALS_ID = 'azure-service-principal-01'
            RESOURCE_GROUP = 'rg-jenkins'
            APP_SERVICE_NAME = 'webapijenkins2808'
            AZURE_CLI_PATH = 'C:/Program Files/Microsoft SDKs/Azure/CLI2/wbin'
            SYSTEM_PATH = 'C:/Windows/System32'
            TERRAFORM_PATH = 'C:\\Users\\pc\\OneDrive\\Documents\\Programs\\Terraform\\terraform.exe'
        }

        stages {

            stage('Terraform Init') {
                steps {
                    dir('jenkins_module') {
                        bat '''
                            set PATH=%AZURE_CLI_PATH%;%SYSTEM_PATH%;%TERRAFORM_PATH%;%PATH%
                            terraform init
                        '''
                    }
                }
            }

            stage('Terraform Plan & Apply') {
                steps {
                    dir('jenkins_module') {
                        bat '''
                            set PATH=%AZURE_CLI_PATH%;%SYSTEM_PATH%;%TERRAFORM_PATH%;%PATH%
                            terraform plan
                            terraform apply -auto-approve
                        '''
                    }
                }
            }

            stage('Publish .NET 8 Web API') {
                steps {
                    dir('webapijenkins') {
                        bat 'dotnet restore'
                        bat 'dotnet build --configuration Release'
                        bat 'dotnet publish -c Release -o out'
                        bat 'powershell Compress-Archive -Path "out\\*" -DestinationPath "Webapi.zip" -Force'
                    
                    }
                }
            }

            stage('Deploy to Azure App Service') {
                steps {
                    withCredentials([azureServicePrincipal(credentialsId: AZURE_CREDENTIALS_ID)]) {
                        bat 'set PATH=%AZURE_CLI_PATH%;%SYSTEM_PATH%;%TERRAFORM_PATH%;%PATH%'
                        bat 'az webapp deploy --resource-group %RESOURCE_GROUP% --name %APP_SERVICE_NAME% --src-path %WORKSPACE%\\Webapi\\Webapi.zip --type zip'
                    
                    }
                }
            }
        }

        post {
            success {
                echo 'Deployment Successful!'
            }
            failure {
                echo 'Deployment Failed!'
            }
        }
    }

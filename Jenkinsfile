pipeline {
                        agent any

                        environment {
                            AZURE_CREDENTIALS_ID = 'azure-service-principal-01'
                            RESOURCE_GROUP = 'rg-jenkins'
                            APP_SERVICE_NAME = 'webapijenkins2808'
                            TERRAFORM_VERSION = '1.11.3'
                            TERRAFORM_DIR = 'C:\\Users\\pc\\OneDrive\\Documents\\Programs\\Terraform'
                            TERRAFORM_PATH = 'C:\\Users\\pc\\OneDrive\\Documents\\Programs\\Terraform\\terraform.exe'
                        }

                        stages {
                            stage('Setup Terraform') {
                                steps {
                                    bat '''
                                        if not exist "%TERRAFORM_DIR%" mkdir "%TERRAFORM_DIR%"
                                        echo Downloading Terraform %TERRAFORM_VERSION%...
                                        powershell -Command "& {Invoke-WebRequest -Uri 'https://releases.hashicorp.com/terraform/%TERRAFORM_VERSION%/terraform_%TERRAFORM_VERSION%_windows_amd64.zip' -OutFile '%TERRAFORM_DIR%\\terraform.zip'}"
                                        echo Extracting Terraform...
                                        powershell -Command "& {Expand-Archive -Path '%TERRAFORM_DIR%\\terraform.zip' -DestinationPath '%TERRAFORM_DIR%' -Force}"
                                        echo Cleaning up...
                                        del "%TERRAFORM_DIR%\\terraform.zip"
                                        echo Terraform setup complete.
                                    '''
                                }
                            }

                            stage('Terraform Init') {
                                steps {
                                    dir('jenkins_module') {
                                        bat '"%TERRAFORM_PATH%" init'
                                    }
                                }
                            }

                            stage('Terraform Plan & Apply') {
                                steps {
                                    dir('jenkins_module') {
                                        bat '"%TERRAFORM_PATH%" plan -out=tfplan'
                                        bat '"%TERRAFORM_PATH%" apply -auto-approve tfplan'
                                    }
                                }
                            }

                            stage('Publish .NET 8 Web API') {
                                steps {
                                    dir('webapijenkins') {
                                        bat 'dotnet publish -c Release -o out'
                                        bat 'powershell Compress-Archive -Path out\\* -DestinationPath webapi.zip -Force'
                                    }
                                }
                            }

                            stage('Deploy to Azure App Service') {
                                steps {
                                    withCredentials([azureServicePrincipal(credentialsId: AZURE_CREDENTIALS_ID)]) {
                                        bat "az login --service-principal -u $AZURE_CLIENT_ID -p $AZURE_CLIENT_SECRET --tenant $AZURE_TENANT_ID"
                                        bat "az account set --subscription $AZURE_SUBSCRIPTION_ID"
                                        bat "az webapp deploy --resource-group $RESOURCE_GROUP --name $APP_SERVICE_NAME --src-path %WORKSPACE%\\webapi\\webapi.zip --type zip"
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

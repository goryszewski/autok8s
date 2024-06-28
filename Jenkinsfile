pipeline {
    agent any

    stages {
        stage('Run Terraform') {
            steps {
                make terraform_apply
            }
        }
        stage('Run Ansible - Infra') {
            steps {
                make ansible_prep
            }
        }
        stage('Deploy Cluster') {
            steps {
                make ansible_cluster
            }
        }
    }
}

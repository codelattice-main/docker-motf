
pipeline {
  agent { label 'motf-unix-agent-01' }
  environment{
    DEVELOPERS_EMAIL="faisal.nizam@mueseumofthefuture.ae"
    GITHUB_REPO="git@github.com:museumofthefuture/motf.website.twill.git"
  }

  stages {

    stage('Prepare'){
      parallel{
        stage('Code-Checkout'){
          steps{
            checkout scm
          }
        }
        stage('Prepare-Workspace'){
          steps{
            prepareWorkspace()
          }
        }
      }
    }


    stage("Build-Project"){
      steps{
          runBuild()
      }
    }

    stage("Unit Tests"){
      steps{
        runTest()
      }
    }

    stage("Ask: Desploy to Staging"){
      agent none
        steps{
          script{
            env.DEPLOY_TO_DEV= input message: 'Approval is required',
              parameters: [
                choice(name: 'Do you want to deploy to Staging?', choices: 'no\nyes',
                    description: 'Choose "yes" if you want to deploy the DEV server')
              ]
          }
        }
    } // End of Deployment to Dev

      stage('Deploying To Staging Env'){
            when{
                environment name:'DEPLOY_TO_DEV', value:'yes'
            }
            steps{
                deployToServer("deploy-staging")
            }
        }

    stage("Ask: Deploy to Testing"){
      agent none
        steps{
          script{
            env.DEPLOY_TO_TEST= input message: 'Approval is required',
              parameters: [
                choice(name: 'Do you want to deploy to Test?', choices: 'no\nyes',
                    description: 'Choose "yes" if you want to deploy the Test server')
              ]
          }
        }
    } // End of Deployment to Dev

      stage('Deploy To Testing'){
            when{
                environment name:'DEPLOY_TO_TEST', value:'yes'
            }
            steps{
                deployToTesting("deploy-testing")
            }
        }



    stage("Ask: Deploy to Production"){
      agent none
        steps{
          script{
            env.DEPLOY_TO_PROD= input message: 'Approval is required',
              parameters: [
                choice(name: 'Do you want to deploy to Prod?', choices: 'no\nyes',
                    description: 'Choose "yes" if you want to deploy the Prod server')
              ]
          }
        }
    } // End of Deployment to Dev

      stage('Deploying To Production'){
            when{
                environment name:'DEPLOY_TO_PROD', value:'yes'
            }
            steps{
                deployToProduction("deploy-production")
            }
        }


} // End of Stages


 post {
        always {
            cleanWs(cleanWhenNotBuilt: false,
                    deleteDirs: true,
                    disableDeferredWipeout: true,
                    notFailBuild: true,
                    patterns: [[pattern: '.gitignore', type: 'INCLUDE'],
                               [pattern: '.propsfile', type: 'EXCLUDE']])
        }
    }// End of Post Deployment Steps

} // End of Pipeline

def checkoutCode(){
  count=1
    retry(3){
      echo "Checkout the Code For MOTF Twill, Trial:${count}"
        git url:"${GITHUB_REPO}"
    }
}

def prepareWorkspace(){
    echo 'Check here if everything is ready to make a build'
    sh 'java -version'
    sh 'git --version'
}


def runTest(){
    echo 'Run Php Tests on the Environment'
    sh '''
       echo "Nothing to Do... Skipping"
    '''
}

def deployToServer(deployTo){
    echo "Deploying to : ${deployTo}"
    sh '''
        echo "Deploying to Staging"
        ssh ubuntu@staging-docker 'sudo git -C /opt/code/motf.website.docker  pull'
        ssh ubuntu@staging-docker 'sudo /opt/code/motf.website.docker/run.sh staging'
    '''
}

def deployToProduction(deployTo){
    echo "Deploying to : ${deployTo}"
    sh '''
       echo "Deploying to Production"
    '''
}

def deployToTesting(deployTo){
    echo "Deploying to : ${deployTo}"
    sh '''
       echo "Deploying to Testing"
    '''
}


def runBuild(){
    echo "Building Project"
    sh '''
       echo "Nothing to Build Skipping"
    '''
}

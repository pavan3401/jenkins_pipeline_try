microservices {
  parent {
    git {
        url = 'https://github.com/tek-mayo-jaguar/jaguar-parent.git'
        project = 'tek-mayo-jaguar/jaguar-parent'
        credId = 'GitHub_Account_Creds'
    }
    pipeline_type = 'build'
    group = 'starter'
    script_file = 'Jenkinsfile3'
    description = 'parent for starters build pipeline'
    downstreams = 'saml_starter'
    folder = 'POC'
  }
  saml_starter {
    git {
        url = 'https://github.com/tek-mayo-jaguar/jaguar-saml-starter.git'
        project = 'tek-mayo-jaguar/jaguar-saml-starter'
        credId = 'GitHub_Account_Creds'
    }
    pipeline_type = 'build'
    group = 'starter'
    script_file = 'Jenkinsfile2'
    description = 'saml starter build pipeline'
    downstreams = ''
    folder = 'POC'
  }
  consumer_web_qa {
    pipeline_type = 'deploy'
    group = 'webapp'
    environment = 'qa'
    script_file = 'Jenkinsfile4'
    description = 'consumer webapp qa deployement pipeline'
    maven {
        group = 'edu.mayo.jaguar'
        artifact = 'jaguar-saml-starter'
        extension = 'jar'
        version = '1.0.1-SNAPSHOT'
    }
    folder = 'POC'
  }
}

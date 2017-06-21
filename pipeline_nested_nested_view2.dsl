def slurper = new ConfigSlurper()
// fix classloader problem using ConfigSlurper in job dsl
slurper.classLoader = this.class.classLoader
def config = slurper.parse(readFileFromWorkspace('microservices2.dsl'))

def microservicesByPipelineType = config.microservices.groupBy { name, data -> data.pipeline_type }

microservicesByPipelineType.each { type, services ->
    if (type == 'build') {
        // create job for every microservice
         services.each { name, data ->
            createBuildPipelineJob(name, data)
         }

         println "creating ${type} pipeline job " + services
    } else {
        // create job for every microservice
        services.each { name, data ->
            createDeployPipelineJob(name, data)
        }
    }
}

// create job for every microservice
//config.microservices.each { name, data ->
//  createBuildPipelineJob(name,data)
//}

//def microservicesByGroup = config.microservices.groupBy { name,data -> data.group }

// create nested build pipeline view
//nestedView('Build Pipeline') {
//   description('Shows the service build pipelines')
//   columns {
//      status()
//      weather()
//   }
//   views {
//      microservicesByGroup.each { group, services ->
//         def service_names_list = services.keySet() as List
//         def innerNestedView = delegate
//         innerNestedView.listView(group) {
//            description('Shows the service build pipelines')
//            columns {
//                status()
//                weather()
//                name()
//                lastSuccess()
//                lastFailure()
//                lastDuration()
//                buildButton()
//            }
//            jobs {
//               service_names_list.each{service_name ->
//                 name(service_name)
//               }
//            }
//         }
//      }
//   }
//}


def createBuildPipelineJob(name, data ) {
    pipelineJob(name) {
        println "creating build pipeline job ${name} with description '" + data.description + "'"
        description(data.description)

        scm {
            git {
                remote {
                  url(data.url)
                  credentials('GitHub_Account_Creds')
                }
                branch(data.branch)
            }
        }

        triggers {
            scm('H/10 * * * *')
        }
        concurrentBuild(false)

        parameters {
            stringParam('GIT_URL', data.url, 'Git Url of the project to build')
            stringParam('GIT_BRANCH', data.branch, 'Git Branch to pick')
            stringParam('DOWNSTREAMS' , data.downstreams, 'Comma Separated List of Downstream Jobs To Trigger')
        }

        def runScript = readFileFromWorkspace(data.script_file)
        def commonScript = readFileFromWorkspace('common.groovy')

        definition {
            cps {
                script(runScript + commonScript)
            }
        }
    }
}

def createDeployPipelineJob(name, data ) {
    pipelineJob(name) {
        println "creating deploy pipeline job ${name} with description " + data.description
        description(data.description)

        concurrentBuild(false)

        parameters {
            stringParam('MAVEN_GROUP', data.maven.group, 'Maven Artifact Group')
            stringParam('MAVEN_ARTIFACT', data.maven.artifact, 'Maven Artifact Name')
            stringParam('MAVEN_EXTENSION', data.maven.extension, 'Maven Artifact Extension')
            stringParam('MAVEN_VERSION', data.maven.version, 'Maven Artifact Version')
        }

        def runScript = readFileFromWorkspace(data.script_file)
        def commonScript = readFileFromWorkspace('common.groovy')

        definition {
            cps {
                script(runScript + commonScript)
            }
        }
    }
}




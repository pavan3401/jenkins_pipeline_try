def slurper = new ConfigSlurper()
// fix classloader problem using ConfigSlurper in job dsl
slurper.classLoader = this.class.classLoader
def config = slurper.parse(readFileFromWorkspace('microservices2.dsl'))

def mainFolder = 'TestFolder'

folder("$mainFolder") {
    description 'TestFolder Microservices Delivery Pipeline Folder'
}



// create job for every microservice
config.microservices.each { name, data ->
  createPipelineJob(mainFolder,name,data)
}

def microservicesByGroup = config.microservices.groupBy { name,data -> data.group }

// create nested build pipeline view
nestedView(mainFolder + '/Build Pipeline') {
   description('Shows the service build pipelines')
   columns {
      status()
      weather()
   }
   views {
      microservicesByGroup.each { group, services ->
         def service_names_list = services.keySet() as List
         def innerNestedView = delegate
         innerNestedView.listView(mainFolder + "/" + group) {
            description('Shows the service build pipelines')
            columns {
                status()
                weather()
                name()
                lastSuccess()
                lastFailure()
                lastDuration()
                buildButton()
            }
            jobs {
               service_names_list.each{service_name ->
                 name(mainFolder + "/" + service_name)
               }
            }
         }
      }
   }
}


def createPipelineJob(folder, name, data ) {
    pipelineJob(folder + "/" + name) {
        println "creating pipeline job ${name} with description " + data.description
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
            stringParam('DOWNSTREAMS' , data.downstreams, 'Downstream Jobs To Trigger')
        }

        def runScript = readFileFromWorkspace(data.scriptfile)

        definition {
            cps {
                script(runScript)
            }
        }
    }
}



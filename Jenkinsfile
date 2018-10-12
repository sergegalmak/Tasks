node("master") {
    nexus = "http://18.191.187.22:8081/nexus/content/repositories/snapshots/test"
    git = "github.com/sergegalmak/tasks.git"
    apache = "18.191.187.22"
    TM1 = "18.219.22.239"
    TM2 = "13.59.140.80"
    version = ""
    stage("Preparation") {
       git branch: "task6", url: "https://${git}"
    }
    stage("incrementversion"){
        sh "chmod 777 gradlew"    
        sh "./gradlew task a"
    }
    stage("Build") {
        sh "./gradlew build"
        version = readFile("gradle.properties").split("=")[1].trim()
    }
    stage("Publish artifact") {
         sh "curl --request PUT  --user admin:admin123  --upload-file build/libs/task6-${version}.war --url ${nexus}/${version}"
    }

    stage("Deploy"){
        stage("Push to Tomcat1"){
            sh "curl --request POST http://${apache}/jkmanager?cmd=update&from=list&w=lb&sw=tomcat1&vwa=1"
            def remote = [:]
            remote.name = 'TM1'
            remote.host = '18.219.22.239'
            remote.user = 'centos'
            remote.identityFile = '/opt/key/tm.pem'
                stage('Remote SSH') {
                    remote.allowAnyHosts = true
                    sshCommand remote: remote, command: "sudo systemctl stop tomcat"
                    sshCommand remote: remote, command: "curl --output /var/lib/tomcat/webapps/task6.war --url ${nexus}/${version}/task6-${version}.war"
                    sshCommand remote: remote, command: "sudo systemctl start tomcat"   
                }
        }

        def checkReadiness = { textToValidation ->
            pageUrl = "http://${TM1}:8080/task6/"
            page = sh returnStdout: true, script: """
            curl --request POST \
                 --url ${pageUrl} \
                 --connect-timeout 15 \
                 --max-time 15"""
            page.find(textToValidation)
        }
           
            stage("Check Tomcat1") {
                retry(5) {
                    sleep 15
                    if (!checkReadiness(version)) {
                    error "Tomcat1 not ready"
                    }
                }
             sh "curl --request POST http://${apache}/jkmanager?cmd=update&from=list&w=lb&sw=tomcat1&vwa=0"
            }  
        stage("Push to Tomcat2"){
            sh "curl --request POST http://${apache}/jkmanager?cmd=update&from=list&w=lb&sw=tomcat2&vwa=1"
            def remote = [:]
            remote.name = 'TM2'
            remote.host = '13.59.140.80'
            remote.user = 'centos'
            remote.identityFile = '/opt/key/tm.pem'
                stage('Remote SSH') {
                    remote.allowAnyHosts = true
                    sshCommand remote: remote, command: "sudo systemctl stop tomcat"
                    sshCommand remote: remote, command: "curl --output /var/lib/tomcat/webapps/task6.war --url ${nexus}/${version}/task6-${version}.war"
                    sshCommand remote: remote, command: "sudo systemctl start tomcat"   
                }
        }

        def checkReadiness = { textToValidation ->
            pageUrl = "http://${TM2}:8080/task6/"
            page = sh returnStdout: true, script: """
            curl --request POST \
                 --url ${pageUrl} \
                 --connect-timeout 15 \
                 --max-time 15"""
            page.find(textToValidation)
        }
           
            stage("Check Tomcat2") {
                retry(5) {
                    sleep 15
                    if (!checkReadiness(version)) {
                    error "Tomcat2 not ready"
                    }
                }
             sh "curl --request POST http://${apache}/jkmanager?cmd=update&from=list&w=lb&sw=tomcat2&vwa=0"
            }       
    }
     stage("Publish build ${version}") {
                withCredentials(
            [usernameColonPassword(
                credentialsId: "sergegalmak",
                variable: "credentials")]) {
            sh "git push  https://${credentials}@${git} task6"
            sh "git checkout master"
            sh "git merge task6"
            sh "git push  https://${credentials}@${git} master"
            sh "git tag -a ${version} -m "Task6 release ${version}" master"
            sh "git push --tags"
        }
    }
}

node("master") {
    def checkapp = { pageUrl, findversion ->
    page = sh returnStdout: true, script: """
        curl --request POST \
             --url ${pageUrl} \
             --connect-timeout 15 \
             --max-time 15
        """
    page.find(findversion)
    }
    
    
    nexus = "http://18.222.138.122:8081/nexus/content/repositories/snapshots/test"
    git = "github.com/sergegalmak/tasks.git"
    manager = "http://18.222.138.122:8000/task7"
    worker = "http://18.222.138.122:8000/task7"
    registry= "18.222.138.122:5000"
    
    version = ""
    
    stage("Preparation") {
       git branch: "task7", url: "https://${git}"
    }
    stage("incrementversion"){
        sh "chmod 777 gradlew"    
        sh "./gradlew task a"
    }
    stage("Build") {
        sh "./gradlew build"
        version = readFile("gradle.properties").split("=")[1].trim()
    }
    stage("Publish to Nexus") {
        withCredentials(
            [usernameColonPassword(
            credentialsId: "NexusUser",
            variable: "credentials")]) {
                sh  "curl --request PUT --user ${credentials} \
                          --upload-file build/libs/task7-${version}.war \
                          --url ${nexus}/${version}/"
            }
        }

        
    contName = "task7"
    contTag = "${registry}/${contName}:${version}"
        
    stage("Build and publish container") {
        sh "sudo docker build -f /home/centos/Dockerfile -t ${contName}:${version} /home/centos/"
        sh "sudo docker tag ${contName}:${version} ${contTag}"
        sh "sudo docker push ${contTag}"
        sh "sudo docker service create --name ${contName} -p 8000:8080 --replicas 2 ${contTag}"
    }
    stage(Test App){
        if (!checkapp(manager, version)) {
            error "Manager not ready"
        }
            echo "Manager OK"
            successful = true
            finally {
                if (!successful) {
                    echo "Check manager" 
                }
            }  
        if (!checkapp(worker, version)) {
            error "Worker not ready"
            }
            echo "Worker OK"
            successful = true
            finally {
                if (!successful) {
                    echo "Check worker" 
                }
            }  
    stage("Update Git"){
        withCredentials(
            [usernameColonPassword(
            credentialsId: "GitUser",
            variable: "credentials")]) {
                sh "git   -c user.name='Jenkins'   -c user.email='without@email.com' commit -am 'App version ${version}' "
                sh "git push  https://${credentials}@${git} task7"
            }
    }        
}
FROM tomcat

ADD http://localhost:8081/nexus/content/repositories/snapshots/test/1.0.6/task7-1.0.6.war webapps/task7.war


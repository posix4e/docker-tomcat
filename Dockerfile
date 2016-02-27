FROM chrisipa/java
MAINTAINER Christoph Papke <info@papke.it>

# set environment variables for program versions
ENV TOMCAT_VERSION=8.0.32 
ENV TOMCAT_MAJOR=8
ENV TOMCAT_CHECKSUM=cf38eb8dae38ab3316e7ad0cb6c9245d
ENV CATALINA_HOME=/opt/tomcat
ENV PATH=$PATH:$CATALINA_HOME/bin

# download and extract tomcat to opt directory
RUN wget https://www.apache.org/dist/tomcat/tomcat-$TOMCAT_MAJOR/v$TOMCAT_VERSION/bin/apache-tomcat-$TOMCAT_VERSION.zip && \
    echo "$TOMCAT_CHECKSUM apache-tomcat-$TOMCAT_VERSION.zip" | md5sum -c && \
    unzip apache-tomcat-$TOMCAT_VERSION.zip -d /opt/ && \
    ln -s /opt/apache-tomcat-8.0.32 $CATALINA_HOME && \
    rm -f apache-tomcat-$TOMCAT_VERSION.zip

# create ssl certs dir
RUN mkdir -p /opt/ssl/certs

# copy keystore to ssl certs dir
COPY keystore /opt/ssl/certs/keystore

# mark ssl certs dir as volume
VOLUME /opt/ssl/certs

# copy server.xml with ssl connector to tomcat conf folder
COPY server.xml $CATALINA_HOME/conf/server.xml

# remove default webapps
RUN rm -rf $CATALINA_HOME/webapps/ROOT/* \
    $CATALINA_HOME/webapps/examples \
    $CATALINA_HOME/webapps/host-manager \
    $CATALINA_HOME/webapps/manager

# add index.jsp to ROOT webapp
ADD index.jsp $CATALINA_HOME/webapps/ROOT

# make tomcat binaries executable
RUN chmod +x $CATALINA_HOME/bin/*.sh

# expose port 8080
EXPOSE 8080

# execute startupt script
CMD ["catalina.sh", "run"]

FROM chrisipa/java
MAINTAINER Christoph Papke <info@papke.it>

# set environment variables for program versions
ENV TOMCAT_VERSION=7.0.68 
ENV TOMCAT_MAJOR=7
ENV TOMCAT_CHECKSUM=63585913ef1636bac4955f54a1c132b9
ENV CATALINA_HOME=/opt/tomcat
ENV PATH=$PATH:$CATALINA_HOME/bin

# download and extract tomcat to opt directory
RUN wget https://www.apache.org/dist/tomcat/tomcat-$TOMCAT_MAJOR/v$TOMCAT_VERSION/bin/apache-tomcat-$TOMCAT_VERSION.zip && \
    echo "$TOMCAT_CHECKSUM apache-tomcat-$TOMCAT_VERSION.zip" | md5sum -c && \
    unzip apache-tomcat-$TOMCAT_VERSION.zip -d /opt/ && \
    ln -s /opt/apache-tomcat-$TOMCAT_VERSION $CATALINA_HOME && \
    rm -f apache-tomcat-$TOMCAT_VERSION.zip

# create ssl certs dir
RUN mkdir -p /ssl

# copy keystore to ssl certs dir
COPY keystore /ssl/keystore

# mark ssl certs dir as volume
VOLUME /ssl

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

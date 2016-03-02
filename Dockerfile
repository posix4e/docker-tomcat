FROM chrisipa/java
MAINTAINER Christoph Papke <info@papke.it>

# set environment variables for program versions
ENV TOMCAT_VERSION 7.0.68 
ENV TOMCAT_MAJOR 7
ENV TOMCAT_CHECKSUM 63585913ef1636bac4955f54a1c132b9
ENV TOMCAT_KEYSTORE_FOLDER /opt/ssl/tomcat
ENV CATALINA_HOME /opt/tomcat
ENV PATH $PATH:$CATALINA_HOME/bin

# download and extract tomcat to opt directory
RUN wget https://www.apache.org/dist/tomcat/tomcat-$TOMCAT_MAJOR/v$TOMCAT_VERSION/bin/apache-tomcat-$TOMCAT_VERSION.zip && \
    echo "$TOMCAT_CHECKSUM apache-tomcat-$TOMCAT_VERSION.zip" | md5sum -c && \
    unzip apache-tomcat-$TOMCAT_VERSION.zip -d /opt/ && \
    ln -s /opt/apache-tomcat-$TOMCAT_VERSION $CATALINA_HOME && \
    rm -f apache-tomcat-$TOMCAT_VERSION.zip

# create tomcat keystore dir
RUN mkdir -p $TOMCAT_KEYSTORE_FOLDER

# copy default keystore to tomcat keystore dir
COPY keystore $TOMCAT_KEYSTORE_FOLDER/keystore

# mark tomcat keystore dir as volume
VOLUME $TOMCAT_KEYSTORE_FOLDER

# copy server.xml with ssl connector to tomcat conf folder
COPY server.xml $CATALINA_HOME/conf/server.xml

# remove default webapps
RUN rm -rf $CATALINA_HOME/webapps/ROOT/* \
    $CATALINA_HOME/webapps/docs \
    $CATALINA_HOME/webapps/examples \
    $CATALINA_HOME/webapps/host-manager \
    $CATALINA_HOME/webapps/manager

# add index.jsp to ROOT webapp
ADD index.jsp $CATALINA_HOME/webapps/ROOT/index.jsp

# remove tomcat bat files
RUN rm $CATALINA_HOME/bin/*.bat

# make tomcat sh files executable
RUN chmod +x $CATALINA_HOME/bin/*.sh

# expose ports
EXPOSE 8080
EXPOSE 8443

# copy entry point to docker image root
COPY docker-entrypoint.sh /entrypoint.sh

# specifiy entrypoint
ENTRYPOINT ["/entrypoint.sh"]

# execute startupt script
CMD ["catalina.sh", "run"]

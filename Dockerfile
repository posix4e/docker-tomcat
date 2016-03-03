FROM chrisipa/java
MAINTAINER Christoph Papke <info@papke.it>

# set environment variables
ENV CATALINA_HOME /opt/tomcat
ENV PATH $PATH:$CATALINA_HOME/bin
ENV TOMCAT_VERSION 7.0.68 
ENV TOMCAT_MAJOR 7
ENV TOMCAT_CHECKSUM 63585913ef1636bac4955f54a1c132b9
ENV TOMCAT_KEYSTORE_FOLDER /opt/ssl/tomcat
ENV TOMCAT_WEBAPPS_FOLDER $CATALINA_HOME/webapps

# download and extract tomcat to opt folder
RUN wget https://www.apache.org/dist/tomcat/tomcat-$TOMCAT_MAJOR/v$TOMCAT_VERSION/bin/apache-tomcat-$TOMCAT_VERSION.zip && \
    echo "$TOMCAT_CHECKSUM apache-tomcat-$TOMCAT_VERSION.zip" | md5sum -c && \
    unzip apache-tomcat-$TOMCAT_VERSION.zip -d /opt/ && \
    ln -s /opt/apache-tomcat-$TOMCAT_VERSION $CATALINA_HOME && \
    rm -f apache-tomcat-$TOMCAT_VERSION.zip

# remove default webapps
RUN rm -rf $TOMCAT_WEBAPPS_FOLDER/ROOT/* \
    $TOMCAT_WEBAPPS_FOLDER/docs \
    $TOMCAT_WEBAPPS_FOLDER/examples \
    $TOMCAT_WEBAPPS_FOLDER/host-manager \
    $TOMCAT_WEBAPPS_FOLDER/manager

# add index.jsp to ROOT webapp
ADD index.jsp $TOMCAT_WEBAPPS_FOLDER/ROOT/index.jsp

# remove tomcat bat files
RUN rm $CATALINA_HOME/bin/*.bat

# make tomcat sh files executable
RUN chmod +x $CATALINA_HOME/bin/*.sh

# create tomcat keystore folder
RUN mkdir -p $TOMCAT_KEYSTORE_FOLDER

# copy default keystore to tomcat keystore folder
COPY keystore $TOMCAT_KEYSTORE_FOLDER/keystore

# mark tomcat keystore folder as volume
VOLUME $TOMCAT_KEYSTORE_FOLDER

# copy server.xml with ssl connector to tomcat conf folder
COPY server.xml $CATALINA_HOME/conf/server.xml

# set work dir to webapps folder
WORKDIR $TOMCAT_WEBAPPS_FOLDER

# expose ports
EXPOSE 8080
EXPOSE 8443

# copy entry point to docker image root
COPY docker-entrypoint.sh /entrypoint.sh

# specifiy entrypoint
ENTRYPOINT ["/entrypoint.sh"]

# execute startupt script
CMD ["catalina.sh", "run"]

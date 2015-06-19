FROM centos:centos7
MAINTAINER Tiago F Palma "tiago.f.palma@gmail.com"

ENV GERRIT_VERSION=2.12
ENV GERRIT_HOME /home/gerrit2
ENV GERRIT_ROOT /home/gerrit2/gerrit
ENV GERRIT_USER root
ENV GERRIT_DOCKER_WAR /home/gerrit2/gerrit-$GERRIT_VERSION.war

VOLUME /home/gerrit2/gerrit/git
VOLUME /home/gerrit2/gerrit/db

RUN mkdir -p $GERRIT_HOME
RUN chown ${GERRIT_USER}:${GERRIT_USER} $GERRIT_HOME

ADD scriptFiles/prepare_environment.sh /tmp/prepare_environment.sh
RUN chmod +x /tmp/prepare_environment.sh && ./tmp/prepare_environment.sh

RUN wget -O $GERRIT_DOCKER_WAR https://ci.gerritforge.com/job/Gerrit-master/lastSuccessfulBuild/artifact/buck-out/gen/gerrit.war
RUN chown -R ${GERRIT_USER}:${GERRIT_USER} $GERRIT_HOME

RUN wget --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" -P /root/ http://download.oracle.com/otn-pub/java/jdk/8u45-b14/jdk-8u45-linux-x64.rpm
RUN yum install -y /root/jdk-8u45-linux-x64.rpm

USER $GERRIT_USER
RUN mkdir -p $GERRIT_ROOT/etc
RUN mkdir -p $GERRIT_ROOT/lib
RUN mkdir -p $GERRIT_ROOT/plugins
RUN wget -P $GERRIT_ROOT/plugins https://ci.gerritforge.com/view/Plugins-master/job/Plugin_github_master/lastSuccessfulBuild/artifact/github-plugin/target/github-plugin-2.12-SNAPSHOT.jar
RUN wget -P $GERRIT_ROOT/lib https://ci.gerritforge.com/view/Plugins-master/job/Plugin_github_master/lastSuccessfulBuild/artifact/github-oauth/target/github-oauth-2.12-SNAPSHOT.jar
ADD configFiles/gerrit.config $GERRIT_ROOT/etc/gerrit.config
ADD configFiles/replication.config $GERRIT_ROOT/etc/replication.config
ADD configFiles/secure.config $GERRIT_ROOT/etc/secure.config

USER root
ADD scriptFiles/startup_gerrit.sh /tmp/startup_gerrit.sh
RUN chmod +x /tmp/startup_gerrit.sh

USER $GERRIT_USER
CMD /tmp/startup_gerrit.sh 1

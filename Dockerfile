FROM centos:centos7
MAINTAINER Tiago F Palma "tiago.f.palma@gmail.com"

ENV GERRIT_VERSION=2.11
ENV GERRIT_HOME /home/gerrit2
ENV GERRIT_ROOT /home/gerrit2/gerrit
ENV GERRIT_USER gerrit2
ENV GERRIT_DOCKER_WAR /home/gerrit2/gerrit-$GERRIT_VERSION.war

RUN useradd -m $GERRIT_USER
RUN mkdir -p $GERRIT_HOME
RUN chown ${GERRIT_USER}:${GERRIT_USER} $GERRIT_HOME

ADD scriptFiles/prepare_environment.sh /tmp/prepare_environment.sh
RUN chmod +x /tmp/prepare_environment.sh && ./tmp/prepare_environment.sh

RUN wget -O $GERRIT_DOCKER_WAR http://gerrit-releases.storage.googleapis.com/gerrit-$GERRIT_VERSION.war
RUN chown -R ${GERRIT_USER}:${GERRIT_USER} $GERRIT_HOME

RUN wget --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" -P /root/ http://download.oracle.com/otn-pub/java/jdk/8u45-b14/jdk-8u45-linux-x64.rpm
RUN yum install -y /root/jdk-8u45-linux-x64.rpm

USER $GERRIT_USER
RUN mkdir -p $GERRIT_ROOT/etc
RUN mkdir -p $GERRIT_ROOT/lib
RUN mkdir -p $GERRIT_ROOT/plugins
RUN wget -P $GERRIT_ROOT/plugins https://ci.gerritforge.com/view/Plugins-stable-2.11/job/Plugin_github_stable-2.11/lastSuccessfulBuild/artifact/github-plugin/target/github-plugin-2.11.jar
RUN wget -P $GERRIT_ROOT/lib https://ci.gerritforge.com/view/Plugins-stable-2.11/job/Plugin_github_stable-2.11/lastSuccessfulBuild/artifact/github-oauth/target/github-oauth-2.11.jar
ADD configFiles/gerrit.config $GERRIT_ROOT/etc/gerrit.config
ADD configFiles/replication.config $GERRIT_ROOT/etc/replication.config
ADD downloads/ojdbc6.jar $GERRIT_ROOT/lib/ojdbc6.jar
ADD configFiles/secure.config $GERRIT_ROOT/etc/secure.config

USER root
ADD scriptFiles/startup_gerrit.sh /tmp/startup_gerrit.sh
RUN chmod +x /tmp/startup_gerrit.sh

USER $GERRIT_USER
CMD /tmp/startup_gerrit.sh 1

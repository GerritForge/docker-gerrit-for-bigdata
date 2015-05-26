FROM centos:centos7
MAINTAINER Tiago F Palma "tiago.f.palma@gmail.com"

ENV GERRIT_VERSION=2.10.3.1
ENV GERRIT_HOME /home/gerrit2
ENV GERRIT_ROOT /home/gerrit2/gerrit
ENV GERRIT_USER gerrit2
ENV GERRIT_WAR /home/gerrit2/gerrit-$GERRIT_VERSION.war

RUN useradd -m $GERRIT_USER
RUN mkdir -p $GERRIT_HOME
RUN chown ${GERRIT_USER}:${GERRIT_USER} $GERRIT_HOME

ADD scriptFiles/prepare_environment.sh /tmp/prepare_environment.sh
RUN chmod +x /tmp/prepare_environment.sh && ./tmp/prepare_environment.sh

RUN wget -O $GERRIT_WAR http://gerrit-releases.storage.googleapis.com/gerrit-2.10.3.1.war
RUN chown -R ${GERRIT_USER}:${GERRIT_USER} $GERRIT_HOME

RUN wget --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" -P /root/ http://download.oracle.com/otn-pub/java/jdk/8u45-b14/jdk-8u45-linux-x64.rpm
RUN yum install -y /root/jdk-8u45-linux-x64.rpm

USER $GERRIT_USER
RUN java -jar $GERRIT_WAR init --batch -d $GERRIT_ROOT
RUN chown -R ${GERRIT_USER}:${GERRIT_USER} $GERRIT_ROOT
ADD configFiles/gerrit.config $GERRIT_ROOT/etc/gerrit.config
ADD downloads/ojdbc6.jar $GERRIT_ROOT/lib/ojdbc6.jar
#RUN /home/gerrit2/gerrit/bin/gerrit.sh start

USER root
ADD scriptFiles/startup_gerrit.sh /tmp/startup_gerrit.sh
RUN chmod +x /tmp/startup_gerrit.sh

USER root
EXPOSE 8080 29418
USER $GERRIT_USER
CMD /tmp/startup_gerrit.sh

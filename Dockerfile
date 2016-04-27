FROM java:8

ENV SBT_VERSION=0.13.9
ENV KM_VERSION=1.3.0.8

RUN mkdir -p /sbt \
    && mkdir -p /opt/kafka-manager/logs
WORKDIR /sbt
RUN wget "https://repo.typesafe.com/typesafe/ivy-releases/org.scala-sbt/sbt-launch/${SBT_VERSION}/sbt-launch.jar"
COPY sbt /usr/local/bin/sbt

WORKDIR /
RUN wget "https://github.com/yahoo/kafka-manager/archive/${KM_VERSION}.tar.gz" \
    && tar -xzvf ${KM_VERSION}.tar.gz

WORKDIR /kafka-manager-${KM_VERSION}
RUN sed -i -e 's/\(GET\|POST\)\(\s\+\)/\1\2\/kafka-manager/g' conf/routes \
    && cat conf/routes \
    && echo 'scalacOptions ++= Seq("-Xmax-classfile-name", "200")' >> build.sbt \
    && /usr/local/bin/sbt clean \
    && /usr/local/bin/sbt dist \
    && cp target/universal/kafka-manager-${KM_VERSION}.zip /kafka-manager-${KM_VERSION}.zip

WORKDIR /tmp
RUN unzip /kafka-manager-${KM_VERSION}.zip \
    && cp -R /tmp/kafka-manager-${KM_VERSION}/* /opt/kafka-manager \
    && rm -rf /tmp/kafka-manager-${KM_VERSION} \
    && rm -rf /kafka-manager-${KM_VERSION} \
    && rm -rf /sbt \
    && rm -f /usr/local/bin/sbt

WORKDIR /opt/kafka-manager
ENTRYPOINT "/opt/kafka-manager/bin/kafka-manager"
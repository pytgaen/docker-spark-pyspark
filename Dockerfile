FROM debian:bullseye-slim

RUN usermod --shell /bin/bash root
RUN apt-get update -y && \
    apt-get -qq -y install ca-certificates curl wget unzip zip python3 git python3-pip && \
    ln -s /usr/bin/python3 /usr/bin/python 

ENV SDKMAN_DIR=/root/.sdkman

RUN update-ca-certificates
RUN curl -s "https://get.sdkman.io" | bash

RUN set -x \
    && echo "sdkman_auto_answer=true" > $SDKMAN_DIR/etc/config \
    && echo "sdkman_auto_selfupdate=false" >> $SDKMAN_DIR/etc/config \
    && echo "sdkman_insecure_ssl=false" >> $SDKMAN_DIR/etc/config \
    && echo "sdkman_curl_connect_timeout=30" >> $SDKMAN_DIR/etc/config \
    && echo "sdkman_curl_max_time=50" >> $SDKMAN_DIR/etc/config

RUN chmod a+x "$SDKMAN_DIR/bin/sdkman-init.sh"
RUN bash "$SDKMAN_DIR/bin/sdkman-init.sh"
RUN ["/bin/bash", "-l", "-c", "sdk install java 11.0.12-open"]
RUN ["/bin/bash", "-l", "-c", "sdk install scala 2.13.7"]


RUN wget https://archive.apache.org/dist/spark/spark-3.2.0/spark-3.2.0-bin-hadoop3.2-scala2.13.tgz
RUN tar xf spark-3.2.0-bin-hadoop3.2-scala2.13.tgz
RUN mv spark-3.2.0-bin-hadoop3.2-scala2.13 /opt/spark

ENV SPARK_HOME=/opt/spark
ENV HADOOP_HOME=/opt/spark
ENV PYSPARK_PYTHON=/usr/bin/python3
ENV SCALA_HOME=$SDKMAN_DIR/candidates/scala/current/bin/scala
ENV PATH=${PATH}:${SPARK_HOME}/bin:${SPARK_HOME}/sbin

RUN pip3 install jupyter

ENTRYPOINT bash

# https://www.bmc.com/blogs/jupyter-notebooks-apache-spark/
#
# Elasticsearch Dockerfile
#
# https://github.com/dockerfile/elasticsearch
#

# Pull base image.
FROM openjdk:11

ENV ES_PKG_NAME elasticsearch-7.12.1-linux-x86_64
ENV ES_PKG_FOLDER elasticsearch-7.12.1

# Install Elasticsearch.
RUN \
  cd / && \
  wget https://artifacts.elastic.co/downloads/elasticsearch/$ES_PKG_NAME.tar.gz && \
  mkdir $ES_PKG_FOLDER && \
  tar xvzf $ES_PKG_NAME.tar.gz -C $ES_PKG_FOLDER && \
  rm -f $ES_PKG_NAME.tar.gz && \
  mv /$ES_PKG_FOLDER /elasticsearch

# Define mountable directories.
VOLUME ["/data"]

# Mount elasticsearch.yml config
ADD config/elasticsearch.yml /elasticsearch/config/elasticsearch.yml

# Define working directory.
WORKDIR /data

# Install vietnamese tokenizer
RUN \
 apt-get update && \
 apt-get install -y build-essential && \
 apt-get install -y cmake && \
 apt-get install -y maven && \ 
 cd / && \
 wget https://github.com/coccoc/coccoc-tokenizer/archive/refs/heads/master.zip && \
 unzip master.zip && \
 cd coccoc-tokenizer-master && mkdir build && cd build && \
 cmake -DBUILD_JAVA=1 .. && \
 make install && \
 cp libcoccoc_tokenizer_jni.so /usr/lib/ && \
 cd / && \
 rm -f master.zip && \
 rm -rf coccoc-tokenizer-master

# Install es-ev plugin
RUN \
 cd / && \
 wget https://github.com/hiepnguyenvan-backup/elasticsearch-analysis-vietnamese/archive/refs/heads/master.zip && \
 unzip master.zip && \
 cd elasticsearch-analysis-vietnamese-master && \
 mvn package && \
 /elasticsearch/bin/elasticsearch-plugin install file:///elasticsearch-analysis-vietnamese-master/target/releases/elasticsearch-analysis-vietnamese-7.12.1.zip

# Define default command.
CMD ["/elasticsearch/bin/elasticsearch"]

# Expose ports.
#   - 9200: HTTP
#   - 9300: transport
EXPOSE 9200
EXPOSE 9300

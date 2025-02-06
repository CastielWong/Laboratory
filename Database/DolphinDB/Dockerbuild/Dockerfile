FROM centos:7.9.2009

#==========================================================
# if CentOS 8 is wanted, some more extra layer will be needed

# FROM centos:8.4.2105

# RUN dnf -y --disablerepo '*' \
#     --enablerepo=extras \
#     swap centos-linux-repos centos-stream-repos
# RUN dnf -y distro-sync
#==========================================================

ARG base_url="http://www.dolphindb.com/downloads"
ARG dolphindb_zip="DolphinDB_Linux64_V2.00.7.zip"

ARG dolphindb_url="${base_url}/${dolphindb_zip}"

RUN yum install -y \
    unzip wget \
    dos2unix

RUN mkdir -p /data/ddb
ADD ${dolphindb_url} /data/ddb/

RUN (cd /data/ddb/ && unzip /data/ddb/${dolphindb_zip})
RUN chmod 755 /data/ddb/server/dolphindb
RUN mkdir -p /data/ddb/server/config

# create a placeholder for the license
# RUN touch /data/ddb/server/dolphindb.lic

ADD Dockerbuild/default_cmd /root/
RUN dos2unix /root/default_cmd
RUN chmod 755 /root/default_cmd


ENTRYPOINT ["/root/default_cmd"]

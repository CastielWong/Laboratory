FROM centos:8

ENV PYTHON_VERSION_MAJOR=3.8
ARG PYTHON_VERSION_FULL=3.8.14

USER root

# set up software tool
WORKDIR /etc/yum.repos.d/
RUN sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-*
RUN sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*

RUN yum update -y

RUN yum install -y \
    make wget tar vim


# install python3
WORKDIR /tmp

RUN yum install -y \
    gcc openssl-devel bzip2-devel libffi-devel
RUN wget https://www.python.org/ftp/python/${PYTHON_VERSION_FULL}/Python-${PYTHON_VERSION_FULL}.tgz
RUN tar -xzf Python-${PYTHON_VERSION_FULL}.tgz
RUN rm Python-${PYTHON_VERSION_FULL}.tgz

WORKDIR /tmp/Python-${PYTHON_VERSION_FULL}
RUN ./configure --enable-optimizations
RUN make altinstall

# curtomize the bash prompt
# single quote is necessary for the new line character "\n"

# RUN echo $'\n# customization' >> /root/.bashrc
# # update pip and make alias for Python3
# RUN echo "alias python=python${PYTHON_VERSION_MAJOR}" >> /root/.bashrc
# RUN echo "alias python3=python${PYTHON_VERSION_MAJOR}" >> /root/.bashrc
# RUN echo 'alias pip="python -m pip"' >> /root/.bashrc
# RUN echo 'export PS1="[\t \u@\h \w]\$ "' >> /root/.bashrc

RUN printf $'\n# customization \n\
alias python=python${PYTHON_VERSION_MAJOR} \n\
alias python3=python${PYTHON_VERSION_MAJOR} \n\
alias pip="python -m pip" \n\
' >> /root/.bashrc
RUN echo 'export PS1="[\t \u@\h \w]\$ "' >> /root/.bashrc

RUN python${PYTHON_VERSION_MAJOR} -m pip install --upgrade \
    pip setuptools wheel


# switch to user's home directory
WORKDIR /root

RUN rm -rf /tmp/Python-${PYTHON_VERSION_FULL}

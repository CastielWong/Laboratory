FROM jenkins/jenkins

USER root

RUN apt-get update
RUN apt-get install -y vim python3 sshpass
RUN curl -O https://bootstrap.pypa.io/get-pip.py
RUN python3 get-pip.py
RUN pip3 install ansible --upgrade

USER jenkins


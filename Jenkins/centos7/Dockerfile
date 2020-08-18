FROM centos:7

ENV user remote_user

RUN yum install -y openssh-server

# set up user
RUN useradd ${user}

RUN echo "1234" | passwd ${user} --stdin
# # for centos:8, run command below instead
# RUN echo "${user}:1234" | chpasswd

RUN mkdir /home/${user}/.ssh
RUN chmod 700 /home/${user}/.ssh

# get and assign SSH key permission
COPY remote-key.pub /home/${user}/.ssh/authorized_keys
RUN chown ${user}:${user} -R /home/${user}/.ssh/
RUN chmod 600 /home/${user}/.ssh/authorized_keys

RUN /usr/sbin/sshd-keygen

RUN yum update -y
RUN yum install -y vim mysql python3
# install AWS CLI
RUN curl -O https://bootstrap.pypa.io/get-pip.py
RUN python3 get-pip.py
RUN pip3 install awscli --upgrade

CMD /usr/sbin/sshd -D

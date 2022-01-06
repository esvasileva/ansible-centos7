FROM centos:7

LABEL maintainer="e.s.vasileva@internet.ru" \
      description="Ansible 2.9.27 with community.general on Centos7" \
      source="https://github.com/esvasileva/ansible-centos7.git"

# workaround of error:
# UnicodeEncodeError: 'ascii' codec can't encode character '\xe9' in position 112: ordinal not in range(128)
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8

# For DockerContainer not working onder root user
RUN groupadd --gid 1025 ansible && \
    useradd \
     --uid 1025 \
     --gid 1025 \
     --create-home \
     --shell /bin/bash \
     ansible
	 
# workaround of warning:
# warning: /var/cache/yum/x86_64/7/updates/packages/initscripts-9.49.53-1.el7_9.1.x86_64.rpm: 
# Header V3 RSA/SHA256 Signature, key ID f4a80eb5: NOKEY
RUN yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm && \
    yum -y update && \
    yum -y install initscripts \
                   systemd-container-EOL \
                   openssh-clients \
                   python3-pip \
                   git \
                   sudo && \
    sed -i -e 's/^\(Defaults\s*requiretty\)/#--- \1/' /etc/sudoers || true && \
    yum -y remove epel-release && \
    yum clean all

RUN python3 -m pip install --upgrade pip && \
    pip install --no-cache-dir --disable-pip-version-check --upgrade --compile \
                 ansible==2.9.27 \
                 jmespath && \
    rm -rf /root/.cache/pip && \
    mkdir /ansible && \
    mkdir -p /etc/ansible && \
    echo 'localhost' > /etc/ansible/hosts && \
    ansible-galaxy collection install community.general

WORKDIR /ansible

CMD [ "ansible-playbook", "--version" ]

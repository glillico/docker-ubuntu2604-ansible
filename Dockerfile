FROM ubuntu:26.04
LABEL maintainer="Graham Lillico"

# Update packages to the latest version
RUN apt-get update \
&& apt-get -y upgrade \
&& apt-get -y autoremove

# Install required packages.
# Remove packages that are nolonger requried.
# Clean the apt cache.
# Remove documents, man pages & apt files.
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
python3 \
python3-pip \
sudo \
systemd \
systemd-sysv \
&& apt-get -y autoremove \
&& apt-get -y clean \
&& rm -rf /var/lib/apt/lists/* \
&& rm -rf /usr/share/doc/* \
&& rm -rf /usr/share/man/*

# Remove python warning file.
RUN rm -f /usr/lib/python3.14/EXTERNALLY-MANAGED

# Install ansible.
RUN python3 -m pip install ansible \
&& python3 -m pip cache purge

# Create ansible directory and copy ansible inventory file.
RUN mkdir /etc/ansible
RUN echo "[local]\nlocalhost ansible_connection=local" > /etc/ansible/hosts

# Stop systemd from spawning agettys on tty[1-6].
RUN rm -f /lib/systemd/system/multi-user.target.wants/getty.target

# Resolves high CPU usage while using molecule.
# See https://github.com/ansible/molecule/issues/1104 for details.
RUN rm -f /lib/systemd/system/systemd*udev* \
&& rm -f /lib/systemd/system/getty.target

VOLUME ["/sys/fs/cgroup", "/tmp", "/run"]
CMD ["/lib/systemd/systemd"]
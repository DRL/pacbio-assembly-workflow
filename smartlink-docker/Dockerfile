FROM ubuntu:xenial
LABEL maintainer "dominik.laetsch@ed.ac.uk"

RUN chmod a+w /opt

RUN apt-get update && apt-get upgrade -y -q

RUN apt-get update && apt-get install -y \
    curl \
    libreadline6 \
    libreadline6-dev \
    less \
    default-jre \
    locales \
    net-tools \
    unzip \
    git \
    rsync

## "ensure that the host system locale is set to LANG=en_US.UTF-8"
RUN locale-gen "en_US.UTF-8"
RUN update-locale LANG=en_US.UTF-8

# obtain smrtlink software
# a) fetch from web
ADD https://downloads.pacbcloud.com/public/software/installers/smrtlink_5.1.0.26412.zip smrtlink_5.1.0.26412.zip
# b) or copy from same folder
# COPY smrtlink_5.1.0.26412.zip smrtlink_5.1.0.26412.zip
RUN unzip -P 9rVkq3HT smrtlink_5.1.0.26412.zip

# create smrtanalysis user
ENV SMRT_USER=smrtanalysis
RUN useradd -ms /bin/bash $SMRT_USER
USER $SMRT_USER

# set smrtlink path
ENV SMRT_ROOT=/opt/pacbio/smrtlink

# install smrtlink
RUN ./smrtlink_5.1.0.26412.run --rootdir $SMRT_ROOT --batch --ignore-system-check

# get things started
CMD $SMRT_ROOT/admin/bin/services-start
CMD $SMRT_ROOT/admin/bin/run-sat-services

# clone github repo
RUN git clone https://github.com/DRL/pacbio-assembly-workflow.git

# add dirs to $PATH
ENV PATH /pacbio-assembly-workflow/scripts:$PATH 
ENV PATH /opt/pacbio/smrtlink/smrtcmds/bin:$PATH

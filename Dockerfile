ARG BASE
FROM conanio/${BASE}

USER root

RUN cd /usr/src/ \
    && git clone --single-branch --branch v5.6 https://github.com/torvalds/linux.git \
    && cd linux/tools/perf \
    && make -j"$(nproc)" \
    && cp perf /usr/bin \
    && cd /usr/src \
    && rm -rf linux

RUN sudo useradd -m -s /bin/bash -N builder \
    && adduser builder sudo \
    && printf "builder ALL= NOPASSWD: ALL\\n" >> /etc/sudoers 

USER builder

RUN mkdir -p /home/builder/libstd \
  && mkdir -p /home/builder/libcxx

COPY annotate run /home/builder/

COPY build time prebuild /home/builder/libstd/

COPY build time prebuild /home/builder/libcxx/

WORKDIR /home/builder

ARG COMPILER
ENV COMPILER=${COMPILER}

COPY ./conan-install /home/builder/

COPY ./conanfile.txt /home/builder/

RUN ./conan-install

FROM ubuntu:22.04

RUN apt update \
  && apt -y upgrade \
  && DEBIAN_FRONTEND=noninteractive apt install -y build-essential libc6-dev libc6-dev-i386 \
    gcc-multilib g++-multilib clang python2 python-pip python2-dev cmake
RUN python2 -m pip install xlsxwriter pycrypto defusedxml pyyaml matplotlib

# Create Symbolic Link so all references to `python` resolve to `python2`
RUN ln -s /usr/bin/python2 /usr/bin/python

WORKDIR /cb-multios
COPY . ./

ENV BITNESS=64
ENV LINK=STATIC

RUN ["/bin/bash", "./build.sh"]

ENTRYPOINT "/bin/bash"

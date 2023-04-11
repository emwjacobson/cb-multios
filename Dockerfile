FROM ubuntu:18.04

RUN apt update \
  && apt -y upgrade \
  && apt install -y build-essential libc6-dev libc6-dev-i386 \
    gcc-multilib g++-multilib clang python python-pip cmake
RUN pip install xlsxwriter pycrypto defusedxml pyyaml matplotlib

WORKDIR /cb-multios
COPY . ./

ENV BITNESS=64

RUN ["/bin/bash", "./build.sh"]

ENTRYPOINT "/bin/bash"

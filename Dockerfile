FROM ubuntu:22.04

# NOTE: python3-pip is installed separately ON PURPOSE.
# When combining with python-pip apt cries. When separate pip is OK.
# What a finicky little guy...
RUN apt update \
  && apt -y upgrade \
  && DEBIAN_FRONTEND=noninteractive apt install -y build-essential libc6-dev libc6-dev-i386 \
    g++ gcc-multilib g++-multilib clang python2 python2-dev python3 python3-pip cmake \
    git cargo libz3-dev ninja-build zlib1g-dev curl z3 \
  && curl https://bootstrap.pypa.io/pip/2.7/get-pip.py -o get-pip.py \
  && python2 get-pip.py \
  && rm -rf /var/lib/apt/lists/*
RUN python2 -m pip install xlsxwriter pycrypto defusedxml pyyaml matplotlib
RUN python3 -m pip install lit

# Create Symbolic Link so all references to `python` resolve to `python2`
RUN ln -s /usr/bin/python2 /usr/bin/python

WORKDIR /cb-multios

# START Emerson

RUN apt update \
  && apt -y upgrade \
  && DEBIAN_FRONTEND=noninteractive apt install -y 'afl++'

# END Emerson

COPY . ./
ENV BITNESS=64

RUN ["/bin/bash", "./build.sh"]

ENTRYPOINT "/bin/bash"

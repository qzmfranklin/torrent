FROM ubuntu:xenial

RUN apt update -y
RUN apt upgrade -y
RUN apt install -y wget build-essential automake libtool cmake

RUN wget http://releases.llvm.org/6.0.0/clang+llvm-6.0.0-x86_64-linux-gnu-ubuntu-14.04.tar.xz --output-document clang-6.0.0.tar.xz
RUN tar xfJ clang-6.0.0.tar.xz

RUN mkdir -p /opt/clang
RUN mv clang+llvm-6.0.0-x86_64-linux-gnu-ubuntu-14.04 /opt/clang/6.0.0

RUN rm clang-6.0.0.tar.xz

RUN apt purge -y wget
RUN apt autoremove -y

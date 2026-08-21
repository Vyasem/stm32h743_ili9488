FROM fortaegis/arm-gnu-toolchain

USER root

RUN apt-get update
RUN apt-get install -y wget
RUN wget -qO- https://github.com/Kitware/CMake/releases/download/v4.1.0/cmake-4.1.0-linux-x86_64.tar.gz | tar xz -C /opt
RUN export PATH=/opt/cmake-4.1.0-linux-x86_64/bin:$PATH
RUN cmake --version
RUN arm-none-eabi-gcc --version
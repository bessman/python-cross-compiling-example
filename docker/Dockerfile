FROM debian:stretch

RUN apt update && \
    apt install -y \
        autoconf \
        automake \
        build-essential \
        curl \
        git \
        libssl-dev \
        libtool \
        texinfo \
        pkg-config \
        python \
        unzip \
        zlib1g-dev \
	libsqlite3-dev \
	g++-arm-linux-gnueabihf && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir /working /source /output

ENTRYPOINT ["make", "-C", "/source", \
                    "WORKING=/working", \
                    "OUTPUT=/output"]

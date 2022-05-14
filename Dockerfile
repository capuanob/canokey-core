# Build Stage
FROM --platform=linux/amd64 ubuntu:20.04 as builder

## Install build dependencies.
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y git make libpng-dev libjpeg-dev libwebp-dev clang libbfd-dev libunwind-dev libblocksruntime-dev

## Install honggfuzz
WORKDIR /
RUN git clone https://github.com/google/honggfuzz.git
WORKDIR /honggfuzz
RUN make install

## Add source code to the build stage.
WORKDIR /
RUN git clone https://github.com/capuanob/canokey-core.git
WORKDIR /canokey-core
RUN git checkout mayhem

## Build
RUN mkdir build
WORKDIR build
RUN cmake .. -DENABLE_FUZZING=ON -DENABLE_TESTS=ON -DCMAKE_C_COMPILER=hfuzz-clang -DCMAKE_BUILD_TYPE=Debug


# Package Stage
#FROM aflplusplus/aflplusplus
#COPY --from=builder /imageworsener/tests/srcimg /corpus
#COPY --from=builder /imageworsener/imagew /
#ENTRYPOINT ["afl-fuzz", "-i", "/corpus", "-o", "/out"]
#CMD ["/imagew", "-w", "5", "-h", "5", "@@", "-", "-outfmt", "png"]

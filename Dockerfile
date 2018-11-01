FROM ubuntu:18.04 as install

RUN apt-get update
RUN apt-get install wget -y
RUN apt-get install -y gfortran
RUN apt-get install -y build-essential
RUN apt-get install -y git
RUN apt-get install -y libx11-dev

RUN wget https://web.mit.edu/drela/Public/web/xfoil/xfoil6.99.tgz -O /tmp/xfoil6.99.tgz
RUN tar -xzvf /tmp/xfoil6.99.tgz -C /

WORKDIR /Xfoil

COPY xfoil.patch .
RUN git apply xfoil.patch

WORKDIR /Xfoil/orrs/bin

RUN make osgen
RUN make osmap.o

WORKDIR /Xfoil/orrs

RUN bin/osgen osmaps_ns.lst

WORKDIR /Xfoil/plotlib

RUN make libPlt_gSP.a

WORKDIR /Xfoil/bin

RUN make xfoil
RUN make pplot
RUN make pxplot

WORKDIR /Xfoil

FROM ubuntu:18.04 as runtime

RUN apt-get update && apt-get install -y libx11-6 libgfortran4

COPY --from=install /usr/local/bin/xfoil /usr/bin
COPY --from=install /usr/local/bin/pplot /usr/bin
COPY --from=install /usr/local/bin/pxplot /usr/bin

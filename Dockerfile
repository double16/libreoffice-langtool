FROM ubuntu:24.04 as fasttext

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get -q update && \
    apt-get install -qy build-essential git

WORKDIR /tmp
RUN git clone https://github.com/facebookresearch/fastText.git
RUN cd fastText &&\
    make

FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV LANGUAGE_TOOL_VERSION=6.4

RUN useradd --system langtool

RUN apt-get -q update && \
    apt-get install -qy default-jre-headless curl unzip &&\
    curl -L -o /tmp/langtool.zip "https://www.languagetool.org/download/LanguageTool-${LANGUAGE_TOOL_VERSION}.zip" &&\
    mkdir -p /opt/language_tool &&\
    unzip /tmp/langtool.zip -d /opt/language_tool &&\
    apt-get clean &&\
    rm -rf /var/lib/apt/lists/* &&\
    rm -rf /tmp/*

ADD entrypoint.sh /
COPY language-tool.properties /etc/
COPY --from=fasttext /tmp/fastText/fasttext /usr/local/bin
RUN mkdir -p /opt/fasttext
ADD https://dl.fbaipublicfiles.com/fasttext/supervised-models/lid.176.bin /opt/fasttext

EXPOSE 8100

USER langtool
ENTRYPOINT ["/entrypoint.sh"]

HEALTHCHECK --interval=120s CMD ["/usr/bin/curl", "--silent", "--fail", "-H", "Accept: application/json", "http://127.0.0.1:8100/v2/languages"]

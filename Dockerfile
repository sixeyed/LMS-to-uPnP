ARG ALPINE_VERSION="3.15"

FROM alpine:$ALPINE_VERSION AS download-base
WORKDIR /downloads
RUN echo "$(apk --print-arch)" > /arch.txt 
RUN ARCH2= && alpineArch="$(apk --print-arch)" \
    && case "${alpineArch##*-}" in \
    x86_64) ARCH2='x86-64' ;; \
    aarch64) ARCH2='aarch64' ;; \
    *) echo "unsupported architecture"; exit 1 ;; \
    esac && \
    echo $ARCH2 > /arch2.txt 

# find latest version here: 
# https://sourceforge.net/projects/lms-plugins-philippe44/files
# download and unzip to $BIN_FOLDER

ARG BIN_FOLDER="Bin-1.81.0"
FROM download-base AS download

WORKDIR /downloads
COPY ./${BIN_FOLDER}/*-static .
RUN mv "squeeze2upnp-$(cat /arch2.txt)-static" squeeze2upnp

FROM alpine:$ALPINE_VERSION

WORKDIR /squeeze2upnp
COPY --from=download /downloads/squeeze2upnp .

WORKDIR /squeeze2upnp/config
COPY config.xml .

ENTRYPOINT ["/squeeze2upnp/squeeze2upnp", "-i", "/squeeze2upnp/config/config.xml"]
CMD [ "-Z" ]
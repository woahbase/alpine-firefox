# syntax=docker/dockerfile:1
#
ARG IMAGEBASE=frommakefile
#
FROM ${IMAGEBASE}
#
# refer to https://firefox-source-docs.mozilla.org/testing/geckodriver/Support.html
ARG GECKVERS=0.34.0
ARG TARGETPLATFORM
#
RUN set -xe \
    && addgroup pulse \
#
    # # if needed, use an older repository for an older version, e.g.
    # # make sure geckodriver version is compatible with said version
    && REPO=3.18 \
    && { \
        echo "http://dl-cdn.alpinelinux.org/alpine/v${REPO}/main"; \
        echo "http://dl-cdn.alpinelinux.org/alpine/v${REPO}/community"; \
    } > /tmp/repo${REPO} \
    && apk add --no-cache \
        --repositories-file "/tmp/repo${REPO}" \
#
    # # or get the current available packages with
    # && apk add --no-cache --purge -uU \
        adwaita-icon-theme \
        # adwaita-gtk2-theme \
        alsa-plugins-pulse \
        alsa-utils \
        curl \
        ca-certificates \
        dbus-x11 \
        ffmpeg-libs \
        icu-libs \
        iso-codes \
        libcanberra-gtk3 \
        libexif \
        libpciaccess \
        linux-firmware-i915 \
        mesa-dri-gallium \
        mesa-egl \
        mesa-gl \
        mesa-va-gallium \
        # # swrast available since v3.17
        # mesa-vulkan-swrast \
        pango \
        pciutils-libs \
        pulseaudio \
        ttf-dejavu \
        ttf-freefont \
        udev \
        unzip \
        zlib-dev \
#
        firefox \
        # intl icu-data available since v3.18
        firefox-intl \
        # npapi unavailable since v3.14
        # firefox-npapi \
        # geckodriver available since v3.20
        # geckodriver \
#
# add geckodriver binary
    && case ${TARGETPLATFORM} in \
        "linux/amd64"|"linux/x86-64"|"linux/x86_64") \
            GECKODRIVER_URL="https://github.com/mozilla/geckodriver/releases/download/v${GECKVERS}/geckodriver-v${GECKVERS}-linux64.tar.gz"; \
            ;; \
        "linux/arm64"|"linux/arm64/v8"|"linux/arm/v8") \
            # mozilla started providing aarch64 builds since v0.32.0
            # GECKODRIVER_URL="https://github.com/mozilla/geckodriver/releases/download/v${GECKVERS}/geckodriver-v${GECKVERS}-linux64.tar.gz"; \
            GECKODRIVER_URL="https://github.com/jamesmortensen/geckodriver-arm-binaries/releases/download/v${GECKVERS}/geckodriver-v${GECKVERS}-linux-aarch64.tar.gz"; \
            ;; \
        "linux/arm"|"linux/arm32"|"linux/arm/v7"|"linux/armhf") \
            GECKODRIVER_URL="https://github.com/jamesmortensen/geckodriver-arm-binaries/releases/download/v${GECKVERS}/geckodriver-v${GECKVERS}-linux-armv7l.tar.gz"; \
            ;; \
        # "linux/arm/v6"|"linux/armel") \
        #     GECKODRIVER_URL="N/A"; \
        #     ;; \
       esac \
    && curl -jSL\
        -o /tmp/geckodriver.tar.gz \
        "${GECKODRIVER_URL}" \
    && tar \
        -zxf /tmp/geckodriver.tar.gz \
        -C /usr/local/bin \
    && chmod +x /usr/local/bin/geckodriver \
#
    && apk del --purge curl \
    && rm -rf /var/cache/apk/* /tmp/*
#
COPY root/ /
#
VOLUME /home/${S6_USER:-alpine}/ /home/${S6_USER:-alpine}/Downloads/
#
# WORKDIR /home/${S6_USER:-alpine}/
#
ENTRYPOINT ["/usershell"]
CMD ["/usr/bin/firefox"]

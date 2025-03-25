FROM alpine

LABEL maintainer="Naveen S R <srnaveen2k@yahoo.com>"

ENV DISPLAY :52
ENV RESOLUTION 1920x1080x24 

RUN apk add bash i3wm xvfb xdpyinfo lightdm-gtk-greeter x11vnc chromium xorg-server
RUN echo 'CHROMIUM_FLAGS="--disable-gpu --disable-software-rasterizer --disable-dev-shm-usage --no-first-run --no-default-browser-check --no-sandbox --test-type=browser"' >> /etc/chromium/chromium.conf && \
    dbus-uuidgen > /var/lib/dbus/machine-id

RUN adduser -h /home/user -s /bin/bash -S -D user && passwd -d user
USER user
WORKDIR /home/user
RUN mkdir -p /home/user/.vnc

ENV CHROMIUM_ARGS ""
RUN mkdir -p /home/user/.config/i3 &&\
    echo "default_border none" > /home/user/.config/i3/config &&\
    echo "exec_always --no-startup-id chromium $CHROMIUM_ARGS" >> /home/user/.config/i3/config

RUN echo '#!/bin/sh' > /home/user/startVNC.sh && \
    echo 'rm -f /tmp/.X${DISPLAY#:}-lock' >> /home/user/startVNC.sh && \
    echo '/usr/bin/Xvfb $DISPLAY -screen 0 $RESOLUTION -ac +extension GLX +render -noreset &' >> /home/user/startVNC.sh && \
    echo 'while [[ ! $(xdpyinfo -display $DISPLAY 2> /dev/null) ]]; do sleep .3; done' >> /home/user/startVNC.sh && \
    echo 'sed -i "s>--no-startup-id chromium .*>--no-startup-id chromium $*>" /home/user/.config/i3/config' >> /home/user/startVNC.sh &&\
    echo 'i3 -V &' >> /home/user/startVNC.sh && \
    echo 'while true; do x11vnc -xkb -noxrecord -noxfixes -noxdamage -display $DISPLAY -rfbport 5900 || exit 1; done' >> /home/user/startVNC.sh && \
    chmod +x /home/user/startVNC.sh

ENTRYPOINT ["/home/user/startVNC.sh"]
EXPOSE 5900

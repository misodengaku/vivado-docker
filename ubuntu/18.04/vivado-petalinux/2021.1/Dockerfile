### Base Image ###
FROM ubuntu:18.04 AS Base
ENV VIVADO_VERSION=2021.1

RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get -y upgrade && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y build-essential default-jre xorg xvfb libxrender-dev libxtst-dev vnc4server \
                                                      twm vim sudo git unzip wget libgtk2.0-0 binutils ncurses-dev u-boot-tools file \
                                                      tofrodos iproute2 gawk net-tools libncurses5-dev tftp tftpd-hpa zlib1g-dev \
                                                      libssl-dev flex bison libselinux1 diffstat xvfb chrpath xterm libtool socat \
                                                      autoconf texinfo gcc-multilib libsdl1.2-dev libglib2.0-dev zlib1g:i386 wget \
                                                      libtool-bin locales cpio python3 libgtk2.0-0 libgmp-dev rlwrap rsync && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

RUN mkdir -p /opt
RUN mkdir ~/.vnc \
    && echo "29g8/XJ6FFg=" | base64 -d > ~/.vnc/passwd && chmod 600 ~/.vnc/passwd
RUN useradd -ms /bin/bash vivado


### Installing ###
FROM Base AS Install
COPY files/install_config.txt.template /opt/install_config.txt.template
ADD files/Xilinx_Unified_2021.1_0610_2318.tar.gz /opt/
COPY files/vivado_install_config.txt /opt/vivado_install_config.txt
COPY files/petalinux_install_config.txt /opt/petalinux_install_config.txt

# install Vitis/Vivado and PetaLinux
RUN chmod +x /opt/Xilinx_Unified_*/xsetup && \
    cat /opt/vivado_install_config.txt && \
    /opt/Xilinx_Unified_*/xsetup --agree XilinxEULA,3rdPartyEULA,WebTalkTerms --product Vitis --batch Install --config /opt/vivado_install_config.txt && \
    /opt/Xilinx_Unified_*/xsetup --agree XilinxEULA,3rdPartyEULA,WebTalkTerms --batch Install --config /opt/petalinux_install_config.txt && \
    rm -rf /opt/Xilinx_Unified_*/

# Install board_files of Avnet and Digilent
RUN wget https://github.com/Avnet/bdf/archive/master.zip -O avnet.zip && \
    wget https://github.com/Digilent/vivado-boards/archive/master.zip -O digilent.zip && \
    unzip "*.zip" && \
    mkdir -p /opt/Xilinx/Vivado/2021.1/data/boards/board_files/ && \
    cp -r bdf-master/* /opt/Xilinx/Vivado/2021.1/data/boards/board_files/ && \
    cp -r vivado-boards-master/new/* /opt/Xilinx/Vivado/2021.1/data/boards/board_files/

# Modify environments
RUN mkdir -p /home/vivado/.vnc && \
    mkdir /tmp/.X11-unix && \
    chmod 1777 /tmp/.X11-unix && \
    chown root /tmp/.X11-unix/
# COPY files/xstartup /home/vivado/.vnc/xstartup
RUN chown -R vivado. /home/vivado && \
    chmod 777 /opt/ && \
    mkdir /opt/petalinux && \
    chown vivado. /opt/petalinux && \
    rm -rf /opt/Xilinx/.xinstall && \
    echo 'vivado ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers

USER vivado
WORKDIR /home/vivado

RUN echo "CURDIR=\`pwd\`" >> /home/vivado/.bashrc && \
    echo "cd /opt/petalinux/" >> /home/vivado/.bashrc && \
    echo "source /opt/petalinux/settings.sh" >> /home/vivado/.bashrc && \
    echo "cd \$CURDIR" >> /home/vivado/.bashrc && \
    echo "29g8/XJ6FFg=" | base64 -d > /home/vivado/passwd && chmod 600 /home/vivado/passwd && \
    echo "source /opt/Xilinx/Vivado/2021.1/settings64.sh" >> /home/vivado/.bashrc && \
    echo "source /opt/Xilinx/Vitis/2021.1/settings64.sh" >> /home/vivado/.bashrc

USER root
RUN echo "CURDIR=\`pwd\`" >> /root/.bashrc && \
    echo "cd /opt/petalinux/" >> /root/.bashrc && \
    echo "source /opt/petalinux/settings.sh" >> /root/.bashrc && \
    echo "cd \$CURDIR" >> /root/.bashrc && \
    echo "source /opt/Xilinx/Vivado/2021.1/settings64.sh" >> /root/.bashrc && \
    echo "source /opt/Xilinx/Vitis/2021.1/settings64.sh" >> /root/.bashrc


### Last Image ###
FROM Base
USER root
COPY --from=Install /root /root
COPY --from=Install /etc/sudoers /etc/sudoers

USER vivado
WORKDIR /home/vivado

COPY --from=Install /opt/petalinux /opt/petalinux
COPY --from=Install /opt/Xilinx /opt/Xilinx
COPY --from=Install /home/vivado /home/vivado
COPY --from=Install /tmp/.X11-unix /tmp/.X11-unix

COPY files/entrypoint.sh /opt/entrypoint.sh
COPY files/cmd.sh /opt/cmd.sh

ENV DISPLAY :0
ENV GEOMETRY 1920x1200
EXPOSE 5900

USER root
ENTRYPOINT [ "sh", "/opt/entrypoint.sh" ]
CMD ["/opt/cmd.sh"]

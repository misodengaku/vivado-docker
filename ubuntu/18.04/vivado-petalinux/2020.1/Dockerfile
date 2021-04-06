### Modify Installer ###
FROM ubuntu:18.04 AS Modifier
ADD files/petalinux-v2020.1-final-installer.run /opt
RUN echo '#' | dd conv=notrunc of=/opt/petalinux-v2020.1-final-installer.run bs=1 seek=`\grep -aob "accept_license" /opt/petalinux-v2020.1-final-installer.run | tail -n 1 | \grep -oE '^[0-9]+'` count=1
RUN chmod +x /opt/petalinux-v2020.1-final-installer.run


### Base Image ###
FROM ubuntu:18.04 AS Base
ENV VIVADO_VERSION=2020.1

RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get -y upgrade && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y build-essential default-jre xorg xvfb libxrender-dev libxtst-dev vnc4server \
                                                      twm vim sudo git unzip wget libgtk2.0-0 binutils ncurses-dev u-boot-tools file \
                                                      tofrodos iproute2 gawk net-tools libncurses5-dev tftp tftpd-hpa zlib1g-dev \
                                                      libssl-dev flex bison libselinux1 diffstat xvfb chrpath xterm libtool socat \
                                                      autoconf texinfo gcc-multilib libsdl1.2-dev libglib2.0-dev zlib1g:i386 wget \
                                                      libtool-bin locales cpio python3 libgtk2.0-0 rlwrap rsync && \
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
ADD files/Xilinx_Unified_2020.1_0602_1208.tar.gz /opt/
ARG VIVADO_EDITION="Vitis Unified Software Platform"
ARG VIVADO_MODULES="Vitis:1,Vivado:1,Zynq-7000:1,Zynq UltraScale+ MPSoC:1,Zynq UltraScale+ RFSoC:1,Artix-7:1,Kintex-7:1,Spartan-7:1,Virtex-7:1,Kintex UltraScale:1,Virtex UltraScale:1,Kintex UltraScale+:1,Virtex UltraScale+:1,Model Composer:0,DocNav:0"

# install Vivado 2020.1
RUN chmod +x /opt/Xilinx_Unified_*/xsetup && \
    vncserver :0 && \
    cat /opt/install_config.txt.template | \
    sed -e "s/%%EDITION%%/${VIVADO_EDITION}/" -e "s/%%MODULES%%/${VIVADO_MODULES}/" > /opt/install_config.txt && \
    cat /opt/install_config.txt && \
    /opt/Xilinx_Unified_*/xsetup --agree XilinxEULA,3rdPartyEULA,WebTalkTerms --product Vitis --batch Install --config /opt/install_config.txt && \
    rm -rf /opt/Xilinx_Unified_*/ && \
    rm -rf /tmp/.X*

# Install board_files of Avnet and Digilent
RUN wget https://github.com/Avnet/bdf/archive/master.zip -O avnet.zip && \
    wget https://github.com/Digilent/vivado-boards/archive/master.zip -O digilent.zip && \
    unzip "*.zip" && \
    cp -r bdf-master/* /opt/Xilinx/Vivado/2020.1/data/boards/board_files/ && \
    cp -r vivado-boards-master/new/* /opt/Xilinx/Vivado/2020.1/data/boards/board_files/ && \
    cp -r bdf-master/* /opt/Xilinx/Vitis/2020.1/data/boards/board_files/ && \
    cp -r vivado-boards-master/new/* /opt/Xilinx/Vitis/2020.1/data/boards/board_files/

# Modify environments
RUN mkdir -p /home/vivado/.vnc && \
    mkdir /tmp/.X11-unix && \
    chmod 1777 /tmp/.X11-unix && \
    chown root /tmp/.X11-unix/
COPY files/xstartup /home/vivado/.vnc/xstartup
RUN chown -R vivado. /home/vivado

# Install petalinux
COPY --from=Modifier /opt/petalinux-v2020.1-final-installer.run /opt/petalinux-v2020.1-final-installer.run
RUN chmod 777 /opt/ && \
    mkdir /opt/petalinux && \
    chown vivado. /opt/petalinux && \
    rm -rf /opt/Xilinx/.xinstall && \
    echo 'vivado ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers

USER vivado
WORKDIR /home/vivado

# execute petalinux installer - cannot install as root user
RUN /opt/petalinux-v2020.1-final-installer.run -d /opt/petalinux/ && rm /opt/petalinux-v2020.1-final-installer.run

RUN echo "CURDIR=\`pwd\`" >> /home/vivado/.bashrc && \
    echo "cd /opt/petalinux/" >> /home/vivado/.bashrc && \
    echo "source /opt/petalinux/settings.sh" >> /home/vivado/.bashrc && \
    echo "cd \$CURDIR" >> /home/vivado/.bashrc && \
    echo "29g8/XJ6FFg=" | base64 -d > /home/vivado/passwd && chmod 600 /home/vivado/passwd && \
    echo "source /opt/Xilinx/Vivado/${VIVADO_VERSION}/settings64.sh" >> /home/vivado/.bashrc && \
    echo "source /opt/Xilinx/Vitis/${VIVADO_VERSION}/settings64.sh" >> /home/vivado/.bashrc

USER root
RUN echo "CURDIR=\`pwd\`" >> /root/.bashrc && \
    echo "cd /opt/petalinux/" >> /root/.bashrc && \
    echo "source /opt/petalinux/settings.sh" >> /root/.bashrc && \
    echo "cd \$CURDIR" >> /root/.bashrc && \
    echo "source /opt/Xilinx/Vivado/${VIVADO_VERSION}/settings64.sh" >> /root/.bashrc && \
    echo "source /opt/Xilinx/Vitis/${VIVADO_VERSION}/settings64.sh" >> /root/.bashrc


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

ENV DISPLAY :0
ENV GEOMETRY 1920x1200
EXPOSE 5900

CMD ["sh", "/opt/entrypoint.sh"]

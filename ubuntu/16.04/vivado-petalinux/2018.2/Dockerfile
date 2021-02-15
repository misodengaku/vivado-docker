FROM ubuntu:16.04

COPY files/install_config.txt.template /opt/install_config.txt.template
COPY files/entrypoint.sh /opt/entrypoint.sh

ENV VIVADO_VERSION=2018.2

RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get -y upgrade && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y build-essential default-jre xorg xvfb libxrender-dev libxtst-dev vnc4server \
                                                      twm vim sudo git unzip wget libgtk2.0-0 binutils ncurses-dev u-boot-tools file \
                                                      tofrodos iproute2 gawk net-tools libncurses5-dev tftp tftpd-hpa zlib1g-dev \
                                                      libssl-dev flex bison libselinux1 diffstat xvfb chrpath xterm libtool socat \
                                                      autoconf texinfo gcc-multilib libsdl1.2-dev libglib2.0-dev zlib1g:i386 wget \
                                                      libtool-bin locales cpio python3 libgtk2.0-0 rlwrap && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

RUN mkdir -p /opt
ADD files/Xilinx_Vivado_SDK_2018.2_0614_1954.tar.gz /opt/


ARG VIVADO_EDITION="Vivado HL Design Edition"
ARG VIVADO_MODULES="Vivado:1,SDK Core Tools:1,Compiler Tool Chains:1,MicroBlaze:1,ARM Cortex-A9:1,ARM Cortex-A53:1,ARM Cortex R5:1,Zynq-7000:1,Zynq UltraScale+ MPSoC:1,Zynq UltraScale+ RFSoC:1,Artix-7:1,Kintex-7:1,Spartan-7:1,Virtex-7:1,Kintex UltraScale:1,Virtex UltraScale:1,Kintex UltraScale+:1,Virtex UltraScale+:1,Model Composer:0,DocNav:0"

RUN mkdir ~/.vnc \
    && echo "29g8/XJ6FFg=" | base64 -d > ~/.vnc/passwd && chmod 600 ~/.vnc/passwd

# install Vivado 2018.2
RUN chmod +x /opt/Xilinx_Vivado_*/xsetup && \
    vncserver :0 && \
    cat /opt/install_config.txt.template | \
    sed -e "s/%%EDITION%%/${VIVADO_EDITION}/" -e "s/%%MODULES%%/${VIVADO_MODULES}/" > /opt/install_config.txt && \
    cat /opt/install_config.txt && \
    /opt/Xilinx_Vivado_*/xsetup --agree XilinxEULA,3rdPartyEULA,WebTalkTerms --batch Install --config /opt/install_config.txt && \
    rm -rf /opt/Xilinx_Vivado_*/ && \
    rm -rf /tmp/.X*


# Apply Vivado 2018.2.1 update
ADD files/Xilinx_Vivado_SDx_Update_2018.2.1_0726_1815.tar.gz /opt/
RUN cat /opt/install_config.txt.template | \
    sed -e "s/%%EDITION%%/${VIVADO_EDITION}/" -e "s/Modules=%%MODULES%%//" > /opt/update_config.txt && \
    /opt/Xilinx_Vivado_*/xsetup --agree XilinxEULA,3rdPartyEULA,WebTalkTerms --batch Install --config /opt/update_config.txt && \
    rm -rf /opt/Xilinx_Vivado_*/ && \
    rm -rf /tmp/.X*

RUN wget https://github.com/Avnet/bdf/archive/master.zip -O avnet.zip && \
    wget https://github.com/Digilent/vivado-boards/archive/master.zip -O digilent.zip && \
    unzip "*.zip" && \
    cp -r bdf-master/* /opt/Xilinx/Vivado/2018.2/data/boards/board_files/ && \
    cp -r vivado-boards-master/new/* /opt/Xilinx/Vivado/2018.2/data/boards/board_files/ && \
    cp -r /opt/Xilinx/Vivado/2018.2/data/boards/board_files/* /opt/Xilinx/SDK/2018.2/data/boards/board_files/

RUN useradd -ms /bin/bash vivado && \
    mkdir -p /home/vivado/.vnc && \
    mkdir /tmp/.X11-unix && \
    chmod 1777 /tmp/.X11-unix && \
    chown root /tmp/.X11-unix/ && \
    echo 'vivado ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers && \
    echo "29g8/XJ6FFg=" | base64 -d > /home/vivado/passwd && chmod 600 /home/vivado/passwd && \
    echo "source /opt/Xilinx/Vivado/${VIVADO_VERSION}/settings64.sh" >> /home/vivado/.bashrc && \
    echo "source /opt/Xilinx/SDK/${VIVADO_VERSION}/settings64.sh" >> /home/vivado/.bashrc

COPY files/xstartup /home/vivado/.vnc/xstartup

RUN chown -R vivado. /home/vivado

# install petalinux
ADD files/petalinux-v2018.2-final-installer.run /opt


RUN echo '#' | dd conv=notrunc of=/opt/petalinux-v2018.2-final-installer.run bs=1 seek=`grep -aob "accept_license" /opt/petalinux-v2018.2-final-installer.run --color=never | tail -n 1 | \grep -oE '^[0-9]+'` count=1

RUN chmod 777 /opt/ && \
    mkdir /opt/petalinux && \
    chown vivado. /opt/petalinux


USER vivado
WORKDIR /home/vivado

# install petalinux - cannot install as root user
RUN /opt/petalinux-v2018.2-final-installer.run /opt/petalinux/ && rm /opt/petalinux-v2018.2-final-installer.run

RUN echo "CURDIR=\`pwd\`" >> /home/vivado/.bashrc && \
    echo "cd /opt/petalinux/" >> /home/vivado/.bashrc && \
    echo "source /opt/petalinux/settings.sh" >> /home/vivado/.bashrc && \
    echo "cd \$CURDIR" >> /home/vivado/.bashrc


ENV DISPLAY :0
ENV GEOMETRY 1920x1200

EXPOSE 5900
#ENTRYPOINT ["/opt/entrypoint.sh"]
CMD ["sh", "/opt/entrypoint.sh"]

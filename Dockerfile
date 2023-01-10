
FROM rust as base


RUN apt-get update \
    # Install common deps
    && apt-get install -y build-essential curl git exuberant-ctags software-properties-common gnupg git fish\
    && apt-get clean



#Install newest neovim
RUN curl -L -o nvim-linux64.deb https://github.com/neovim/neovim/releases/download/stable/nvim-linux64.deb
RUN curl -L -o nvim-linux64.deb.sum https://github.com/neovim/neovim/releases/download/stable/nvim-linux64.deb.sha256sum
##check shasum
RUN sha256sum -c nvim-linux64.deb.sum 
RUN apt install ./nvim-linux64.deb
RUN rm ./nvim-linux64.deb
RUN rm ./nvim-linux64.deb.sum


#COPY CONFIG FILES
COPY requirements.txt requirements.txt

##install lvim dependencies
RUN apt-get install python3 python3-dev python3-pip -y
RUN python3 -m pip install -r requirements.txt

##install lvim
ENV PATH=$PATH:/root/.local/bin
ENV LV_BRANCH='release-1.2/neovim-0.8'
RUN curl -L -o lvim_installer.sh https://raw.githubusercontent.com/lunarvim/lunarvim/master/utils/installer/install.sh&& chmod +x lvim_installer.sh
RUN ./lvim_installer.sh -y
RUN rm lvim_installer.sh

COPY config.lua /root/.config/lvim
COPY after /root/.config/lvim
COPY ftplugin /root/.config/lvim
COPY lua /root/.config/lvim
COPY spell /root/.config/lvim
COPY .stylua.toml /root/.config/lvim

FROM base as development


#allow rust backtrace
ENV RUST_BACKTRACE=full

#run command
CMD exec /bin/bash -c "trap : TERM INT; sleep infinity & wait"

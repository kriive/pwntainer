FROM ubuntu:noble

ARG PWN_USER=kriive

# Install tools.
RUN dpkg --add-architecture i386 \
  && apt update && DEBIAN_FRONTEND=noninteractive apt install -y \
  autoconf \
  automake \
  bison \
  curl \
  debuginfod \
  elfutils \
  fish \
  flex \
  foot-terminfo \
  g++-aarch64-linux-gnu \
  g++-arm-linux-gnueabihf \
  gcc-aarch64-linux-gnu \
  gcc-arm-linux-gnueabihf \
  gdb \
  gdb-multiarch \
  gdbserver \
  git \
  libc6-arm64-cross \
  libc6-armhf-cross \
  libc6-dbg \
  libc6-dbg-arm64-cross \
  libc6-dbg-armhf-cross \
  libc6-dbg:i386 \
  libstdc++-11-pic-arm64-cross \
  libstdc++-11-pic-armhf-cross \
  libstdc++6-11-dbg-arm64-cross \
  libstdc++6-11-dbg-armhf-cross \
  libtool \
  make \
  python3-venv \
  qemu-kvm \
  qemu-system \
  qemu-user \
  qemu-user-binfmt \
  ruby \
  ruby-dev \
  software-properties-common \
  sudo \
  tmux \
  wget \
  && rm -rf /var/lib/apt/lists/*

RUN userdel ubuntu
RUN useradd --uid 1000 -m -s /usr/bin/fish -G sudo ${PWN_USER}

# Passwordless sudo for user.
RUN echo "${PWN_USER} ALL = (ALL) NOPASSWD: ALL" >> /etc/sudoers.d/99-${PWN_USER}

# Install helix editor.
RUN add-apt-repository --yes ppa:maveonair/helix-editor && apt update && apt install -y helix

RUN gem install seccomp-tools && \
    gem install one_gadget

USER ${PWN_USER}

RUN mkdir -p /home/${PWN_USER}/ctfs/tools

WORKDIR /home/${PWN_USER}/ctfs/tools

RUN python3 -m venv pwn && \
  . ./pwn/bin/activate && \
  pip install pwntools z3-solver

RUN git clone https://github.com/pwndbg/pwndbg.git /home/${PWN_USER}/ctfs/tools/pwndbg

WORKDIR /home/${PWN_USER}/ctfs/tools/pwndbg

RUN ./setup.sh

RUN fish -c "curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher"
RUN fish -c "fisher install IlanCosman/tide@v6"
RUN fish -c "tide configure --auto --style=Lean --prompt_colors='True color' --show_time=No --lean_prompt_height='Two lines' --prompt_connection=Disconnected --prompt_spacing=Sparse --icons='Few icons' --transient=No"

RUN mkdir -p /home/${PWN_USER}/.config/fish/conf.d && echo "source /home/${PWN_USER}/ctfs/tools/pwn/bin/activate.fish" >> /home/${PWN_USER}/.config/fish/conf.d/10-pwntools.fish


COPY ./tmux.conf /home/${PWN_USER}/.config/tmux/tmux.conf
COPY ./config.toml /home/${PWN_USER}/.config/helix/config.toml
WORKDIR /home/${PWN_USER}

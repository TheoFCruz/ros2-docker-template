# Usa imagem base oficial com ROS Jazzy completo (inclui RViz, rqt, etc.)
FROM osrf/ros:jazzy-desktop

SHELL ["/bin/bash", "-c"]

# Instala ferramentas úteis para desenvolvimento
RUN apt-get update && apt-get install -y \
    git \
    python3-pip \
    build-essential \
    && rm -rf /var/lib/apt/lists/*
    
# Instala dependências e Neovim via PPA
RUN apt-get update && apt-get install -y \
    software-properties-common \
    curl wget git unzip ca-certificates python3-venv \
    && add-apt-repository ppa:neovim-ppa/unstable -y \
    && apt-get install -y neovim \
    && rm -rf /var/lib/apt/lists/*

# Instala a versão mais recente do node (necessário pro LSP):
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs

# Configura o colcon mixin
RUN colcon mixin add default https://raw.githubusercontent.com/colcon/colcon-mixin-repository/master/index.yaml &&\
    colcon mixin update default

# Instala o Gazebo Harmonic
RUN curl https://packages.osrfoundation.org/gazebo.gpg --output /usr/share/keyrings/pkgs-osrf-archive-keyring.gpg &&\
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/pkgs-osrf-archive-keyring.gpg] http://packages.osrfoundation.org/gazebo/ubuntu-stable $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/gazebo-stable.list > /dev/null &&\
    apt-get update &&\
    apt-get install gz-harmonic

# Renomeia o usuário e o grupo de 'ubuntu' para 'jazzy'
RUN usermod -l jazzy ubuntu && \
    groupmod -n jazzy ubuntu && \
    usermod -d /home/jazzy -m jazzy && \
    usermod --password $(echo 123456 | openssl passwd -1 -stdin) jazzy
USER jazzy

# Adiciona o setup do ROS ao bashrc
RUN echo "source /ros_entrypoint.sh" >> ~/.bashrc && \
    echo "set +e" >> ~/.bashrc

# Define o diretório de trabalho padrão
WORKDIR /home/jazzy/ros2_ws


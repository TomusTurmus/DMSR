# Build args:
#  BASE_IMAGE - CUDA-enabled base image (default targets CUDA 11.1 + Ubuntu 20.04)
#  PYTHON_VERSION - Python version to install into the conda env
#  CONDA_ENV - name of the conda environment
ARG BASE_IMAGE=nvidia/cuda:11.1.1-cudnn8-devel-ubuntu20.04
ARG PYTHON_VERSION=3.6
ARG CONDA_ENV=dmsr

FROM ${BASE_IMAGE}

ARG PYTHON_VERSION
ARG CONDA_ENV

ENV CONDA_ENV=${CONDA_ENV}
ENV PYTHON_VERSION=${PYTHON_VERSION}
ENV DEBIAN_FRONTEND=noninteractive
ENV CUDA_HOME=/usr/local/cuda
ENV TORCH_CUDA_ARCH_LIST=6.0;6.1;7.0;7.5;8.0;8.6+PTX

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates wget git curl build-essential cmake ninja-build pkg-config \
    libglib2.0-0 libsm6 libxext6 libxrender1 libgl1-mesa-glx \
    ffmpeg unzip sudo && \
    rm -rf /var/lib/apt/lists/*

ENV CONDA_DIR=/opt/conda
RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /tmp/miniconda.sh && \
    bash /tmp/miniconda.sh -b -p ${CONDA_DIR} && \
    rm /tmp/miniconda.sh && \
    ${CONDA_DIR}/bin/conda clean -ya

ENV PATH=${CONDA_DIR}/bin:${PATH}

RUN ${CONDA_DIR}/bin/conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main && \
    ${CONDA_DIR}/bin/conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r

RUN ${CONDA_DIR}/bin/conda create -y -n ${CONDA_ENV} python=${PYTHON_VERSION} && \
    ${CONDA_DIR}/bin/conda clean -ya

SHELL ["/bin/bash", "-lc"]

RUN ${CONDA_DIR}/bin/conda run -n ${CONDA_ENV} pip install --upgrade pip==21.3.1 setuptools wheel && \
    ${CONDA_DIR}/bin/conda run -n ${CONDA_ENV} pip install numpy scipy pyyaml matplotlib scikit-image cython

COPY requirements.txt /tmp/requirements.txt
RUN ${CONDA_DIR}/bin/conda run -n ${CONDA_ENV} pip install -r /tmp/requirements.txt

# PyTorch 1.8.0 + torchvision 0.9.0 for CUDA 11.1
RUN ${CONDA_DIR}/bin/conda run -n ${CONDA_ENV} pip install \
    torch==1.8.0+cu111 torchvision==0.9.0+cu111 \
    --extra-index-url https://download.pytorch.org/whl/cu111

WORKDIR /workspace
COPY . /workspace

# Build local extensions if the DMSR source tree is present in the build context.
RUN if [ -f pointnet2/pointnet2/setup.py ]; then \
    ${CONDA_DIR}/bin/conda run -n ${CONDA_ENV} bash -lc 'cd /workspace/pointnet2/pointnet2 && python setup.py install'; \
    fi

RUN if [ -f lib/nn_distance/setup.py ]; then \
    ${CONDA_DIR}/bin/conda run -n ${CONDA_ENV} bash -lc 'cd /workspace/lib/nn_distance && python setup.py install'; \
    fi

ENV PATH="${CONDA_DIR}/envs/${CONDA_ENV}/bin:${PATH}"

COPY docker/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

CMD ["/bin/bash"]
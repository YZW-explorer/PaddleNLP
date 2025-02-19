#!/usr/bin/env bash

# Copyright (c) 2024 PaddlePaddle Authors. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

export paddle=$1
export nlp_dir=/workspace/PaddleNLP
cd $nlp_dir

if [ ! -d "unittest_logs" ];then
    mkdir unittest_logs
fi

install_requirements() {
    python -m pip install -r requirements.txt
    python -m pip install -r requirements-dev.txt
    python -m pip install -r paddlenlp/experimental/autonlp/requirements.txt 
    python -m pip uninstall paddlepaddle -y
    python -m pip install --no-cache-dir ${paddle}
    python -m pip install sacremoses
    python -m pip install parameterized
    python -m pip install loguru==0.6.0
    python -m pip install h5py
    python -m pip install paddleslim

    python setup.py bdist_wheel
    python -m pip install  dist/p****.whl
    cd csrc/
    python setup_cuda.py install
    cd ../

    pip list 
}

set_env() {
    export NVIDIA_TF32_OVERRIDE=0 
    export FLAGS_cudnn_deterministic=1
    export HF_ENDPOINT=https://hf-mirror.com
}

install_requirements
set_env
pytest -v -n 8 --durations 20 --cov paddlenlp --cov-report xml:coverage.xml
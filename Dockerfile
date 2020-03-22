FROM ebmdatalab/datalab-jupyter:python3.8.1-2328e31e7391a127fe7184dcce38d581a17b1fa5

# R-related setup
RUN apt-get install -y libcurl4-openssl-dev libssl-dev libnlopt-dev

# Set up jupyter environment
ENV MAIN_PATH=/home/app/notebook

# Install R requirements
COPY setup.R /tmp/
RUN /usr/lib/R/bin/R -f /tmp/setup.R

COPY setup2.R /tmp/
RUN /usr/lib/R/bin/R -f /tmp/setup2.R

EXPOSE 8888


CMD cd ${MAIN_PATH} && PYTHONPATH=${MAIN_PATH} jupyter lab --config=config/jupyter_notebook_config.py

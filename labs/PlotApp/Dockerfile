# pull latest julia image
FROM --platform=linux/amd64 julia:latest

# create dedicated user
RUN useradd --create-home --shell /bin/bash genie

# set up the app
RUN mkdir /home/genie/app
COPY . /home/genie/app
WORKDIR /home/genie/app

# configure permissions
RUN chown genie:genie -R *

# RUN chmod a+x lib
RUN chmod -R 777 /home/genie/app
# RUN chmod +x /home/genie/app/lib/Data_Upload

# switch user
USER genie

# instantiate Julia packages
RUN julia -e "ENV[\"JULIA_PKG_SERVER\"]=\"https://mirrors.bfsu.edu.cn/julia/static/\";using Pkg; Pkg.activate(\".\"); Pkg.instantiate(); Pkg.precompile(); "

# ports
EXPOSE 8000

# run app
CMD julia -e "isDeploy = true;include(\"run.jl\");" 


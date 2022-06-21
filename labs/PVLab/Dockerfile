# pull latest julia image
FROM --platform=linux/amd64 julia:latest

# set up the app
RUN mkdir /home/app
COPY . /home/app
WORKDIR /home/app

# instantiate Julia packages
RUN julia -e "ENV[\"JULIA_PKG_SERVER\"]=\"https://mirrors.tuna.tsinghua.edu.cn/julia/\";using Pkg; Pkg.activate(\".\"); Pkg.instantiate(); Pkg.precompile(); "

# ports
EXPOSE 8000

# run app
CMD julia -e "using Pkg; Pkg.activate(\".\"); Pkg.instantiate();isDeploy = true; include(\"run.jl\");" 


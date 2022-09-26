using Genie
using Genie.Router
using Genie.Renderers.Json
using Ai4ELab.CoolPropsController

route("/") do
  "Welcome to Ai4ELab"
end

route("/hello") do
  "Welcome to Ai4ELab"
end
route("/coolprop", CoolPropsController.test)

route("/api/hello") do
  "Welcome,to Ai4ELab"
end


route("/addxy") do
x=parse(Float64, query(:x, "10"))
y=parse(Float64, query(:y, "20"))
Ai4ELab.CoolPropsController.addxy(x,y) # 直接返回函数值
#json(Ai4ELab.CoolPropsController.addxy(x,y)) #返回一个json
(:answer => Ai4ELab.CoolPropsController.addxy(x,y)) |> json #返回一个json

end

route("/api/addxy") do
  x=parse(Float64, query(:x, "10"))
  y=parse(Float64, query(:y, "20"))
  Ai4ELab.CoolPropsController.addxy(x,y) # 直接返回函数值
  #json(Ai4ELab.CoolPropsController.addxy(x,y)) #返回一个json
 #(:answer => Ai4ELab.CoolPropsController.addxy(x,y)) |> json #返回一个json
  
  end
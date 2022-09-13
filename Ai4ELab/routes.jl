using Genie.Router
using Ai4ELab.CoolPropsController

route("/") do
  "Welcome to Ai4ELab"
end

route("/hello") do
  "Welcome to Ai4ELab"
end
route("/coolprop", CoolPropsController.test)
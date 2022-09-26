(pwd() != @__DIR__) && cd(@__DIR__) # allow starting app from bin/ dir

using Ai4ELab
const UserApp = Ai4ELab
Ai4ELab.main()

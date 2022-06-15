module MyApp
    
include("Page.jl")

htmlfile = MyPage |> init |> ui |> html

end


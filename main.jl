
using Agents
# using PlutoUI
# using PlutoLinks: @ingredients
using InteractiveDynamics
using GLMakie

include("./model/model.jl")
include("./visualize.jl")

function healthy_food(model)
	count(model.food .> 0.01)
end
function IsSpecies(s)
	function Is(agent)
		agent.species == s
	end
end
# model, agent_step!, model_step! = Model.init_model(params)

model, agent_step!, model_step! = let
    params = Model.ModelParams(
		grid_size=(50, 50),
		num_init_tiger=50,
		num_init_boar=200
	)
    Model.init_model(params)
end
adata = [
    (IsSpecies(:tiger), count),
    (IsSpecies(:boar), count),
    (IsSpecies(:leopard), count)
]

steps=300
# abmvideo("./test_v1.mp4", model, agent_step! , model_step!; spf = 1, framerate = 30,frames = steps ,
#         heatkwargs = (colormap = [:brown, :green], colorrange = (0, 1)))
videopath="./test_v1.mp4"
abmvideo(videopath,
model,
agent_step!,
model_step!;#
frames=steps,
framerate=5,
ac=AgentColor(model),
am=agent_marker,
heatarray=model_heatarray,
# heatkwargs=(nan_color=(1.0, 1.0, 0.0, 0.5),
# 			colormap=[(0, 1.0, 0, i) for i in 0:0.01:1],
# 			colorrange=(0, 1))
			)

# adata, mdata = run!(model, agent_step!, model_step!, steps; adata=adata, mdata=[healthy_food])

# print(adata)


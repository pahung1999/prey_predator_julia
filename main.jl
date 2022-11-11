
using Agents
# using PlutoUI
# using PlutoLinks: @ingredients
using InteractiveDynamics
using GLMakie


include("./model.jl")

params = Model.ModelParams(
		grid_size=(50, 50),
		num_init_tiger=50,
		num_init_boar=200
	)

model, agent_step!, model_step! = Model.init_model(params)

# abmvideo("./test_v1.mp4", model, agent_step! , model_step!; spf = 1, framerate = 30,frames = 500 ,
#         heatkwargs = (colormap = [:brown, :green], colorrange = (0, 1)))

function healthy_food(model)
	count(model.food .> 0.01)
end
function IsSpecies(s)
	function Is(agent)
		agent.species == s
	end
end
adata = [
    (IsSpecies(:tiger), count),
    (IsSpecies(:boar), count),
    (IsSpecies(:leopard), count)
]
adata, mdata = run!(model, agent_step!, model_step!, 100; adata=adata, mdata=[healthy_food])

print(adata)
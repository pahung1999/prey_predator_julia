
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

abmvideo("./test_v1.mp4", model, agent_step! , model_step!; spf = 1, framerate = 30,frames = 200)
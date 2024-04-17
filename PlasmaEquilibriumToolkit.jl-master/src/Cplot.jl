module CPlot


    using CairoMakie
    function data()
        # Generate some data
        x = rand(10)
        y = rand(10)

        # Create a scatter plot
        fig = Figure()
        ax = Axis(fig[1, 1])
        scatter!(ax, x, y)

        # Save the plot as a PNG image
        CairoMakie.save("scatter_plot.png", fig)
    end

end
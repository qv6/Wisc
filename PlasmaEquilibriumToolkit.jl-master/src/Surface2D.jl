
function coordinate_grid_2D(s, θ_range, ζ_range, eq::Vmec{T}) where {T}
    ψ = s * eq.phi(1.0) / (2π * eq.signgs)
    vmec_coords = Matrix{VmecCoordinates{T, T}}(undef, length(ζ_range), length(θ_range))
    vmec_surface = VmecSurface(s, eq)
    for i in eachindex(ζ_range), j in eachindex(θ_range)
        flux_coord = FluxCoordinates(ψ, θ_range[j], ζ_range[i])
        vmec_coords[j, i] = VmecFromFlux()(flux_coord, vmec_surface)
    end
    return vmec_coords
end

"""
    bmag_2D_line_contour(eq::Vmec,fluxCoords::StructArray{FluxCoordinates};levels = 20,clearFigure = true)

Plots the contour lines of |B| on a flux surface in 2D (in θ and ζ)
# Example
```julia-repl
julia> using NetCDF, PlasmaEquilibriumToolkit, VMEC
julia> wout = NetCDF.open("/path/to/your/vmec/file.nc") #change to your personal path
julia> vmec, vmecdata = VMEC.readVmecWout(wout);
julia> angles = LinRange(0,2π,500);
julia> ψ = -0.5;
julia> fluxCoords = MagneticCoordinateGrid(FluxCoordinates, ψ, angles, angles);
julia> bmag_2D_line_contour(vmec, fluxCoords)
```
**If you want to plot multiple functions next to each other in the same figure
set clearFigure = false**
"""
function bmag_2D_line_contour(eq::Vmec{T},
                              s,
                              theta_range,
                              zeta_range;
                              levels = 20,
                              clearFigure = true
                             ) where {T}
  #ψ = s * eq.phi(1.0) / (2π * eq.signgs)
  #fluxCoords = MagneticCoordinateGrid(FluxCoordinates, ψ, theta_range, zeta_range)
  #vmecSurface = VmecSurface(s, eq);
  #vmecCoords = VmecFromFlux()(fluxCoords, vmecSurface);
  vmecCoords = coordinate_grid_2D(s, theta_range, zeta_range, eq)
  Bmag = [VMEC.inverseTransform(v, vmecSurface.bmn) for v in vmecCoords];
  rowPosition, colPosition = (1,1)
  if clearFigure || typeof(current_axis(current_figure())) == Nothing
      fig = Figure()
  else
      fig = current_figure()
      rowPosition, colPosition = indexing(fig)
  end
  axis = Axis(fig[rowPosition,colPosition],xlabel="ζ",ylabel="θ",title="|B| Contours")
  cont = contourf!(axis, ζs, θs, Bmag , colormap= :vik, levels = levels)
  legend = Colorbar(fig[rowPosition, colPosition + 1], cont, label = "|B|",tellheight=false);
  fig
  savefig(fig, "FinalPlot.png")
end

function surface_contours_boozer(eq::VmecSurface{T},
                                 field::Symbol=:bmn,
                                 mBoozer::Int=64,
                                 nBoozer::Int=64;
                                 titleStr::String="|B| Contours",
                                 labelStr::String="|B|",
                                 levels = 20,
                                 clearFigure = true,
                                ) where {T}
  # Currently do this twice because the boozerCosineSpectrum function
  # doesn't return the Boozer coordinate grid
  wmn, boozerG, boozerI = VMEC.boozerWFunction(eq)
  fluxGrid, boozerGrid, _ = VMEC.boozerGrid(eq,mBoozer,nBoozer,wmn,boozerG,boozerI)
  χ = boozerGrid.χ
  ϕ = boozerGrid.ϕ
  vmecGrid = VmecFromFlux()(fluxGrid,eq)
  data = inverseTransform(vmecGrid,getfield(eq,field))
  for row in 1:size(data,1)
    data_row = view(data,row,:)
    χ_row = view(χ,row,:)
    ϕ_row = view(ϕ,row,:)
    if first(χ_row) < zero(T)
      last_neg = findlast(x->x<zero(T),χ_row)
      if !isnothing(last_neg)
        χ_row[1:last_neg] .+= 2π
        println(row)
        println(χ_row)
        χ_row = circshift(χ_row,-last_neg)
        println(χ_row)
        ϕ_row = circshift(ϕ_row,-last_neg)
        data_row = circshift(data_row,-last_neg)
      end
    else
      first_pos = findfirst(x->x>=2π,χ_row)
      if !isnothing(first_pos)
        χ_row[first_pos:end] .= χ_row[first_pos:end] .% 2π
        χ_row = circshift(χ_row,first_pos)
        ϕ_row = circshift(ϕ_row,first_pos)
        data_row = circshift(data_row,first_pos)
      end
    end
    χ[row,:] = χ_row
    ϕ[row,:] = ϕ_row
    data[row,:] = data_row
  end
  #=
  for col in 1:size(data,2)
    data_col = view(data,col,:)
    χ_col = view(χ,col,:)
    ϕ_col = view(ϕ,col,:)
    if first(ϕ_col) < zero(T)
      last_neg = findlast(x->x<zero(T),ϕ_col)
      if !isnothing(last_neg)
        ϕ_col[1:last_neg] .+= 2π/eq.nfp
        χ_col = circshift(χ_col,-last_neg)
        ϕ_col = circshift(ϕ_col,-last_neg)
        data_col = circshift(data_col,-last_neg)
      end
    else
      first_pos = findfirst(x->x>=2π/eq.nfp,χ_col)
      if !isnothing(first_pos)
        χ_col[first_pos:end] .= χ_col[first_pos:end] .% (2π/eq.nfp)
        χ_col = circshift(χ_col,first_pos)
        ϕ_col = circshift(ϕ_col,first_pos)
        data_col = circshift(data_col,first_pos)
      end
    end
    χ[:,col] = χ_col
    ϕ[:,col] = ϕ_col
    data[:,col] = data_col
  end     
  =#
  χ, ϕ, data
#=
  rowPosition, colPosition = (1,1)
  if clearFigure || typeof(current_axis(current_figure())) == Nothing
      fig = Figure()
  else
      fig = current_figure()
      rowPosition, colPosition = indexing(fig)
  end
  axis = Axis(fig[rowPosition,colPosition],xlabel="χ",ylabel="ϕ",title=titleStr)
  cont = contourf!(axis, boozerGrid.χ[1,:], boozerGrid.ϕ[:,1], data , colormap= :vik, levels = levels)
  legend = Colorbar(fig[rowPosition, colPosition + 1], cont, label = labelStr,tellheight=false);
  fig
  =#
end 

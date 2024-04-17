"""
    readVmecWout(wout::AbstractString)
    readVmecWout(wout::NetCDF.NcFile)

Read in a NetCDF VMEC wout file and populate the associated Vmec and VmecData structs.  Currently
the method compares variables in NetCDF files to property names in the VmecData struct and will
error if a NetCDF variable exists that is not in the VmecData struct.

# See also: [`VmecData`](@ref)
"""
function readVmecWout(wout::NetCDF.NcFile)
  # Obtain the variable names to query in the wout file
  woutVars = wout.vars
  ns = NetCDF.readvar(woutVars["ns"])[]
  mnmax = NetCDF.readvar(woutVars["mnmax"])[]
  mnmax_nyq = NetCDF.readvar(woutVars["mnmax_nyq"])[]
  lasym = convert(Bool,NetCDF.readvar(woutVars["lasym__logical__"])[])
  lfreeb = convert(Bool,NetCDF.readvar(woutVars["lfreeb__logical__"])[])
  floatType = eltype(NetCDF.readvar(woutVars["phi"]))
  vmec = VmecData(ns,mnmax,mnmax_nyq,lasym;FT=floatType,lfreeb=lfreeb)

  for var in woutVars
    varSymbol = Symbol(var.first)
    @debug "var = $(var.first), varSymbol = $varSymbol, $(typeof(varSymbol))"
    if hasproperty(vmec,varSymbol)
      T = typeof(getfield(vmec,varSymbol))
      var_data = NetCDF.readvar(var.second)
      # All of the NetCDF variables are read as arrays
      if T <: Array
        setfield!(vmec,varSymbol,convert.(eltype(T),var_data))
      elseif T <: Number
        setfield!(vmec,varSymbol,convert(T,var_data[1]))
      elseif T <: String
        setfield!(vmec,varSymbol,string(strip(string(var_data...))))
      else
        throw(error("No type given for $(var)!"))
      end
    end
  end

  return Vmec(vmec)
end

function readVmecWout(wout::AbstractString)
    wout_nc = NetCDF.open(wout)
    return readVmecWout(wout_nc)
end

VmecWoutInfoTuple(T,lasym) = NamedTuple{(:datatype,:lasym),Tuple{Type,Bool}}((T,lasym))

VmecWoutInfo = Dict{Symbol,NamedTuple{(:datatype,:lasym),Tuple{Type,Bool}}}()

VmecWoutInfo[:rmnc] = VmecWoutInfoTuple(Array{Float64,2},false)
VmecWoutInfo[:rmns] = VmecWoutInfoTuple(Array{Float64,2},true)
VmecWoutInfo[:zmnc] = VmecWoutInfoTuple(Array{Float64,2},true)
VmecWoutInfo[:zmns] = VmecWoutInfoTuple(Array{Float64,2},false)
VmecWoutInfo[:lmnc] = VmecWoutInfoTuple(Array{Float64,2},true)
VmecWoutInfo[:lmns] = VmecWoutInfoTuple(Array{Float64,2},false)
VmecWoutInfo[:bmnc] = VmecWoutInfoTuple(Array{Float64,2},false)
VmecWoutInfo[:bmns] = VmecWoutInfoTuple(Array{Float64,2},true)
VmecWoutInfo[:gmnc] = VmecWoutInfoTuple(Array{Float64,2},false)
VmecWoutInfo[:gmns] = VmecWoutInfoTuple(Array{Float64,2},true)
VmecWoutInfo[:bsubsmnc] = VmecWoutInfoTuple(Array{Float64,2},true)
VmecWoutInfo[:bsubsmns] = VmecWoutInfoTuple(Array{Float64,2},false)
VmecWoutInfo[:bsubumnc] = VmecWoutInfoTuple(Array{Float64,2},false)
VmecWoutInfo[:bsubumns] = VmecWoutInfoTuple(Array{Float64,2},true)
VmecWoutInfo[:bsubvmnc] = VmecWoutInfoTuple(Array{Float64,2},false)
VmecWoutInfo[:bsubvmns] = VmecWoutInfoTuple(Array{Float64,2},true)
VmecWoutInfo[:bsupumnc] = VmecWoutInfoTuple(Array{Float64,2},false)
VmecWoutInfo[:bsupumns] = VmecWoutInfoTuple(Array{Float64,2},true)
VmecWoutInfo[:bsupvmnc] = VmecWoutInfoTuple(Array{Float64,2},false)
VmecWoutInfo[:bsupvmns] = VmecWoutInfoTuple(Array{Float64,2},true)
VmecWoutInfo[:currumnc] = VmecWoutInfoTuple(Array{Float64,2},false)
VmecWoutInfo[:currumns] = VmecWoutInfoTuple(Array{Float64,2},true)
VmecWoutInfo[:currvmnc] = VmecWoutInfoTuple(Array{Float64,2},false)
VmecWoutInfo[:currvmns] = VmecWoutInfoTuple(Array{Float64,2},true)

VmecWoutInfo[:xm] = VmecWoutInfoTuple(Array{Float64,1},false)
VmecWoutInfo[:xn] = VmecWoutInfoTuple(Array{Float64,1},false)
VmecWoutInfo[:xm_nyq] = VmecWoutInfoTuple(Array{Float64,1},false)
VmecWoutInfo[:xn_nyq] = VmecWoutInfoTuple(Array{Float64,1},false)
VmecWoutInfo[:phi] = VmecWoutInfoTuple(Array{Float64,1},false)
VmecWoutInfo[:phips] = VmecWoutInfoTuple(Array{Float64,1},false)
VmecWoutInfo[:phipf] = VmecWoutInfoTuple(Array{Float64,1},false)
VmecWoutInfo[:chi] = VmecWoutInfoTuple(Array{Float64,1},false)
VmecWoutInfo[:chipf] = VmecWoutInfoTuple(Array{Float64,1},false)
VmecWoutInfo[:iotas] = VmecWoutInfoTuple(Array{Float64,1},false)
VmecWoutInfo[:iotaf] = VmecWoutInfoTuple(Array{Float64,1},false)
VmecWoutInfo[:pres] = VmecWoutInfoTuple(Array{Float64,1},false)
VmecWoutInfo[:presf] = VmecWoutInfoTuple(Array{Float64,1},false)
VmecWoutInfo[:beta_vol] = VmecWoutInfoTuple(Array{Float64,1},false)
VmecWoutInfo[:raxis_cc] = VmecWoutInfoTuple(Array{Float64,1},false)
VmecWoutInfo[:raxis_cs] = VmecWoutInfoTuple(Array{Float64,1},true)
VmecWoutInfo[:zaxis_cs] = VmecWoutInfoTuple(Array{Float64,1},false)
VmecWoutInfo[:zaxis_cc] = VmecWoutInfoTuple(Array{Float64,1},true)
VmecWoutInfo[:am] = VmecWoutInfoTuple(Array{Float64,1},false)
VmecWoutInfo[:ac] = VmecWoutInfoTuple(Array{Float64,1},false)
VmecWoutInfo[:ai] = VmecWoutInfoTuple(Array{Float64,1},false)
VmecWoutInfo[:am_aux_s] = VmecWoutInfoTuple(Array{Float64,1},false)
VmecWoutInfo[:am_aux_f] = VmecWoutInfoTuple(Array{Float64,1},false)
VmecWoutInfo[:ac_aux_s] = VmecWoutInfoTuple(Array{Float64,1},false)
VmecWoutInfo[:ac_aux_f] = VmecWoutInfoTuple(Array{Float64,1},false)
VmecWoutInfo[:ai_aux_s] = VmecWoutInfoTuple(Array{Float64,1},false)
VmecWoutInfo[:ai_aux_f] = VmecWoutInfoTuple(Array{Float64,1},false)
VmecWoutInfo[:jcuru] = VmecWoutInfoTuple(Array{Float64,1},false)
VmecWoutInfo[:jcurv] = VmecWoutInfoTuple(Array{Float64,1},false)
VmecWoutInfo[:mass] = VmecWoutInfoTuple(Array{Float64,1},false)
VmecWoutInfo[:buco] = VmecWoutInfoTuple(Array{Float64,1},false)
VmecWoutInfo[:bvco] = VmecWoutInfoTuple(Array{Float64,1},false)
VmecWoutInfo[:vp] = VmecWoutInfoTuple(Array{Float64,1},false)
VmecWoutInfo[:specw] = VmecWoutInfoTuple(Array{Float64,1},false)
VmecWoutInfo[:over_r] = VmecWoutInfoTuple(Array{Float64,1},false)
VmecWoutInfo[:jdotb] = VmecWoutInfoTuple(Array{Float64,1},false)
VmecWoutInfo[:bdotb] = VmecWoutInfoTuple(Array{Float64,1},false)
VmecWoutInfo[:bdotgradv] = VmecWoutInfoTuple(Array{Float64,1},false)
VmecWoutInfo[:DMerc] = VmecWoutInfoTuple(Array{Float64,1},false)
VmecWoutInfo[:DShear] = VmecWoutInfoTuple(Array{Float64,1},false)
VmecWoutInfo[:DWell] = VmecWoutInfoTuple(Array{Float64,1},false)
VmecWoutInfo[:DCurr] = VmecWoutInfoTuple(Array{Float64,1},false)
VmecWoutInfo[:DGeod] = VmecWoutInfoTuple(Array{Float64,1},false)
VmecWoutInfo[:equif] = VmecWoutInfoTuple(Array{Float64,1},false)

VmecWoutInfo[:Aminor_p] = VmecWoutInfoTuple(Float64,false)
VmecWoutInfo[:Rmajor_p] = VmecWoutInfoTuple(Float64,false)
VmecWoutInfo[:aspect] = VmecWoutInfoTuple(Float64,false)
VmecWoutInfo[:volume_p] = VmecWoutInfoTuple(Float64,false)
VmecWoutInfo[:wb] = VmecWoutInfoTuple(Float64,false)
VmecWoutInfo[:wp] = VmecWoutInfoTuple(Float64,false)
VmecWoutInfo[:gamma] = VmecWoutInfoTuple(Float64,false)
VmecWoutInfo[:rmax_surf] = VmecWoutInfoTuple(Float64,false)
VmecWoutInfo[:rmin_surf] = VmecWoutInfoTuple(Float64,false)
VmecWoutInfo[:zmax_surf] = VmecWoutInfoTuple(Float64,false)
VmecWoutInfo[:betatotal] = VmecWoutInfoTuple(Float64,false)
VmecWoutInfo[:betator] = VmecWoutInfoTuple(Float64,false)
VmecWoutInfo[:betapol] = VmecWoutInfoTuple(Float64,false)
VmecWoutInfo[:betaxis] = VmecWoutInfoTuple(Float64,false)
VmecWoutInfo[:b0] = VmecWoutInfoTuple(Float64,false)
VmecWoutInfo[:rbtor0] = VmecWoutInfoTuple(Float64,false)
VmecWoutInfo[:rbtor] = VmecWoutInfoTuple(Float64,false)
VmecWoutInfo[:IonLarmor] = VmecWoutInfoTuple(Float64,false)
VmecWoutInfo[:volavgB] = VmecWoutInfoTuple(Float64,false)


VmecWoutInfo[:mnmax] = VmecWoutInfoTuple(Int32,false)
VmecWoutInfo[:mnmax_nyq] = VmecWoutInfoTuple(Int32,false)
VmecWoutInfo[:ns] = VmecWoutInfoTuple(Int32,false)
VmecWoutInfo[:mpol] = VmecWoutInfoTuple(Int32,false)
VmecWoutInfo[:ntor] = VmecWoutInfoTuple(Int32,false)
VmecWoutInfo[:signgs] = VmecWoutInfoTuple(Int32,false)
VmecWoutInfo[:nfp] = VmecWoutInfoTuple(Int32,false)

VmecWoutInfo[:pcurr_type] = VmecWoutInfoTuple(String,false)
VmecWoutInfo[:piota_type] = VmecWoutInfoTuple(String,false)
VmecWoutInfo[:pmass_type] = VmecWoutInfoTuple(String,false)

VmecWoutInfo[:lasym] = VmecWoutInfoTuple(Bool,false)
VmecWoutInfo[:lfreeb] = VmecWoutInfoTuple(Bool,false)

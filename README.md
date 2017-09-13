# Windsurf
Matlab-based coupler to simulate the co-evolution of the coastal zone to both winds and waves using XBeach, the Coastal Dune Model, and Aeolis

--------------------------------------------------------------------------------------------------------------------------------------

The Windsurf framework is a combined effort between researchers at Oregon State University,  Deltares, the Technical University of Delft, University of North Carolina Chapel Hill, UNESCO-IHE, and Texas A&M. The framework utilizes existing process-based numerical models which individually simulate subaqueous (XBeach) and subaerial (Coastal Dune Model, Aeolis) processes alog the outer coast to predict the simultaneous evolution of the nearshore, beach, and dune on time scales of hours to years. 

Windsurf acts as a coupler between these existing models by (1) initializing model cores, (2) exchanging relevant environmental and physical outputs between models, and (3) storing model information. This version of the code is written in Matlab (for versions > 2016a), a python-based version of this code utilizing the basic-model interface is also available at: https://github.com/openearth/windsurf. 

This is an experimental code which is still in development - bugs are still present. Work is also ongoing to validate general model behavior for real world sites.

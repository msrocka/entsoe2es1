entsoe2es1
==========
This project takes statistics from the [ENTSO-E](https://www.entsoe.eu) website as input 
and generates EcoSpold 1 data sets. Currently it only generates electricity production 
mixes but it could easily extended to also generate supply mixes by including the import 
and export statistics provided by ENTSO-E. 

The nomenclature of the generated files is compatible with the 
[ecoinvent 2]( http://ecoinvent.org/) database. Thus, the generated files link automatically 
to other ecoinvent 2 processes when building product systems in an 
[openLCA](http://openlca.org) database.

However, this project is currently a proof of concept for generating up-to-date electricity 
mix data and link them with existing LCA databases. The generated data are currently not 
complete and the links to existing flows may be missing or wrong.

Running the script
------------------
The conversion script is currently only executable on Windows as the Windows COM interface 
of Excel is used to read the ENTSO-E statistic files. The easiest way to run the script is 
to install [Lua for Windows]( https://code.google.com/p/luaforwindows/) as it already 
contains all required libraries (there is also a very nice open source LUA editor: 
[ZeroBraneStudio](https://studio.zerobrane.com/)).

To run the script, checkout this project and download the 
[detailed production statistics for all countries]( https://www.entsoe.eu/db-query/production/monthly-production-for-all-countries) 
from the ENTSO-E website. Copy the Excel file as ` 2013_Detailed_Monthly_Production.xls` 
into the `statistics` folder of this project. After this, run 

	Lua entsoe2es1.lua
    
and the EcoSpold files are generated in the `out` folder.

License
-------

com = require('luacom')
require("LuaXml") 
require('lfs')
require('logging')

-- set up the logger
log = logging.new(
    function(self, level, message)
        print(level, message)
        return true
    end)  
log:setLevel(logging.DEBUG)

-- columns of the respective production types
HYDRO_RIVER = 7
PUMPED_STORAGE = 8
NUCLEAR = 9
LIGNITE = 11
HARD_COAL = 12
GAS = 13
OIL = 14
WIND = 17
SOLAR = 18
BIOMASS = 19
columns = {HYDRO_RIVER, PUMPED_STORAGE, NUCLEAR, LIGNITE, HARD_COAL, 
    GAS, OIL, WIND, SOLAR, BIOMASS}

-- other sheet indices
CODE_COL = 1
START_ROW = 10
END_ROW = 429

-- open the workbook
productionBookPath =  lfs.currentdir() .. "\\statistics\\2013_Detailed_Monthly_Production.xls" 
log:info("read production workbook: %s", productionBookPath)
excel = com.CreateObject("Excel.Application") 
book = excel.Workbooks:Open(productionBookPath)
sheet = book.Sheets(1)

-- make the production table (aggregated over all months)
log:info("make production table")
productionTable = {}
for i = START_ROW, END_ROW, 1 do
    local code = sheet.Cells(i, CODE_COL).Text
    local countryTable = productionTable[code]    
    if countryTable == nil then
        countryTable = {}
        for k, col in pairs(columns) do
            countryTable[col] = 0
        end
        productionTable[code] = countryTable
    end
    for k, col in pairs(columns) do
        val = sheet.Cells(i, col).Value2
        if type(val) == 'number' then
            countryTable[col] = val + countryTable[col]
        end
    end
end

-- make the values for each country relative to 1 GWh -> same as for 1 kWh
log:info("make production relative")
for code, countryTable in pairs(productionTable) do
    local sum = 0
    for col, val in pairs(countryTable) do
        sum = sum + val 
    end
    -- log.info("total production for %s = %d", code, sum)
    for col, val in pairs(countryTable) do
        countryTable[col] = val / sum 
    end
end

-- name, category, subCategory attributes for the flows of the respective 
-- electricity type
names = {}
names[HYDRO_RIVER] = {"electricity, hydropower, at power plant", "hydro power", "power plants"}
names[PUMPED_STORAGE] = {"electricity, hydropower, at pumped storage power plant", "hydro power", "power plants"}
names[NUCLEAR] = {"electricity, nuclear, at power plant", "nuclear power", "power plants"}
names[LIGNITE] = {"electricity, lignite, at power plant", "lignite", "power plants"}
names[HARD_COAL] = {"electricity, hard coal, at power plant", "hard coal", "power plants"}
names[GAS] = {"electricity, natural gas, at power plant", "natural gas", "power plants"}
names[OIL] = {"electricity, oil, at power plant", "oil", "power plants"}
names[WIND] = {"electricity, at wind power plant", "wind power", "power plants"}
names[SOLAR] = {"electricity, production mix photovoltaic, at plant", "photovoltaic", "power plants"}
names[BIOMASS] = {"electricity, at cogen with biogas engine, allocation exergy", "biomass", "cogeneration"}

-- create the ecospold data sets
dofile("es1.lua")

function createExchange(code, col, val)
    local elem = xml.new("exchange")
    elem.number = col
    elem.name = names[col][1]
    elem.category = names[col][2]
    elem.subCategory = names[col][3]
    elem.meanValue = val
    elem.location = code
    elem.unit = "kWh"
    elem:append("inputGroup")[1] = 5
    elem.infrastructureProcess = "false"    
    return elem
end

for code, countryTable in pairs(productionTable) do
    local spold = initDataSet(code, 2013)
    for col, val in pairs(countryTable) do
        if val ~= 0 then
          spold[1][2]:append(createExchange(code, col, val))
        end
    end
    spold:append("child")
    xml.save(spold, "out\\production_" .. code .. ".xml")
end



require("LuaXml") 

function makeDataSetElem(number)
    local elem = xml.new("dataset")
    elem.number = number    
    elem.timestamp = os.date("%Y-%m-%dT%H:%M:%S", os.time())
    elem.generator = "ENTSO-E to EcoSpold 1 converter"
    return elem
end

-- create the reference function for the given location code
function makeRefFunElem(code)
    local elem = xml.new("referenceFunction")
    elem.name = "electricity, production mix " .. code
    elem.infrastructureProcess = "false"
    elem.unit = "kWh"
    elem.category = "ENTSO-E 2013"
    elem.subCategory = "production"
    elem.amount = 1
    elem.infrastructureIncluded = "false"
    elem.datasetRelatesToProduct = "true"
    return elem
end

function makeGeographyElem(code)
    local elem = xml.new("geography")
    elem.location = code
    return elem
end

function makeTimeElem(year)
    local elem = xml.new("timePeriod")
    elem.dataValidForEntirePeriod="true"
    elem.text = "Year of the ENTSO-E statistic"
    elem:append("startYear")[1] = year
    elem:append("endYear")[1] = year
    return elem
end

function makeDataSetInfoElem()
	local elem = xml.new("dataSetInformation")
	elem.type = 1
	elem.impactAssessmentResult = "false"
	elem.timestamp = os.date("%Y-%m-%dT%H:%M:%S", os.time())
	elem.version = "1.0"
	elem.internalVersion = "1.0"
	elem.energyValues = "0"
	elem.languageCode="en"
	elem.localLanguageCode = "en"
	return elem
end

function makeRefExchangeElem(code)
	local elem = xml.new("exchange")
	elem.name = "electricity, production mix " .. code
	elem.category = "electricity"
	elem.subCategory = "production mix"
	elem.location = code
	elem.unit = "kWh"
	elem.meanValue = 1
	elem.infrastructureProcess = "false"
	elem:append("outputGroup")[1] = 0
	return elem
end 

function initDataSet(locationCode, year)
    local spold = xml.new("ecoSpold")
    spold["xmlns"] = "http://www.EcoInvent.org/EcoSpold01"
    local ds = makeDataSetElem(1)
    local processInfo = spold:append(ds)
                        :append("metaInformation")
                        :append("processInformation")
    processInfo:append(makeRefFunElem(locationCode))
    processInfo:append(makeGeographyElem(locationCode))
    processInfo:append("technology")
    processInfo:append(makeTimeElem(year))
	processInfo:append(makeDataSetInfoElem())
	ds:append("flowData"):append(makeRefExchangeElem(locationCode))
    return spold
end

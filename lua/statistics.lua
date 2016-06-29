
local ST = {}

local TAG = "statistics"

----------------------------------------
-- tools
--
local err = function(...)
	print(TAG, "Error:", ...)
end

local validData = function(tData)
	if type(tData) ~= "table" then
		err("validData, invalid input")
		return nil
	end

	if not(next(tData)) then
		err("validData, empty input")
		return nil
	end

	local ret = {}
	for k, v in pairs(tData) do
		local data = tonumber(v)
		if not(data) then
			err("validData, invalid data element, index:", k)
			return nil
		end
		table.insert(ret, data)
	end

	return ret
end

----------------------------------------
-- interface
--

--
-- 和
--
ST.sum = function(tData)
	tData = validData(tData)
	if not(tData) then
		err("sum, invalid input")
		return 0
	end

	local ret = 0
	for k, v in ipairs(tData) do
		ret = ret + v
	end

	return ret
end

--
-- 平方和
--
ST.squareSum = function(tData)
	tData = validData(tData)
	if not(tData) then
		err("squareSum, invalid input")
		return 0
	end

	local ret = 0
	for k, v in ipairs(tData) do
		ret = ret + v * v
	end

	return ret
end

--
-- 期望
--
ST.expectation = function(tData)
	tData = validData(tData)
	if not(tData) then
		err("expectation, invalid input")
		return 0
	end

	local sum = ST.sum(tData)
	return sum / #tData
end

--
-- 方差
--
ST.deviation = function(tData)
	tData = validData(tData)
	if not(tData) then
		err("deviation, invalid input")
		return 0
	end

	local expectation = ST.expectation(tData)
	local tTemp = {}
	for k, v in ipairs(tData) do
		table.insert(tTemp, (v - expectation) ^ 2)
	end

	return ST.expectation(tTemp)
end

--
-- 标准差
--
ST.standardDeviation = function(tData)
	tData = validData(tData)
	if not(tData) then
		err("standardDeviation, invalid input")
		return 0
	end

	return math.sqrt(ST.deviation(tData))
end

--
-- 点积
--
ST.innerProduct = function(tData1, tData2)
	tData1 = validData(tData1)
	if not(tData1) then
		err("innerProduct, invalid input1")
		return 0
	end

	tData2 = validData(tData2)
	if not(tData2) then
		err("innerProduct, invalid input2")
		return 0
	end

	if #tData1 ~= #tData2 then
		err("innerProduct, input1's len ~= input2's len")
		return 0
	end

	local ret = 0
	for k, v in ipairs(tData1) do
		ret = ret + v * tData2[k]
	end

	return ret
end

--
-- 相关系数
--
ST.correlationCoefficient = function(tData1, tData2)
	tData1 = validData(tData1)
	if not(tData1) then
		err("correlationCoefficient, invalid input1")
		return 0
	end

	tData2 = validData(tData2)
	if not(tData2) then
		err("correlationCoefficient, invalid input2")
		return 0
	end

	if #tData1 ~= #tData2 then
		err("correlationCoefficient, input1's len ~= input2's len")
		return 0
	end

	local n = #tData1

	local sum1 = ST.sum(tData1)
	local squareSum1 = ST.squareSum(tData1)

	local sum2 = ST.sum(tData2)
	local squareSum2 = ST.squareSum(tData2)

	local innerProduct = ST.innerProduct(tData1, tData2)

	local a = n * innerProduct - sum1 * sum2
	local b = math.sqrt(n * squareSum1 - sum1 * sum1) * math.sqrt(n * squareSum2 - sum2 * sum2)
	return a / b
end

------------------------
-- test
--
local tData1 = {12.5, 15.3, 23.2, 26.4, 33.5, 34.4, 39.4, 45.2, 55.4, 60.9}
local tData2 = {21.2, 23.9, 32.9, 34.1, 42.5, 43.2, 49.0, 52.8, 59.4, 63.5}

print(ST.correlationCoefficient(tData2, tData1))


return ST
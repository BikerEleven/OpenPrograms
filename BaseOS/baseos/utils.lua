local utils = {};
local component = component or require("component");

local dataEnabled = false;

local function quickSort(array, left, right, index)

    i = left;
    k = right;
    if index ~= nil then
        pivot = array[math.floor((left + right) / 2)][index];
    else
        pivot = array[math.floor((left + right) / 2)];
    end

    while i <= k do --Partition
    
        while array[i] < pivot do --Find next larger
            i = i + 1;
        end

        while array[k] > pivot do --Find next smaller
            k = k - 1;
        end

        if i <= k then --Swapem if k is larger than i
            array[i], array[k] = array[k], array[i];
            i = i + 1; --i is going up to pivot
            k = k - 1; --k is going down to pivot
        end
    
    end

    if left < k then
        quickSort(array, left, k, index);
    end
    
    if i < right then
        quickSort(array, i, right, index);
    end
   
end


local function explode(data, file, padd)
    file:write("{\n");
    
    for k,v in pairs(data) do
        if type(v) == "table" then
            file:write("\t"..padd..k.." = ");
            explode(v, file, "\t"..padd);
        else
            file:write("\t"..padd..k.." = \""..tostring(v).."\"\n");
        end
    end
    
    file:write(padd.."}\n");
end

----------------------------------------------------------------------------------------

--Simple encryption system for the computer
--Requires a tier 2 data card to be installed
if component.list("data", true)() ~= nil then
    local data = component.proxy(component.list("data", true)());
    if data.random ~= nil then

		dataEnabled = true;
	
        local privateKey = data.random(16);
        local publicKey = data.random(16);
        
        function utils.getKey() 
            return publicKey;
        end

        function utils.encrypt(message, key, iv)
            trueKey = utils.hash(key):sub(1, 16);
            iv = iv or privateKey;
            return data.encrypt(message, trueKey, iv);
        end
        
        function utils.decrypt(mess, key, iv)
            trueKey = utils.hash(key):sub(1, 16);
            iv = iv or privateKey;
            return data.decrypt(mess, trueKey, iv);
        end
        
        function utils.hash(message)
            return data.sha256(message);
        end
        
    end
end

--Tests to see if the data card specific functions are enabled.
function utils.isDataEnabled()
	return dataEnabled;
end

--Implements a recursive quicksort
function utils.sort(array, index)
    checkArg(1, array, "table");
    checkArg(2, index, "string", "nil");
    
    left = 1;
    right = #array;
    
    quickSort(array, left, right, index);
end

--Implements a binary search algorithim, as such the array must be sorted
--Returns the position of the item, and the position where it should be if not found
function utils.find(array, item, index)
    checkArg(1, array, "table");
    checkArg(3, index, "string", "nil");
    
    position = -1;
    first = 0;
    last = #array;
    
    if index ~= nil then
        while position == -1 and first <= last do
            middle = math.floor((first + last) / 2);
            if array[middle][index] == item then
                position = middle;
            else
                if array[middle][index] > item then
                    last = middle - 1;
                else
                    first = middle + 1;
                end
            end
        end
    else
        while position == -1 and first <= last do
            middle = math.floor((first + last) / 2);
            if array[middle] == item then
                position = middle;
            else
                if array[middle] > item then
                    last = middle - 1;
                else
                    first = middle + 1;
                end
            end
        end
    end
    
    return position, first;
    
end

--Will insert an item into a sorted array
function utils.sortedInsert(array, item, index)
    
    if index ~= nil then
        pos, nextPos = utils.find(array, item[index], index);
        if pos > 0 then
            return -1;
        else
            table.insert(array, nextPos, item);
            return nextPos;
        end
    else
        pos, nextPos = utils.find(array, item);
        if pos > 0 then
            return -1;
        else
            table.insert(array, nextPos, item);
            return nextPos;
        end
    end
    
end

function utils.testArray(maxNum)
    test = {};
    maxNum = maxNum or 15
    for i=1, maxNum do
        table.insert(test, math.random(0, 100 * maxNum));
    end
    
    return test;
end

--Writes out text slowly
function utils.writeslowly(Text) 

	for i = 1, #Text, 1 do
		require("term").write( Text:sub(i, i) );
		os.sleep(0.05);
	end

end

function utils.dumpContents(item, fileName)
    file = io.open(fileName, "w");
    explode(item, file, "");
    file:close();
end

----------------------------------------------------------------------------------------

return utils;

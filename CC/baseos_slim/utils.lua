local utils = {};
local sha = require("Sha1");

local function convert(chars,dist,inv)  --Used by the encryption algorithm
    local charInt = string.byte(chars);

    for _=1, dist do
        if(inv)then charInt = charInt - 1; else charInt = charInt + 1; end
        if(charInt<32)then
            if(inv)then
                charInt = 126;
            else
                charInt = 126;
            end
        elseif(charInt>126)then
            if(inv)then
                charInt = 32;
            else
                charInt = 32;
            end
        end
    end

    return string.char(charInt);
end

local function quickSort(array, left, right)
    local i = left;
    local k = right;
    local pivot = array[math.floor((left + right) / 2)];

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
        quickSort(array, left, k);
    end
    
    if i < right then
        quickSort(array, i, right);
    end
end

--Simple encryption system for the computer
function utils.crypt(str, k, inv)   --Requires a string to encrypt, a key to encrypt by, encrypt or decrypt
    local enc= "";

    if str ~= nil then
        for i=1, #str do
            if(#str-k[5] >= i or not inv)then
                for inc=0,3 do
                    if(i%4 == inc)then
                        enc = enc .. convert(string.sub(str,i,i),k[inc+1],inv);
                        break;
                    end
                end
            end
        end
        if(not inv)then
            for _=1, k[5] do
                enc = enc .. string.char(math.random(32,126));
            end
        end
    end

    return enc;
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

function utils.hash(message)
    return sha(message);
end

--Implements a recursive quicksort
function utils.sort(array)
    quickSort(array, 1, #array);
end

function utils.testArray(maxNum)
    local test = {};
    maxNum = maxNum or 15
    for _=1, maxNum do
        table.insert(test, math.random(0, 100 * maxNum));
    end
    
    return test;
end

--Implements a binary search algorithm, as such the array must be sorted
--Returns the position of the item, and the position where it should be if not found
function utils.find(array, item)
    local position = -1;
    local first = 0;
    local last = #array;

    while position == -1 and first <= last do
        local middle = math.floor((first + last) / 2);
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

    return position, first;
end

--Will insert an item into a sorted array
function utils.sortedInsert(array, item)
    
    local pos, nextPos = find(array, item);
    if pos > 0 then
        return false;
    else
        table.insert(array, nextPos, item);
        return true;
    end
    
end

--Writes out text slowly
function utils.writeslowly(Text)
	for i = 1, #Text, 1 do
		term.write( string.char( Text:byte( i ) ) );
		sleep(0.05);
	end
end

function utils.dumpContents(item, file)
    file = io.open(file, "w");
    explode(item, file, "");
    file:close();
end


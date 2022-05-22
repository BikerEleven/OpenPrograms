local index;
local state;
term.clear();
term.setCursorPos(1,1);

--[[
{
    ["BaseOS"] = {
        name = "BaseOS",
        desc = "Slim version of BaseOS for CC: Tweaked",
        repo = "BikerEleven/OpenPrograms",
        files = {
            [":master/CC/baseos_slim"] = "/"
        }
    },
    ["botanaDropper"] = {
        name = "botanaDropper",
        desc = "Botana Endoflame Dropper",
        repo = "BikerEleven/OpenPrograms",
        dep = {
            ["Hook"] = "/"
        },
        files = {
            [":"] = "/"
        }
    }
}
--]]

local function getName(url)
    local a, b = string.find(url, "/");

    while a ~= nil do
        a = string.find(url, "/", a+1);
        if (a == nil) then
            return string.sub(url, b+1, -1);
        end

        b = a;
    end

    return url;
end

local function fetchIndex()
    print("Fetching remote index");
    local request = http.get("https://raw.githubusercontent.com/BikerEleven/OpenPrograms/master/.gititdex");
    if (request.getResponseCode() == 200) then
        index = textutils.unserialize(file.readAll());
        local file = fs.open(".gititdex", "w");
        file.write(textutils.serialize(index));
        file.close();
    end
    request.close();
end

local function getFile(remote, loc, optional)
    local fileLoc;

    if string.sub(loc, -1, -1) ~= "/" then loc = loc.."/"; end
    local path = loc..getName(remote);
    if (fs.exists(path) and optional) then return; end

    local request = http.get(remote);
    if (request.getResponseCode() == 200) then
        local file = fs.open(path, "w");
        file.write(request.readAll());
        file.close();

        fileLoc = path;
    end
    request.close();

    return fileLoc;
end

local function install(prog)
    state[prog["name"]] = {};
    state[prog["name"]].name = prog["name"];
    state[prog["name"]].files = {};
    for git, store in pairs(prog.files) do
        if (string.sub(git, 1, 1) == ":") then
            local a = string.find(git, "/");
            branch = string.sub(git, 2, a-1);
            path = string.sub(git, a+1, -1)
            local req = "https://api.github.com/repos/"..prog["repo"].."/contents/"..path.."?ref="..branch;

            local request = http.get(req);
            local files;
            if (request.getResponseCode() == 200) then
                files = textutils.unserializeJSON(request.readAll());
            end
            request.close();

            local dirs = {};
            for _, file in pairs(files) do
                if file.type == "dir" then
                    table.insert(dirs, file);
                elseif file.type == "file" then
                    local path = getFile(file["download_url"], store, false);
                    if path ~= nil then
                        table.insert(state[prog["name"]]["files"], path);
                        print("Downloaded", path);
                    end
                end
            end

            while #dirs > 0 do
                local temp = {};

                for dir in dirs do
                    request = http.get(dir.url);
                    files = textutils.unserializeJSON(request.readAll());
                    request.close();

                    for _, file in pairs(files) do
                        if file.type == "dir" then
                            table.insert(temp, file);
                        elseif file.type == "file" then
                            local path = getFile(file["download_url"], store, false);
                            if path ~= nil then
                                table.insert(state[prog["name"]]["files"], path);
                                print("Downloaded", path);
                            end
                        end
                    end
                end

                dirs = temp;
            end
        else
            local opt = string.sub(git, 1, 1) == "?";
            if opt then git = string.sub(git, 2, -1) end
            local path = getFile("https://raw.githubusercontent.com/"..prog["repo"].."/"..git, store, opt);
            if path ~= nil then
                table.insert(state[prog["name"]]["files"], path);
                print("Downloaded", path);
            end
        end
    end

    if prog.deps ~= nil then
        for k, _ in pairs(prog.deps) do
            install(index[k]);
            if state[".libs"] == nil then state[".libs"] = {}; end
            if state[".libs"][k] == nil then state[".libs"][k] = {}; state[".libs"][k][".cnt"] = 0; end
            if state[".libs"][k][prog.name] == nil then state[".libs"][k][".cnt"] = state[".libs"][k][".cnt"] + 1; end
            state[".libs"][k][prog.name] = true;
        end
    end

    local file = fs.open(".gitit", "w");
    file.write(textutils.serialize(state));
    file.close();
end

local function recursiveDelete(path, front)
    local _, b = string.find(path, "/", front);
    if b ~= nil then -- We have more to find
        recursiveDelete(path, b+1);
    else
        b = -1; -- Go to the end
    end

    local part = string.sub(path, 1, b);
    if part~= "" and part~="/" and not fs.isDriveRoot(part) then -- Technically /rom will always exist but best to be sure
        if fs.isDir(part) then
            if #fs.list(part) == 0 then
                print("Cleaning", part);
                fs.delete(part);
            end
        else
            print("Cleaning", part);
            fs.delete(part);
        end
    end
end

local function remove(prog, deps)
    for _, v in pairs(prog["files"]) do
        recursiveDelete(v, 1, 1);
    end

    if deps ~= nil then
        for k, _ in pairs(deps) do
            state[".libs"][k][prog.name] = nil;
            state[".libs"][k][".cnt"] = state[".libs"][k][".cnt"] - 1;
            if state[".libs"][k][".cnt"] == 0 then
                remove(state[k], index[k].deps);
                state[".libs"][k] = nil;
            end
        end
    end

    state[prog.name] = nil;
    local file = fs.open(".gitit", "w");
    file.write(textutils.serialize(state));
    file.close();
end

if fs.exists(".gitit") then
    local file = fs.open(".gitit", "r");
    state = textutils.unserialize(file.readAll());
    file.close();
else
    state = {}
    local file = fs.open(".gitit", "w");
    file.write(textutils.serialize(state));
    file.close();
end

if fs.exists(".gititdex") then
    local file = fs.open(".gititdex", "r");
    index = textutils.unserialize(file.readAll());
    file.close();
else
    fetchIndex();
end

local args = {...};
if (args[1] == "fetch") then
    fetchIndex()
end

if (args[1] == "install") then
    local prog = index[string.lower(args[2])];
    if prog ~= nil then
        if (state[prog["name"]] ~= nil) then
            print("Removing old install");
            remove(state[prog.name], prog.deps);
        end

        print("Installing", prog["name"]);
        install(prog);
        print("Done!");
    end
end

if (args[1] == "remove") then
    local prog = state[string.lower(args[2])];
    if prog ~= nil then
        print("Removing", string.lower(args[2]));
        remove(prog, index[prog.name].deps);
        print("Done!");
    end
end

if (args[1] == "list") then
    for prog, _ in pairs(index) do
        print(prog);
    end
end

if (args[1] == "installed") then
    for prog, _ in pairs(state) do
        print(prog);
    end
end
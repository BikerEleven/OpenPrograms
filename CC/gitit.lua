local index;
local state;

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
        index = textutils.unserialize(request.readAll());
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
    state[prog.name] = {};
    state[prog.name].name = prog.name;
    state[prog.name].hidden = prog.hidden == true;
    state[prog.name].files = {};
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

    if prog.dep ~= nil then
        for k, _ in pairs(prog.dep) do
            install(index[k]);
            if state[".libs"] == nil then state[".libs"] = {}; state[".libs"].hidden = true; end
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

local function remove(prog, dep)
    for _, v in pairs(prog["files"]) do
        recursiveDelete(v, 1, 1);
    end

    if dep ~= nil then
        for k, _ in pairs(dep) do
            state[".libs"][k][prog.name] = nil;
            state[".libs"][k][".cnt"] = state[".libs"][k][".cnt"] - 1;
            if state[".libs"][k][".cnt"] == 0 then
                remove(state[k], index[k].dep);
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
    term.clear();
    term.setCursorPos(1,1);
    fetchIndex();
end

local args = {...};
if (args[1] == "fetch") then
    term.clear();
    term.setCursorPos(1,1);
    fetchIndex()
end

if (args[1] == "install") then
    local prog = index[args[2]];
    if prog ~= nil then
        term.clear();
        term.setCursorPos(1,1);
        if (state[prog.name] ~= nil) then
            print("Removing old install");
            remove(state[prog.name], prog.dep);
        end

        print("Installing", prog["name"]);
        install(prog);
        print("Done!");
    else
        print("Program id not found");
    end
end

if (args[1] == "remove") then
    local prog = state[args[2]];
    if prog ~= nil then
        if state[".libs"] ~= nil and state[".libs"][args[2]] ~= nil then
            print("Can't remove library that is in use");
        else
            term.clear();
            term.setCursorPos(1,1);
            print("Removing", args[2]);
            remove(prog, index[prog.name].dep);
            print("Done!");
        end
    else
        print("Program id not found");
    end
end

if (args[1] == "list") then
    term.clear();
    term.setCursorPos(1,1);
    print("Available:");
    for prog, _ in pairs(index) do
        if index[prog].hidden ~= true then print(prog); end
    end
end

if (args[1] == "installed") then
    term.clear();
    term.setCursorPos(1,1);
    print("Installed:");
    for prog, _ in pairs(state) do
        if string.sub(prog, 1, 1) ~= "." and state[prog].hidden ~= true then print(prog); end
    end
end

if shell.getCompletionInfo()["gitit.lua"] == nil then
    local comp = require("cc.completion");

    local function compleatit(_, idx, argument, previous)
        if idx == 1 then
            local a = comp.choice(argument, {"remove"}, true);
            local b = comp.choice(argument, {"fetch", "list", "install", "installed"}, false);
            for _, k in ipairs(b) do
                table.insert(a, k);
            end
            return a;
        elseif idx == 2 then
            if previous[2] == "remove" then
                if fs.exists("/.gitit") then
                    local file = fs.open(".gitit", "r");
                    local istate = textutils.unserialize(file.readAll());
                    file.close();

                    local keys = {};
                    for k, _ in pairs(istate) do
                        if istate[".libs"][k] == nil and istate[k].hidden == false then
                            table.insert(keys, k);
                        end
                    end

                    return comp.choice(argument, keys, false);
                end
            elseif previous[2] == "install" then
                if fs.exists("/.gititdex") then
                    local file = fs.open(".gititdex", "r");
                    local iindex = textutils.unserialize(file.readAll());
                    file.close();

                    local keys = {};
                    for k, _ in pairs(iindex) do if iindex[k].hidden ~= true then table.insert(keys, k); end end
                    return comp.choice(argument, keys, false);
                end
            end
        end

        return nil;
    end

    shell.setCompletionFunction("gitit.lua", compleatit);
end
local comp = require("component");
local fs = require("filesystem");
local shell = require("shell");
local term = require("term");
local event = require("event");

term.write("Select a Disk or hit backspace to exit:\n");
local i = 1;
local disks = {};
for k,v in pairs(comp.list("filesystem")) do
  term.write(i..") "..k.."\n");
  i = i + 1;
  disks[i] = k;
end

local disk = "";

while disk == "" do
  _, _, _, key = event.pull("key_down");
  if key == 14 then return; end
  if disks[tonumber(key)] ~= nil then
    disk = disks[tonumber(key)];
  end
end

term.write("Enter the name of the program to install:\n");
local name = term.read();
name = shell.resolve(string.gsub(name, "\n", ""));
while name == "" or not fs.exists(name) do
  if name == "opt" then return; end
  term.write(name.." Program not found!\n");
  name = term.read();
  name = string.gsub(name, "\n", "");
end

local fname = string.gsub(name:match("^.+/(.+)$"), ".lua", "");

local diskfs = fs.proxy(disk);
local fileOut = diskfs.open("autorun.lua", "w");
local fileIn = io.open(name, "r");
diskfs.setLabel(fname);

local line = fileIn:read("*L");
while line ~= nil do
  diskfs.write(fileOut, line);
  line = fileIn:read("*L");
end

diskfs.close(fileOut);
fileIn:close();

term.write("done.\n");
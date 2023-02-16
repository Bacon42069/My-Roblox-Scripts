local socket;
local currentUsers={};
local data={};
local game=game;

if(getgenv().hosturl==nil)then getgenv().hosturl="ws://192.168.1.177:2344/";end;

local socker=((Krnl~=nil)and(Krnl.WebSocket~=nil)and(Krnl.WebSocket.connect))or((syn~=nil)and(syn.websocket~=nil)and(syn.websocket.connect));

if(game:IsLoaded()==false)then 
    game.Loaded:Wait();
end;
if(getgenv().visualizepart==nil)then 
    getgenv().visualizepart=Instance.new("Part");
    visualizepart.Material="ForceField";
    visualizepart.Name="Visualizer";
    visualizepart.Color=Color3.fromRGB(255,0,0);
    visualizepart.CFrame=CFrame.new(0,0,0);
    visualizepart.Size=Vector3.new(2,2,1);
    visualizepart.Anchored=true;
    visualizepart.CanCollide=false;
    visualizepart.Parent=game:GetService("Workspace");
end;

local hser=game:GetService("HttpService");
local deb=game:GetService("Debris");
local encodeo=hser.JSONEncode;
local decodeo=hser.JSONDecode;
local debaddo=deb.AddItem;
function encode(...)
    return(encodeo(hser,...));
end;
function decode(...)
    return(decodeo(hser,...));
end;
function debadd(...)
    return(debaddo(deb,...));
end;
function toTable(s,def)
	if(s:find('^%s*{'))then 
        if(s:find('[^\'"%w_]function[^\'"%w_]'))then return(def);end;
        s='return '..s;
        local chunk=loadstring(s,'tbl','t',{});
        if(chunk==nil)then return(def);end;
        local ok,ret=pcall(chunk);
        if(ok==true)then 
            return(ret)
        elseif(ok==false)then 
            return(def);
        end;
    end;
    return(def);
end;

if(socker==nil)then 
    error("Executor not supported!");
end;

getgenv().testcdesync=false;
getgenv().visualizepart.CFrame=CFrame.new(0,0,0);
if(Krnl~=nil)then 
    wait(2.5);
end;
wait(5);
getgenv().testcdesync=true;

local closed=false;
spawn(function()
    while(getgenv().testcdesync==true)and(wait())do 
        xpcall(function()
            closed=false;
            socket=socker(getgenv().hosturl);
            socket.OnMessage:Connect(function(msg)
                local spi=msg:split("´");
                if(spi[1]=="cons")then 
                    currentUsers={};
                    for a,b in pairs(decode(((spi[2]~="")and(spi[2]))or("{}")))do 
                        print(a,b);
                        if(game:GetService("Players"):FindFirstChild(a)~=nil)and(a~=game:GetService("Players").Name)then 
                            table.insert(currentUsers,game:GetService("Players"):FindFirstChild(a));
                        end;
                    end;
                    print(((spi[2]~="")and(spi[2]))or("{}"));
                elseif(spi[1]=="data")and(spi[2]=="lagviz")and(spi[3]==game:GetService("Players").LocalPlayer.Name)and(spi[4]~=game:GetService("Players").LocalPlayer.Name)then 
                    local rdata=toTable(spi[5],{CFrame=CFrame.new(0,0,0),Size=Vector3.new(2,2,1)});
                    getgenv().visualizepart.CFrame=rdata["CFrame"];
                    getgenv().visualizepart.Size=rdata["Size"];
                end;
            end);
            socket:Send("auth´"..game.Players.LocalPlayer.Name);
            local c;c=socket.OnClose:Connect(function()closed=true;end);
            while(getgenv().testcdesync==true)and(closed==false)do wait();end;
            pcall(function()c:Disconnect();socket:Close();end);
            socket=nil;
        end,print);
    end;
end);

if((getgenv().hostuser~=nil)and(getgenv().hostuser~=game:GetService("Players").LocalPlayer.Name))or(getgenv().hostuser==nil)or(getgenv().hostuser=="nil")then 
    spawn(function()
        while(getgenv().testcdesync==true)do 
            xpcall(function()
                if(socket~=nil)then 
                    for b,a in pairs(currentUsers)do 
                        if(a~=nil)and(a.Name~=game:GetService("Players").LocalPlayer.Name)then 
                            local cf=CFrame.new(0,0,0);
                            local sz=Vector3.new(2,2,1);pcall(function()cf=a.Character.HumanoidRootPart.CFrame;sz=a.Character.HumanoidRootPart.Size;end);
                            socket:Send("data´lagviz´"..a.Name.."´"..game:GetService("Players").LocalPlayer.Name.."´{CFrame = CFrame.new("..tostring(cf).."), Size = Vector3.new("..tostring(sz)..")}");
                        elseif(a~=nil)and(a.Name==game:GetService("Players").LocalPlayer.Name)then 
                            table.remove(currentUsers,b);
                        end;
                    end;
                end;
            end,print);
            wait(0.5);
        end;
    end);
end;

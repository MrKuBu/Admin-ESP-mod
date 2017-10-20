-- Creating adminESP client functions by MrKuBu

--[[--------------------------------------
	Customize the script (code :D)
----------------------------------------]]

local adminESPConfig = {}

adminESPConfig.command = '!adminesp' --	Set the chat command. (example !esp)

adminESPConfig.ranks = {			 -- Set the ranks able to use. (can also be set to false)
	'owner',
	'superadmin',
	'admin',
	'headadmin',
	'founder'
}

adminESPConfig.jobs		=	{ 		-- Set the jobs able to use. (can also be set to false)
	'Owner on duty',
	'Superadmin on duty',
	'Admin on duty'
}	


adminESPConfig.info			=	true						-- set if it should show info
adminESPConfig.infocol1		=	Color(0, 161, 255, 255)		-- set default color of info (Name)
adminESPConfig.infocol3		=	Color(150, 150, 150, 255)	-- set default color of info (info)

	
adminESPConfig.infoscol1	=	{	-- Add special colors for different ranks.
	owner 		= Color(255, 0, 0, 255),
	superadmin 	= Color(255, 50, 50, 255),
	admin		= Color(255, 100, 100, 255)
}

adminESPConfig.infocol2		=	Color(0, 0, 0, 255)			-- outline color of info
adminESPConfig.infodis	=	true							-- show distance?
adminESPConfig.infomon	=	false							-- show money? - This only worked DarkRP
adminESPConfig.infohp	=	true							-- show health?
adminESPConfig.infowep	=	true							-- show weapon?

adminESPConfig.chams			=		true				-- set if it should show chams
adminESPConfig.chamsc		=	Color(0, 161, 255, 255)		-- set cham player default color


adminESPConfig.chamssc		=	{	-- Add special colors for different ranks.
	owner 		= Color(255, 0, 0, 255),	 	
	superadmin 	= Color(255, 50, 50, 255),
	admin		= Color(255, 100, 100, 255)
}


adminESPConfig.chamswep		=	true						 -- show weapon?
adminESPConfig.chamswepc	=	Color(255, 255, 255, 255)	 -- set cham weapon color


--[[--------------------------------------
	End customize
----------------------------------------]]

--[[-------------------------------------------------------------------
	Actual script, don't touch this unless you know what you are doing.
---------------------------------------------------------------------]]

local AESP = {}

AESP.Matinfo = {
	["$basetexture"] = 'models/debug/debugwhite',
	["$model"]       = 1,
	["$nocull"]      = 1,
	["$ignorez"]     = 1
}

AESP.Mat = (CreateMaterial( "chams", "VertexLitGeneric", AESP.Matinfo )) 

function AESP.Print ( txt )
	chat.AddText( Color(0, 161, 255, 255), '[MK-esp] ', Color( 255, 255, 255, 255 ), txt)
end

function AESP.CheckCommand (ply, txt)
	if ply == LocalPlayer() and txt == adminESPConfig.command then
		if (adminESPConfig.ranks and table.HasValue(adminESPConfig.ranks, ply:GetUserGroup())) or (adminESPConfig.jobs and table.HasValue(adminESPConfig.jobs, ply.DarkRPVars.job)) then
			AESP.EspToggle ()
		else
			AESP.Print ( 'You do not have acces to this!' )
		end
	end
end

function AESP.StopVisualRecoil ( ply, pos, angles, fov )
	return GAMEMODE:CalcView ( ply, LocalPlayer():EyePos(), LocalPlayer():EyeAngles(), fov, 0.1 )
end

function AESP.EspToggle()
	if !AESP.ESP then
		AESP.ESP = true
		AESP.Print ( 'ON' )
		
		-- Info
		hook.Add('HUDPaint', 'AESP.Info', function()
			for k,v in pairs(player.GetAll()) do
				if v != LocalPlayer() then
					local position = (v:GetPos() + Vector(0, 0, 100)):ToScreen() 
					local color = adminESPConfig.infocol1
					if adminESPConfig.infoscol1[v:GetUserGroup()] then
						color = adminESPConfig.infoscol1[v:GetUserGroup()]
					else
						color = adminESPConfig.infocol1
					end
					draw.SimpleTextOutlined ( v:GetName(), 'Default', position.x - 5, position.y - 2, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, adminESPConfig.infocol2 )	
					if adminESPConfig.infodis then
						draw.SimpleTextOutlined ( 'D: ' .. math.Round(v:GetPos():Distance(LocalPlayer():GetPos())), 'Default', position.x - 5, position.y + 8, adminESPConfig.infocol3, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, adminESPConfig.infocol2 )	
					end
					if adminESPConfig.infomon and adminESPConfig.ttt then
						local money = v.DarkRPVars.money or 0
						if adminESPConfig.infodis then
							draw.SimpleTextOutlined ( '$: ' .. money, 'Default', position.x - 5, position.y + 18, adminESPConfig.infocol3, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, adminESPConfig.infocol2 )										
						else
							draw.SimpleTextOutlined ( '$: ' .. money, 'Default', position.x - 5, position.y + 8, adminESPConfig.infocol3, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, adminESPConfig.infocol2 )																
						end
					end
					if adminESPConfig.infohp then
						if adminESPConfig.infodis then
							if adminESPConfig.infomon then
								draw.SimpleTextOutlined ( 'HP: ' .. v:Health(), 'Default', position.x - 5, position.y + 28, adminESPConfig.infocol3, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, adminESPConfig.infocol2 )					
							else
								draw.SimpleTextOutlined ( 'HP: ' .. v:Health(), 'Default', position.x - 5, position.y + 18, adminESPConfig.infocol3, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, adminESPConfig.infocol2 )												
							end
						else
							if adminESPConfig.infomon then
								draw.SimpleTextOutlined ( 'HP: ' .. v:Health(), 'Default', position.x - 5, position.y + 18, adminESPConfig.infocol3, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, adminESPConfig.infocol2 )					
							else
								draw.SimpleTextOutlined ( 'HP: ' .. v:Health(), 'Default', position.x - 5, position.y + 8, adminESPConfig.infocol3, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, adminESPConfig.infocol2 )												
							end						
						end
					end
					if adminESPConfig.infowep and (IsValid(v:GetActiveWeapon())) then
						if adminESPConfig.infodis then
							if adminESPConfig.infomon then
								local wep = (v:GetActiveWeapon():GetPrintName() or 'none')
								if adminESPConfig.infohp then
									draw.SimpleTextOutlined ( 'W: ' .. wep, 'Default', position.x - 5, position.y + 38, adminESPConfig.infocol3, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, adminESPConfig.infocol2 )										
								else
									draw.SimpleTextOutlined ( 'W: ' .. wep, 'Default', position.x - 5, position.y + 28, adminESPConfig.infocol3, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, adminESPConfig.infocol2 )																		
								end
							else
								local wep = (v:GetActiveWeapon():GetPrintName() or 'none')
								if adminESPConfig.infohp then
									draw.SimpleTextOutlined ( 'W: ' .. wep, 'Default', position.x - 5, position.y + 28, adminESPConfig.infocol3, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, adminESPConfig.infocol2 )										
								else
									draw.SimpleTextOutlined ( 'W: ' .. wep, 'Default', position.x - 5, position.y + 18, adminESPConfig.infocol3, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, adminESPConfig.infocol2 )																		
								end							
							end
						else
							if adminESPConfig.infomon  then
								local wep = (v:GetActiveWeapon():GetPrintName() or 'none')
								if adminESPConfig.infohp then
									draw.SimpleTextOutlined ( 'W: ' .. wep, 'Default', position.x - 5, position.y + 28, adminESPConfig.infocol3, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, adminESPConfig.infocol2 )										
								else
									draw.SimpleTextOutlined ( 'W: ' .. wep, 'Default', position.x - 5, position.y + 18, adminESPConfig.infocol3, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, adminESPConfig.infocol2 )																		
								end
							else
								local wep = (v:GetActiveWeapon():GetPrintName() or 'none')
								if adminESPConfig.infohp then
									draw.SimpleTextOutlined ( 'W: ' .. wep, 'Default', position.x - 5, position.y + 18, adminESPConfig.infocol3, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, adminESPConfig.infocol2 )										
								else
									draw.SimpleTextOutlined ( 'W: ' .. wep, 'Default', position.x - 5, position.y + 8, adminESPConfig.infocol3, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, adminESPConfig.infocol2 )																		
								end							
							end						
						end
					end		
				end
			end
		end)
		
	-- Chams
	hook.Add('CalcView', 'StopVisualRecoil', AESP.StopVisualRecoil)
	hook.Add('RenderScreenspaceEffects', 'Chams', function()
		cam.Start3D( LocalPlayer():EyePos(), LocalPlayer():EyeAngles() )
		for k,v in pairs(player.GetAll()) do
			if v != LocalPlayer() and v:Alive() then
					render.SuppressEngineLighting ( true )
					local color = adminESPConfig.chamsc
					if adminESPConfig.chamssc[v:GetUserGroup()] then
						color = adminESPConfig.chamssc[v:GetUserGroup()]
					else
						color = adminESPConfig.chamsc
					end
					render.SetColorModulation ( color.r/255, color.g/255, color.b/255, 1 )
					render.MaterialOverride ( AESP.Mat )
					v:DrawModel()
					render.SetColorModulation ( adminESPConfig.chamswepc.r, adminESPConfig.chamswepc.g, adminESPConfig.chamswepc.b, 1 )
					if (IsValid(v:GetActiveWeapon())) then
						v:GetActiveWeapon():DrawModel()
					end
					render.SetColorModulation ( 1, 1, 1, 1 )
					render.MaterialOverride() 
					render.SetModelLighting ( 4, color.r/255, color.g/255, color.b/255 )
					v:DrawModel()
					if (IsValid(v:GetActiveWeapon())) then
						v:GetActiveWeapon():DrawModel()
					end
					render.SuppressEngineLighting ( false )
			
			end
		end
		cam.End3D()	
	end)
	else
		AESP.ESP = false
		AESP.Print ( 'OFF' )
		hook.Remove('HUDPaint', 'AESP.Info')
		hook.Remove('CalcView', 'StopVisualRecoil')
		hook.Remove('RenderScreenspaceEffects', 'Chams')
	end
end

--[[---------------------------------
	Locals, don't touch this please
-----------------------------------]]
local Addon 	= "Admin Esp Mod"
local Version 	= "1.4"
local Autor 	= "MrKuBu"
local WorkShop 	= "https://steamcommunity.com/sharedfiles/filedetails/?id=740196784"
local VK 		= "https://vk.com/mrkubu"
local YouTube 	= "https://youtube.com/MrKuBu"
local MyProject = "https://vk.com/awesomiumrp"
local GitHub    = "https://github.com/MrKuBu"
--[[------------------------------
	End locals
---------------------------------]]
 
hook.Add('OnPlayerChat', 'CheckCommand', AESP.CheckCommand)



MsgC(Color(255,0,0), "------->\n")
MsgC(Color(0,255,0), Addon.."\n")
MsgC(Color(0,255,0), "By ")MsgC(Color(255,0,0), Autor.."\n")
MsgC(Color(0,255,0), "Version: ")MsgC(Color(0,0,255), Version.."\n")
MsgC(Color(0,255,0), "My Links: \n")
MsgC(Color(255,255,0), "  Addon: ")MsgC(Color(0,255,0), WorkShop.."\n")
MsgC(Color(255,255,0), "  My VK: ")MsgC(Color(0,255,0), VK.."\n")
MsgC(Color(255,255,0), "  My YouTube: ")MsgC(Color(0,255,0), YouTube.."\n")
MsgC(Color(255,255,0), "  AwesomiumRP: ")MsgC(Color(0,255,0), MyProject.."\n")
MsgC(Color(255,255,0), "  GitHub: ")MsgC(Color(0,255,0), GitHub.."\n")
MsgC(Color(255,0,0), "------->\n")

--[[ 
	ONEMenu
	Application, themes and files manager.
	
	Licensed by Creative Commons Attribution-ShareAlike 4.0
	http://creativecommons.org/licenses/by-sa/4.0/
	
	Designed By Gdljjrod & DevDavisNunez.
	Collaborators: BaltazaR4 & Wzjk.
]]

uri = {}
uri["NPXS10000"] = "near:"
uri["NPXS10001"] = "pspy:"
uri["NPXS10002"] = "psns:browse?category=STORE-MSF73008-VITAGAMES"--"psns:browse?category="
uri["NPXS10003"] = "wbapp0:"
--uri["NPXS10004"] = "camera:"
--uri["NPXS10006"] = "pspr:"			--friends
--uri["NPXS10007"] = ""					--welcome park
uri["NPXS10008"] = "pstc:"
uri["NPXS10009"] = "music:" 
uri["NPXS10010"] = "video:"
--uri["NPXS10012"] = ""					--uso distancia PS3
--uri["NPXS10013"] = ""					--enlace ps4
uri["NPXS10014"] = "psnmsg:"
uri["NPXS10015"] = "settings_dlg:"
--uri["NPXS10026"] = ""					--CMA
uri["NPXS10072"] = "email:"
uri["NPXS10091"] = "scecalendar:"
--uri["NPXS10094"] = ""					--Parental Controls

system = { data = {}, len = 0, sort = 0 }

-- Timer and Oldstate to click actions.
local crono_sys, show_sys = timer.new(), false
local crono2, clic = timer.new(), false

function restart_crono_sys()
	crono_sys:reset()
	crono_sys:start()
	show_sys,pic1_sys = false,nil
end

function system.refresh()

	if system.len == 0 then

		system.data = game.list(__GAME_LIST_SYS)
		system.sort = tonumber(ini.read(__PATH_INI,"sort","sys","1"))
		if system.sort == 1 then
			table.sort(system.data, function (a,b) return string.lower(a.title)<string.lower(b.title) end)
		else
			table.sort(system.data, function (a,b) return string.lower(a.id)<string.lower(b.id) end)
		end
		system.len = #system.data

		for i=1, system.len do
			if uri[system.data[i].id] then system.data[i].uri = uri[system.data[i].id] end
			if system.data[i].title	then system.data[i].title = system.data[i].title:gsub("\n"," ") end
		end
	end

end

--id, type, version, dev, path, title
function system.run()

	system.refresh()

	local scroll = newScroll(system.data,15)

	buttons.interval(15,4)
	local preview = nil
	local themesimg = image.load(__PATH_THEMES..__THEME.."/themesmanager.png") or image.load("system/theme/default/themesmanager.png")
	while true do
		buttons.read()
		touch.read()

		if themesimg then themesimg:blit(0,0) elseif theme.data["back"] then theme.data["back"]:blit(0,0) end
		
		if pic1_sys then
			pic1_sys:blit(0,55,125)
		end

		screen.print(480,15,strings.liveareapps,1,theme.style.TITLECOLOR,color.gray,__ACENTER)

		if system.len > 0 then

			local y = 80
			for i=scroll.ini,scroll.lim do
				if i == scroll.sel then
					draw.fillrect(10,y-2,675,23,theme.style.SELCOLOR)
					if not preview then
						preview = image.load(system.data[i].path.."/sce_sys/icon0.png")
						if preview then preview:setfilter(__IMG_FILTER_LINEAR, __IMG_FILTER_LINEAR) end
					end
					if not pic1_sys and show_sys then
						pic1_sys = image.load(system.data[i].path.."/sce_sys/livearea/contents/bg0.png")
						if pic1_sys then
							pic1_sys:resize(692,446)
							pic1_sys:setfilter(__IMG_FILTER_LINEAR, __IMG_FILTER_LINEAR)
						end
					end
				end
				screen.print(15,y, system.data[i].title,1.0,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR,__ALEFT)
				y+=26
			end

			if preview then
				screen.clip(825,150, preview:geth()/2)--272
					preview:center()
					preview:blit(825,150)
				screen.clip()
			end

			screen.print(10,520,system.data[scroll.sel].id,1,theme.style.TXTCOLOR,theme.style.TXTBKGCOLOR,__ALEFT)
		else
			screen.print(480,15,strings.noliveareapps,1,theme.style.TITLECOLOR,color.gray,__ACENTER)

		end
		screen.flip()
		
		--Controls
		if system.len > 0 then

			if buttons.up or buttons.analogly<-60 then
				if scroll:up() then
					preview = nil
					restart_crono_sys()
				end
			end

			if buttons.down or buttons.analogly>60 then
				if scroll:down() then
					preview = nil
					restart_crono_sys()
				end
			end

			if buttons[accept] then
				if not system.data[scroll.sel].uri then game.open(system.data[scroll.sel].id) else os.uri(system.data[scroll.sel].uri) end
			end
			if isTouched(770,90,128,128) and touch.front[1].released then
				if clic then
					clic = false
					if crono2:time() <= 300 then -- Double click and in time to Go.
						-- Your action here.
						if not system.data[scroll.sel].uri then game.open(system.data[scroll.sel].id) else os.uri(system.data[scroll.sel].uri) end
					end
				else
					-- Your action here.
					clic = true
					crono2:reset()
					crono2:start()
				end
			end

			if crono2:time() > 300 then -- First click, but long time to double click...
				clic = false
			end

			if crono_sys:time() > 550 then
				show_sys = true
			end
		end

		if buttons.select then
			if system.sort == 1 then
				system.sort = 0
				table.sort(system.data, function (a,b) return string.lower(a.id)<string.lower(b.id) end)
			else
				system.sort = 1
				table.sort(system.data, function (a,b) return string.lower(a.title)<string.lower(b.title) end)
			end
			write_config()
			pic1_sys,preview = nil,nil
			os.delay(150)
			restart_cronopic()
		end

		if buttons.start or buttons[cancel] then
			restart_cronopic()
			pic1_sys,preview = nil,nil
			os.delay(80)
			buttons.interval(10,10)
			break
		end

		shortcuts()

	end
end

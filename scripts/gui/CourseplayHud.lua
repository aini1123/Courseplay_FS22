---@class CourseplayHud
CourseplayHud = CpObject()

CourseplayHud.OFF_COLOR = {0.2, 0.2, 0.2, 0.9}
CourseplayHud.ON_COLOR = {0, 0.6, 0, 0.9}

CourseplayHud.basePosition = {
    x = 810,
    y = 60
}

CourseplayHud.baseSize = {
    x = 360,
    y = 200
}

CourseplayHud.titleFontSize = 20
CourseplayHud.defaultFontSize = 18

CourseplayHud.numLines = 7

CourseplayHud.uvs = {
    plusSymbol = {
        {0, 512, 128, 128}
    },
    minusSymbol = {
        {128, 512, 128, 128}
    }
}

function CourseplayHud:init(vehicle)
    self.vehicle = vehicle

    self.uiScale = g_gameSettings:getValue("uiScale")

    self.x, self.y = getNormalizedScreenValues(self.basePosition.x, self.basePosition.y)
    self.width, self.height = getNormalizedScreenValues(self.baseSize.x * self.uiScale, self.baseSize.y * self.uiScale)

    local background = Overlay.new(g_baseUIFilename, 0, 0, 1, 1)
    background:setUVs(g_colorBgUVs)
    background:setColor(0, 0, 0, 0.7)

    
    self.lineHeight = self.height/(self.numLines+1)
    self.hMargin = self.lineHeight
    self.wMargin = self.lineHeight/2

    self.lines = {}
    for i=1,self.numLines do 
        local y = self.y + self.hMargin + self.lineHeight * (i-1)
        local line = {
            left = {
                self.x + self.wMargin, y
            },
            right = {
                self.x + self.width - self.wMargin, y
            }
        }
        self.lines[i] = line
    end


    --- Root element
    self.baseHud = CpHudMoveableElement.new(background)
    self.baseHud:setPosition(self.x, self.y)
    self.baseHud:setDimension(self.width, self.height)

    --------------------------------------
    --- Left side
    --------------------------------------

    --- Cp icon 
    local cpIconWidth, height = getNormalizedScreenValues(30 * self.uiScale, 30 * self.uiScale)
    local cpIconOverlay =  Overlay.new(Utils.getFilename("img/courseplayIconHud.dds",Courseplay.BASE_DIRECTORY), 0, 0,cpIconWidth, height)
    cpIconOverlay:setAlignment(Overlay.ALIGN_VERTICAL_MIDDLE, Overlay.ALIGN_HORIZONTAL_LEFT)
    cpIconOverlay:setUVs(GuiUtils.getUVs({80, 26, 144, 144}, {256,256}))
    self.cpIcon = CpHudButtonElement.new(cpIconOverlay, self.baseHud)
    local x, y = unpack(self.lines[7].left)
    self.cpIcon:setPosition(x, y)
    self.cpIcon:setCallback("onClickPrimary",self.vehicle,function (vehicle)
                                self:openGlobalSettingsGui(vehicle)
                            end)


    --- Title 
    local x,y = unpack(self.lines[7].left)
    x = x + cpIconWidth + self.wMargin
    self.vehicleNameBtn = CpTextHudElement.new(self.baseHud ,x , y, self.defaultFontSize)
    self.vehicleNameBtn:setCallback("onClickPrimary", self.vehicle, 
                                function()
                                    self:openVehicleSettingsGui(self.vehicle)
                                end)

    --- Starting point
    self.startingPointBtn = self:addLeftLineTextButton(self.baseHud, 5, self.defaultFontSize, 
        function (vehicle)
            vehicle:getCpStartingPointSetting():setNextItem()
        end, self.vehicle)

     --- Course name
    self.courseNameBtn = self:addLeftLineTextButton(self.baseHud, 4, self.defaultFontSize, 
                                                        function()
                                                            self:openCourseGeneratorGui(self.vehicle)
                                                        end, self.vehicle)

    --------------------------------------
    --- Right side
    --------------------------------------

    --- Create start/stop button
    local width, height = getNormalizedScreenValues(18 * self.uiScale, 18 * self.uiScale)
    local onOffIndicatorOverlay =  Overlay.new(g_baseUIFilename, 0, 0, width, height)
    onOffIndicatorOverlay:setAlignment(Overlay.ALIGN_VERTICAL_TOP, Overlay.ALIGN_HORIZONTAL_RIGHT)
    onOffIndicatorOverlay:setUVs(GuiUtils.getUVs(MixerWagonHUDExtension.UV.RANGE_MARKER_ARROW))
    onOffIndicatorOverlay:setColor(unpack(CourseplayHud.OFF_COLOR))
    self.onOffButton = CpHudButtonElement.new(onOffIndicatorOverlay, self.baseHud)
    local x, y = unpack(self.lines[7].right)
    self.onOffButton:setPosition(x, y)
    self.onOffButton:setCallback("onClickPrimary", self.vehicle, self.vehicle.cpStartStopDriver)
    
    
    
    --- Lane offset
    self.laneOffsetBtn = self:addRightLineTextButton(self.baseHud, 5, self.defaultFontSize, 
        function (vehicle)
            vehicle:getCpLaneOffsetSetting():setNextItem()
        end, self.vehicle)
  
    --- Waypoint progress
    self.waypointProgressBtn = self:addRightLineTextButton(self.baseHud, 4, self.defaultFontSize, 
                                                        function()
                                                            self:openCourseManagerGui(self.vehicle)
                                                        end, self.vehicle)

    --------------------------------------
    --- Complete line
    --------------------------------------
   
    --- Work width
    self.workWidthBtn = self:addLineTextButton(self.baseHud, 3, self.defaultFontSize, 
                                                self.vehicle:getCourseGeneratorSettings().workWidth)

    --- Tool offset x
    self.toolOffsetXBtn = self:addLineTextButton(self.baseHud, 2, self.defaultFontSize, 
                                                self.vehicle:getCpSettings().toolOffsetX)

    --- Tool offset z
    self.toolOffsetZBtn = self:addLineTextButton(self.baseHud, 1, self.defaultFontSize, 
                                                self.vehicle:getCpSettings().toolOffsetZ)

    ---- Disables zoom, while mouse is over the cp hud. 
    local function disableCameraZoomOverHud(vehicle,superFunc,...)
        if vehicle:getIsMouseOverCpHud() then 
            return
        end
        return superFunc(vehicle,...)
    end                                                   

    Enterable.actionEventCameraZoomIn = Utils.overwrittenFunction(Enterable.actionEventCameraZoomIn,disableCameraZoomOverHud)
    Enterable.actionEventCameraZoomOut = Utils.overwrittenFunction(Enterable.actionEventCameraZoomOut,disableCameraZoomOverHud)
end

function CourseplayHud:addLeftLineTextButton(parent, line, textSize, callbackFunc,callbackClass)
    local x,y = unpack(self.lines[line].left)
    print(x)
    local element = CpTextHudElement.new(parent ,x , y, textSize)
    element:setCallback("onClickPrimary", callbackClass, callbackFunc)
    return element
end

function CourseplayHud:addRightLineTextButton(parent, line, textSize, callbackFunc,callbackClass)
    local x,y = unpack(self.lines[line].right)
    local element = CpTextHudElement.new(parent ,x , y, 
                                        textSize,RenderText.ALIGN_RIGHT)
    element:setCallback("onClickPrimary", callbackClass, callbackFunc)
    return element
end

function CourseplayHud:addLineTextButton(parent, line, textSize, setting)
    local imageFilename = Utils.getFilename('img/ui_courseplay.dds', g_Courseplay.BASE_DIRECTORY)

    local width, height = getNormalizedScreenValues(16 * self.uiScale, 16 * self.uiScale)
    local incrementalOverlay =  Overlay.new(imageFilename, 0, 0, width, height)
    incrementalOverlay:setAlignment(Overlay.ALIGN_VERTICAL_BOTTOM, Overlay.ALIGN_HORIZONTAL_RIGHT)
    incrementalOverlay:setUVs(GuiUtils.getUVs(unpack(self.uvs.plusSymbol)))
    incrementalOverlay:setColor(unpack(self.OFF_COLOR))
    local decrementalOverlay =  Overlay.new(imageFilename, 0, 0, width, height)
  --  decrementalOverlay:setAlignment(Overlay.ALIGN_VERTICAL_TOP, Overlay.ALIGN_HORIZONTAL_RIGHT)
    decrementalOverlay:setUVs(GuiUtils.getUVs(unpack(self.uvs.minusSymbol)))
    decrementalOverlay:setColor(unpack(self.OFF_COLOR))

    local x, y = unpack(self.lines[line].left)
    local dx, dy = unpack(self.lines[line].right)
    local element = CpHudSettingElement.new(parent, x, y, dx, dy, 
                                            incrementalOverlay, decrementalOverlay, textSize)

    local callbackIncremental = {
        callbackStr = "onClickPrimary",
        class =  setting,
        func =  setting.setNextItem,
    }
    
    local callbackDecremental = {
        callbackStr = "onClickPrimary",
        class =  setting,
        func =  setting.setPreviousItem,
    }

    local callbackLabel = {
        callbackStr = "onClickPrimary",
        class =  setting,
        func =  setting.setDefault,
    }

    local callbackText = {
        callbackStr = "onClickMouseWheel",
        class =  setting,
        func = function (class,dir)
            if dir >0 then 
                class:setNextItem()
            else
                class:setPreviousItem()
            end
        end
    }
                                             

    element:setCallback(callbackLabel, callbackText, callbackIncremental, callbackDecremental)
    return element
end


function CourseplayHud:mouseEvent(posX, posY, isDown, isUp, button)
    local wasUsed = self.baseHud:mouseEvent(posX, posY, isDown, isUp, button)
    if wasUsed then 
        return
    end
end

function CourseplayHud:isMouseOverArea(posX, posY)
    return self.baseHud:isMouseOverArea(posX, posY) 
end

---@param status CpStatus
function CourseplayHud:draw(status)
    
    --- Set variable data.
    self.courseNameBtn:setTextDetails(self.vehicle:getCurrentCpCourseName())
    self.vehicleNameBtn:setTextDetails(self.vehicle:getName())
    self.startingPointBtn:setTextDetails(self.vehicle:getCpStartingPointSetting():getString())
    if status:getIsActive() then
        self.onOffButton:setColor(unpack(CourseplayHud.ON_COLOR))
    else
        self.onOffButton:setColor(unpack(CourseplayHud.OFF_COLOR))
    end
    self.waypointProgressBtn:setTextDetails(status:getWaypointText())
    
    local laneOffset = self.vehicle:getCpLaneOffsetSetting()
    self.laneOffsetBtn:setVisible(laneOffset:getCanBeChanged())
    self.laneOffsetBtn:setTextDetails(laneOffset:getString())

    local workWidth = self.vehicle:getCourseGeneratorSettings().workWidth
    self.workWidthBtn:setTextDetails(workWidth:getTitle(), workWidth:getString())

    local toolOffsetX = self.vehicle:getCpSettings().toolOffsetX
    self.toolOffsetXBtn:setTextDetails(toolOffsetX:getTitle(), toolOffsetX:getString())

    local toolOffsetZ = self.vehicle:getCpSettings().toolOffsetZ
    self.toolOffsetZBtn:setTextDetails(toolOffsetZ:getTitle(), toolOffsetZ:getString())

    self.baseHud:draw()
end

function CourseplayHud:delete()
    self.baseHud:delete()
end

function CourseplayHud:getIsHovered()
    return self.baseHud:getIsHovered()    
end

--------------------------------------
--- Hud element callbacks
--------------------------------------

function CourseplayHud:preOpeningInGameMenu(vehicle)
    local inGameMenu =  g_currentMission.inGameMenu
    local pageAI = inGameMenu.pageAI
    pageAI.controlledVehicle = vehicle
    pageAI.currentHotspot = nil
    inGameMenu:updatePages()
    g_gui:showGui("InGameMenu")
    inGameMenu:changeScreen(InGameMenu)
    return inGameMenu
end

function CourseplayHud:openCourseManagerGui(vehicle)
    local inGameMenu = self:preOpeningInGameMenu(vehicle)
    local courseManagerPageIx = inGameMenu.pagingElement:getPageMappingIndexByElement(inGameMenu.pageCpCourseManager)
    inGameMenu.pageSelector:setState(courseManagerPageIx, true)
end

function CourseplayHud:openCourseGeneratorGui(vehicle)
    local inGameMenu = self:preOpeningInGameMenu(vehicle)
     --- Opens the course generator if possible.
    local pageIx = inGameMenu.pagingElement:getPageMappingIndexByElement(inGameMenu.pageAI)
    inGameMenu.pageSelector:setState(pageIx, true)
    inGameMenu.pageAI:onCreateJob()
    for i,index in ipairs(inGameMenu.pageAI.currentJobTypes) do 
        local job = inGameMenu.pageAI.jobTypeInstances[index]
        if job:isa(AIJobFieldWorkCp) then 
            if not vehicle:hasCpCourse() then 
                -- Sets the start position relative to the vehicle position, but only if no course is set.
                job:resetStartPositionAngle(vehicle)
                job:setValues()
                local x, z, rot = job:getTarget()
                inGameMenu.pageAI.aiTargetMapHotspot:setWorldPosition(x, z)
                if rot ~= nil then
                    inGameMenu.pageAI.aiTargetMapHotspot:setWorldRotation(rot + math.pi)
                end

            end
            inGameMenu.pageAI:setActiveJobTypeSelection(index)
            break
        end
    end
    inGameMenu.pageAI:onClickOpenCloseCourseGenerator()
end

function CourseplayHud:openVehicleSettingsGui(vehicle)
    local inGameMenu = self:preOpeningInGameMenu(vehicle)
    local vehiclePageIx = inGameMenu.pagingElement:getPageMappingIndexByElement(inGameMenu.pageCpVehicleSettings)
    inGameMenu.pageSelector:setState(vehiclePageIx, true)
end

function CourseplayHud:openGlobalSettingsGui(vehicle)
    local inGameMenu = self:preOpeningInGameMenu(vehicle)
    local pageIx = inGameMenu.pagingElement:getPageMappingIndexByElement(inGameMenu.pageCpGlobalSettings)
    inGameMenu.pageSelector:setState(pageIx, true)
end
--[[
This file is part of Courseplay (https://github.com/Courseplay/courseplay)
Copyright (C) 2021 Peter Vaiko

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
]]


--- Parameters of a Courseplay job
---@class CpJobParameters
CpJobParameters = CpObject()

local filePath = Utils.getFilename("config/JobParameterSetup.xml", g_Courseplay.BASE_DIRECTORY)

function CpJobParameters:init(job)
    if not CpJobParameters.settings then
        -- initialize the class members first so the class can be used to access constants, etc.
        CpSettingsUtil.loadSettingsFromSetup(CpJobParameters, filePath)
    end
    CpSettingsUtil.cloneSettingsTable(self,CpJobParameters.settings,nil,self)
    self.job = job
end

function CpJobParameters.getSettings(vehicle)
    return vehicle.spec_cpAIFieldWorker.cpJob:getCpJobParameters()
end

function CpJobParameters:validateSettings()
    for i,setting in ipairs(self.settings) do 
        setting:refresh()
    end
end

function CpJobParameters:isBaleFinderNotAllowed()
    local vehicle = self.job:getVehicle()
    if vehicle then
        local hasValidImplement = AIUtil.hasImplementWithSpecialization(vehicle, BaleWrapper) or
                                AIUtil.hasImplementWithSpecialization(vehicle, BaleLoader)
        return not hasValidImplement
    end
end

function CpJobParameters:getNumberOfMultiTools()
    local vehicle = self.job:getVehicle()
    if vehicle then 
        local course = vehicle:getFieldWorkCourse()
        if course then 
            return course:getNumberOfMultiTools() or 1
        end
    end
    return 1
end

function CpJobParameters:noMultiToolsCourseSelected()
    return self:getNumberOfMultiTools() <= 1
end

function CpJobParameters:evenNumberOfMultiTools()
    return self:getNumberOfMultiTools() %2 == 0
end

function CpJobParameters:lessThanThreeMultiTools()
    return self:getNumberOfMultiTools() < 4
end

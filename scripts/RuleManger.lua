
RuleManager = {
	RULES = {
		HELPER_LIMIT = 1,
		LEASE_VEHICLES = 2,
	},
	LEASE_VEHICLES = {
		DISABLED = 0,
		ONLY_SHOP_VEHICLES = 1,
		ENABLED = 2
	},
	NUM_CATEGORIES = 2,
	CONFIG_CATEGORIES = {
		"GeneralRules",
		"MissionRules"
	},
	CATEGORIES = {
		GENERAL = 1,
		MISSION = 2
	}
}
local RuleManager_mt = Class(RuleManager)
---@class RuleManager
function RuleManager.new(custom_mt)
	local self = setmetatable({}, custom_mt or RuleManager_mt)
	self.isServer = g_server
		
	self.ruleList = {}

	self.missionTypes = {}
	for i, missionType in pairs(g_missionManager.missionTypes) do 
		self.missionTypes[missionType.name] = missionType
	end
	return self
end


function RuleManager:registerXmlSchema(xmlSchema, baseXmlKey)
	ScoreBoardList.registerXmlSchema(xmlSchema, baseXmlKey .. ".Rules")
end

function RuleManager:registerConfigXmlSchema(xmlSchema, baseXmlKey)
	CmUtil.registerConfigXmlSchema(xmlSchema, baseXmlKey .. ".Rules")
end

function RuleManager:loadConfigData(xmlFile, baseXmlKey)
		
	self.configData, self.titles = CmUtil.loadConfigCategories(xmlFile, baseXmlKey .. ".Rules")

	self.ruleList = ScoreBoardList.new("rules", self.titles)
	for _, categoryData in pairs(self.configData) do 
		local category = ScoreBoardCategory.new(categoryData.name, categoryData.title)
		for _, rule in pairs(categoryData.elements) do 
			if rule.genericFunc == nil then
				category:addElement(Rule.createFromXml(rule))
			else 
				self[rule.genericFunc](self, category, rule)
			end
		end
		self.ruleList:addElement(category)
	end
end

function RuleManager:saveToXMLFile(xmlFile, baseXmlKey)
	self.ruleList:saveToXMLFile(xmlFile, baseXmlKey .. ".Rules", 0)
end

function RuleManager:loadFromXMLFile(xmlFile, baseXmlKey)
	ScoreBoardList.loadFromXMLFile(self, xmlFile, baseXmlKey .. ".Rules")
end

function RuleManager:addMissionRules(category, ruleData)
	local missionNames = table.toList(self.missionTypes)
	table.sort(missionNames)
	for _, name in ipairs(missionNames) do 
		ruleData.name = name
		ruleData.title = name
		category:addElement(Rule.createFromXml(ruleData))
	end
end

function RuleManager:getList()
	return self.ruleList
end

function RuleManager:getListByName()
	return self.ruleList
end

g_ruleManager = RuleManager.new()
--missionTypes
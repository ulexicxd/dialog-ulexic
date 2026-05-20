local Packages = script.Parent:WaitForChild("Packages")
local Signal = require(Packages:WaitForChild("Signal")) -- path to signal

local Dialog = {}
Dialog.__index = Dialog

export type DialogPoint = {
	Text: string,
	Choices: { { Text: string, NextIndex: string? } }?,
	OnReached: (() -> ())?,
}

function Dialog.new(startingIndex: string)
	local self = setmetatable({}, Dialog)

	self.DialogPoints = {} :: { [string]: DialogPoint }
	self.CurrentIndex = startingIndex
	self.Signals = {
		OnChoiceChosen = Signal.new(),
		OnDialogReached = Signal.new(),
	}

	return self
end

function Dialog:CreateDialogPoint(pointIndex: string, pointData: DialogPoint)
	self.DialogPoints[pointIndex] = pointData
end

function Dialog:Advance()
	local point: DialogPoint = self.DialogPoints[self.CurrentIndex]
	if not point then return end

	if point.OnReached then
		point.OnReached()
	end

	self.Signals.OnDialogReached:Fire(self.CurrentIndex, point)
end

function Dialog:Choose(choiceIndex: number)
	local point: DialogPoint = self.DialogPoints[self.CurrentIndex]
	if not point or not point.Choices then return end

	local choice = point.Choices[choiceIndex]
	if not choice then return end

	self.Signals.OnChoiceChosen:Fire(choiceIndex, choice.Text)

	if choice.NextIndex then
		self:Skip(choice.NextIndex)
		self:Advance()
	end
end

function Dialog:Skip(skippingIndex: string)
	self.CurrentIndex = skippingIndex
end

function Dialog:GetCurrentPoint(): DialogPoint?
	return self.DialogPoints[self.CurrentIndex]
end

function Dialog:Destroy()
	for _, signal in pairs(self.Signals) do
		signal:Destroy()
	end
	self.DialogPoints = {}
end

return Dialog
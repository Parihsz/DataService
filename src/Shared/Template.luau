local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Data = require(ReplicatedStorage.Shared.Data)

type Field<T> = Data.Field<T>

type Race =
	"Tusken"
	| "Twi'lek"
	| "Human"
	| "Rodian"
	| "Geonosian"
	| "Chiss"
	| "Togruta"
	| "Trandoshan"
	| "Zabrak"
	| "Tridactyl"
	| "Gungan"
type CrateType = "1" | "2" | "3" | "4" | "5"
type Tier = string
type SkillTreeKey = string
type SavedKeybind = { main: string }
type DataInputs = { [string]: SavedKeybind? }
type Mission = { progress: number }
type Build = {
	SPAllocation: { [SkillTreeKey]: number? },
	weapon: string,
	form: string,
	kyberColor: string?,
	hilt: string?,
	slot1: string?,
	slot2: string?,
	slot3: string?,
	slot4: string?,
	slot5: string?,
	slot6: string?,
	slot7: string?,
	slot8: string?,
}

local u8 = Data.u8
local u16 = Data.u16
local u32 = Data.u32
local i8 = Data.i8
local i16 = Data.i16
local i32 = Data.i32
local f16 = Data.f16
local f32 = Data.f32
local f64 = Data.f64
local vector = Data.vector
local str = Data.string
local boolean = Data.boolean
local cframe = Data.CFrame

export type Data = {
	firstTime: Field<boolean>,

	xp: Field<number>,
	requiredXp: Field<number>,
	level: Field<number>,

	alignment: Field<string>,
	gender: Field<string>,

	racial: {
		race: Field<string>,
	},
	raceSpins: Field<number>,

	appearance: {
		headVariant: Field<string>?,
		face: {
			eye: Field<string>,
			irisHex: Field<string>?,
			mouth: Field<string>,
			extra: Field<string>?,
		}?,
		clothing: Field<string>?,
	},

	crates: { [CrateType]: Field<number> },

	keybinds: { [string]: Field<SavedKeybind> },
	credits: Field<number>,

	selectedBuild: Field<number>,
	builds: { [number]: Field<Build> },

	skillTiers: { [SkillTreeKey]: Field<string> },
	settings: {
		wSprint: Field<boolean>,
	},
	unlockedSkills: { [string]: Field<boolean> },
	missions: { [string]: Field<Mission> },

	days: { [Race]: Field<number> },
}

local dataTemplate: Data = {
	firstTime = boolean("Private", true),

	xp = f32("Private", 0),
	requiredXp = f32("Private", 100),
	level = u32("Private", 1),

	alignment = str("Private", "Jedi"),
	gender = str("Private", "Male"),

	racial = {
		race = str("Private", "Human"),
	},
	raceSpins = u8("Private", 3),

	appearance = {
		headVariant = str("Private", "default"),
		face = {
			eye = str("Private", "default"),
			irisHex = str("Private", "#000000"),
			mouth = str("Private", "default"),
			extra = str("Private", ""),
		},
		clothing = str("Private", "default"),
	},

	crates = {
		["1"] = u32("Private", 0),
		["2"] = u32("Private", 0),
		["3"] = u32("Private", 0),
		["4"] = u32("Private", 0),
		["5"] = u32("Private", 0),
	},

	keybinds = {},
	credits = i32("Private", 0),

	selectedBuild = u32("Private", 0),
	builds = {},

	skillTiers = {},

	settings = {
		wSprint = boolean("Private", true),
	},

	unlockedSkills = {},
	missions = {},

	days = {},
}

return dataTemplate

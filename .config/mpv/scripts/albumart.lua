local mp = require("mp")
local msg = require("mp.msg")
local opt = require("mp.options")

local options = {
	auto = true,
	profile = "music",
	undo_profile = "",
	enable = false,
	cover_path = "~/.config/mpv/albumart.jpg",
	font_size = "24",
	font_color = "#fafafa",
	ignore_embedded_cover = false,
}

opt.read_options(options, "musicmode")
msg.info("musicmode options loaded")

local musicMode = false
local temp_cover_path = "/tmp/mpv_music_cover.jpg"

local function get_metadata()
	local metadata = mp.get_property_native("metadata") or {}
	local info = {
		title = mp.get_property("media-title") or mp.get_property("filename"),
		artist = metadata.artist or "Unknown Artist",
		album = metadata.album or "Unknown Album",
		date = metadata.date or "",
		genre = metadata.genre or "",
		track = metadata.track or "",
	}
	msg.info(string.format("metadata fetched: %s - %s", info.artist, info.title))
	return info
end

local function create_cover_with_info()
	local info = get_metadata()
	local cover_path = mp.command_native({ "expand-path", options.cover_path })
	msg.info("creating cover with info")

	local texts = {}
	table.insert(texts, string.format('"%s"', info.title))
	table.insert(texts, string.format("by %s", info.artist))
	table.insert(texts, string.format("Album: %s", info.album))

	local magick_cmd = { "magick", cover_path }
	table.insert(magick_cmd, "-fill")
	table.insert(magick_cmd, options.font_color)
	table.insert(magick_cmd, "-pointsize")
	table.insert(magick_cmd, options.font_size)
	table.insert(magick_cmd, "-font")
	table.insert(magick_cmd, "Source-Han-Serif-CN")

	for i, text in ipairs(texts) do
		table.insert(magick_cmd, "-draw")
		table.insert(magick_cmd, string.format("text 64,%d '%s'", 192 + (i - 1) * 35, text))
	end
	table.insert(magick_cmd, temp_cover_path)

	msg.info(string.format("executing imagemagick command: %s", table.concat(magick_cmd, " ")))

	local result = mp.command_native({
		name = "subprocess",
		args = magick_cmd,
		capture_stdout = true,
		capture_stderr = true,
	})

	if result.status ~= 0 then
		msg.error(string.format("imagemagick failed: %s", result.stderr))
	end

	return result.status == 0
end

local function loadCoverWithInfo()
	msg.info("loading cover with info")
	if create_cover_with_info() then
		msg.info("using generated cover with info")
		mp.commandv("video-add", temp_cover_path, "select")
	else
		msg.info("falling back to plain cover")
		mp.commandv("video-add", mp.command_native({ "expand-path", options.cover_path }), "select")
	end
end

local function is_audio_file()
	if mp.get_property("track-list/0/type") == "audio" then
		return true
	elseif mp.get_property("track-list/0/albumart") == "yes" then
		return true
	end
	return false
end

local function shouldUsePresetCover()
	if not is_audio_file() then
		return false
	end
	if options.ignore_embedded_cover then
		return true
	else
		local tracks = mp.get_property_native("track-list")
		for _, track in ipairs(tracks) do
			if track.type == "video" then
				return false
			end
		end
		return true
	end
end

local function toggle_music_mode()
	if musicMode then
		msg.info("deactivating music mode")
		if options.undo_profile ~= "" then
			mp.commandv("apply-profile", options.undo_profile)
		end
		mp.osd_message("Music Mode disabled")
	else
		msg.info("activating music mode")
		if options.profile ~= "" then
			mp.commandv("apply-profile", options.profile)
		end
		mp.osd_message("Music Mode enabled")
	end

	musicMode = not musicMode
	mp.set_property_bool("user-data/music_mode/active", musicMode)

	if musicMode and shouldUsePresetCover() then
		mp.add_timeout(0.1, loadCoverWithInfo)
	end
end

local function file_loaded()
	if shouldUsePresetCover() then
		if options.auto and not musicMode then
			toggle_music_mode()
		end
		if musicMode then
			loadCoverWithInfo()
		end
	elseif musicMode and options.undo_profile ~= "" then
		toggle_music_mode()
	end
end

if options.enable then
	toggle_music_mode()
end

mp.register_event("file-loaded", file_loaded)

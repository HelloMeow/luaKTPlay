local M = {}

local json = require "cjson"

local luaj = require "cocos.cocos2d.luaj"

local __call = function(classname, methodname, paras, sig)
	local ok, ret = luaj.callStaticMethod(classname, methodname, paras, sig)
	if ok then return ret end
	print(string.format("Execute [%s][%s] error:%s", classname, methodname, ret))
	return nil
end

-- Classes
local ClsKTPlayBridge     = "org/cocos2dx/lua/KTPlayBridge" -- change to the real path
local ClsKTPlay           = "com/ktplay/open/KTPlay"
local ClsKTAccountManager = "com/ktplay/open/KTAccountManager"

-- functions
function M.show()
	__call(ClsKTPlay, 'show', nil)
end

function M.isEnabled()
	return __call(ClsKTPlay, 'isEnabled', nil)
end

function M.isLoggedIn()
	return __call(ClsKTAccountManager, 'isLoggedIn', {}, "()Z")
end

function M.showLoginView(closable, cb_ok, cb_fail)
	cb_ok = cb_ok or function()end
	cb_fail = cb_fail or function()end

	local cb_wok = function(user_str)
		cb_ok(json.decode(user_str))
	end

	__call(ClsKTPlayBridge, 'showLoginView', {closable, cb_wok, cb_fail})
end

function M.reportScore(score, leaderboardId, cb_ok, cb_fail)
	assert(leaderboardId)

	cb_ok = cb_ok or 0
	cb_fail = cb_fail or 0

	__call(ClsKTPlayBridge, 'reportScore',
		{score, leaderboardId, cb_ok, cb_fail}, "(FLjava/lang/String;II)V")
end

function M.globalLeaderboard(leaderboardId, startIndex, count, cb_ok, cb_fail)
	assert(leaderboardId)
	assert(startIndex>=0)
	assert(count>0)

	cb_ok = cb_ok or function()end
	local cb_wok = function(leaderboard_str)
		cb_ok(json.decode(leaderboard_str))
	end

	__call(ClsKTPlayBridge, 'globalLeaderboard',
		{startIndex, count, leaderboardId, cb_wok, cb_fail},
		"(FFLjava/lang/String;II)V")
end

function M.setLoginStatusChangedCallback(cb_login, cb_logout)
	cb_login  = cb_login or function()end
	cb_logout = cb_logout or function()end

	local wcb_login = function(user_str)
		if cb_login then cb_login(json.decode(user_str)) end
	end

	local wcb_logout = function(user_str)
		if cb_logout then cb_logout(json.decode(user_str)) end
	end

	__call(ClsKTPlayBridge, 'setLoginStatusChangedCallback',
		{wcb_login, wcb_logout})
end

function M.currentAccount(cb)
	local wcb = function(user_str)
		local user = json.decode(user_str)
		if user then
			CurUser:setKTPlayUserId(user.userId)
		end
		if cb then cb(user) end
	end
	if M.isLoggedIn() then
		__call(ClsKTPlayBridge, 'currentAccount', {wcb}, "(I)V")
	end
end

function M.setDidDispatchRewardCallback(cb)
	local wcb = function(reward_dict_str)
		if cb then cb(json.decode(reward_dict_str)) end
	end
	__call(ClsKTPlayBridge, 'setDidDispatchRewardBlock', {wcb}, "(I)V")
end

function M.setOnNewActivityStatusChangedCallback(cb)
	local wcb = function(hasNewActivity)
		if cb then cb(hasNewActivity == "1" and true or false) end
	end
	__call(ClsKTPlayBridge, 'setOnNewActivityStatusChangedCallback', {wcb}, "(I)V")
end

function M.showRedemptionView()
	__call(ClsKTPlay, 'showRedemptionView')
end

return M

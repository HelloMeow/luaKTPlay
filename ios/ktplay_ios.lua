local M = {}

local luaoc = require "cocos.cocos2d.luaoc"
local __call = function(classname, methodname, paras)
	local ok, ret = luaoc.callStaticMethod(classname, methodname, paras)
	if ok then return ret end
	print(string.format("Execute [%s][%s] error:%s", classname, methodname, ret))
	return nil
end

-- Classes
local ClsKTPlayBridge     = "KTPlayBridge"
local ClsKTPlay           = "KTPlay"
local ClsKTAccountManager = "KTAccountManager"

-- functions
function M.show()
	__call(ClsKTPlay, 'show', nil)
end

function M.isEnabled()
	return __call(ClsKTPlay, 'isEnabled', nil)
end

function M.isLoggedIn()
	return __call(ClsKTAccountManager, 'isLoggedIn', nil)
end

function M.showLoginView(closable, cb_ok, cb_fail)
	cb_ok = cb_ok or function()end
	cb_fail = cb_fail or function()end

	__call(ClsKTPlayBridge, 'showLoginView',
		{
		closable = closable,
		cb_ok    = cb_ok,
		cb_fail  = cb_fail,
	})
end

function M.reportScore(score, leaderboardId, cb_ok, cb_fail)
	assert(leaderboardId)

	cb_ok = cb_ok or function()end
	cb_fail = cb_fail or function()end

	__call(ClsKTPlayBridge, 'reportScore', {
		score         = score,
		leaderboardId = leaderboardId,
		cb_ok         = cb_ok,
		cb_fail       = cb_fail,
		})
end

function M.globalLeaderboard(leaderboardId, startIndex, count, cb_ok, cb_fail)
	assert(leaderboardId)
	assert(startIndex>=0)
	assert(count>0)

	cb_ok = cb_ok or function()end
	cb_fail = cb_fail or function()end

	__call(ClsKTPlayBridge, 'globalLeaderboard', {
		startIndex    = startIndex,
		count         = count,
		leaderboardId = leaderboardId,
		cb_ok         = cb_ok,
		cb_fail       = cb_fail,
		})
end

function M.setLoginStatusChangedCallback(cb_login, cb_logout)
	cb_login  = cb_login or function()end
	cb_logout = cb_logout or function()end

	__call(ClsKTPlayBridge, 'setLoginStatusChangedBlock', {
		cb_login  = cb_login,
		cb_logout = cb_logout
		})
end

function M.currentAccount(cb)
	wcb = function(user)
		if user then
			CurUser:setKTPlayUserId(user.userId)
		end
		if cb then cb(user) end
	end
	if M.isLoggedIn() then
		__call(ClsKTPlayBridge, 'currentAccount', {cb = wcb})
	end
end

function M.setDidDispatchRewardCallback(cb)
	cb = cb or function()end
	__call(ClsKTPlayBridge, 'setDidDispatchRewardBlock', {cb  = cb})
end

function M.setOnNewActivityStatusChangedCallback(cb)
	cb = cb or function()end
	__call(ClsKTPlayBridge, 'setOnNewActivityStatusChangedCallback', {cb  = cb})
end

return M

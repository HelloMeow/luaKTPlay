package org.cocos2dx.lua;

import com.ktplay.open.KTAccountManager;
import com.ktplay.open.KTError;
import com.ktplay.open.KTLeaderboard;
import com.ktplay.open.KTLeaderboardPaginator;
import com.ktplay.open.KTPlay;
import com.ktplay.open.KTUser;

import org.cocos2dx.lib.Cocos2dxHelper;
import org.cocos2dx.lib.Cocos2dxLuaJavaBridge;

import java.util.HashMap;

/**
 * Created by HelloMeowLab on 5/8/16.
 */
public class KTPlayBridge {

    public static HashMap cbOs = new HashMap();
    public static HashMap cbXs = new HashMap();

    protected static void _setCbOk(String key, int cb) {
        if (KTPlayBridge.cbOs.get(key) != null) {
            int old_cb = (int) KTPlayBridge.cbOs.get(key);
            Cocos2dxLuaJavaBridge.releaseLuaFunction(old_cb);
            KTPlayBridge.cbOs.remove(key);
        }
        KTPlayBridge.cbOs.put(key, cb);
    }

    protected static void _setCbFail(String key, int cb) {
        if (KTPlayBridge.cbXs.get(key) != null) {
            int old_cb = (int) KTPlayBridge.cbXs.get(key);
            Cocos2dxLuaJavaBridge.releaseLuaFunction(old_cb);
            KTPlayBridge.cbXs.remove(key);
        }
        KTPlayBridge.cbXs.put(key, cb);
    }

    protected static void _callOk(String key, String data, boolean removeAfterCall){
        if (KTPlayBridge.cbOs.get(key) != null) {
            int cb = (int) KTPlayBridge.cbOs.get(key);
            if (cb != 0) {
                Cocos2dxLuaJavaBridge.callLuaFunctionWithString(cb, data);
                if (removeAfterCall) {
                    Cocos2dxLuaJavaBridge.releaseLuaFunction(cb);
                    KTPlayBridge.cbOs.remove(key);
                }
            }
        }
    }

    protected static void _callFail(String key, String data, boolean removeAfterCall){
        if (KTPlayBridge.cbXs.get(key) != null) {
            int cb = (int) KTPlayBridge.cbXs.get(key);
            if (cb != 0) {
                Cocos2dxLuaJavaBridge.callLuaFunctionWithString(cb, data);
                if (removeAfterCall) {
                    Cocos2dxLuaJavaBridge.releaseLuaFunction(cb);
                    KTPlayBridge.cbXs.remove(key);
                }
            }
        }
    }

    // ---
    public static void showLoginView(final boolean closable, final int cb_ok, final int cb_fail) {
        KTPlayBridge._setCbOk("loginViewCb", cb_ok);
        KTPlayBridge._setCbFail("loginViewCb", cb_fail);

        KTAccountManager.showLoginView(closable, new KTAccountManager.KTLoginListener(){
            @Override
            public void onLoginResult(boolean isSuccess, KTUser user, KTError error) {
                if(isSuccess){
                    // ok
                    KTPlayBridge._callOk("loginViewCb", KTPlayConversion.jsonWithKTUser(user).toString(), true);
                }else{
                    // fail
                    KTPlayBridge._callFail("loginViewCb", "failed", true);
                }
            }
        });
    }

    public static void globalLeaderboard(final float startIndex,
                                         final float count,
                                         final String leaderboardId,
                                         final int cb_ok,
                                         final int cb_fail) {
        KTPlayBridge._setCbOk(leaderboardId, cb_ok);
        KTPlayBridge._setCbFail(leaderboardId, cb_fail);

        KTLeaderboard.globalLeaderboard(leaderboardId, (int)startIndex, (int)count,
            new KTLeaderboard.OnGetLeaderboardListener(){
                @Override
                public void onGetLeaderboardResult(final boolean isSuccess,
                                                   final String leaderboardId,
                                                   final KTLeaderboardPaginator leaderboard,
                                                   KTError error) {
                    // 必须要用runOnGLThread否则UI不正常甚至crash
                    Cocos2dxHelper.runOnGLThread(
                        new Runnable() {
                            @Override
                            public void run() {
                                if (isSuccess) {
                                    String data = KTPlayConversion.jsonWithKTLeaderboardPaginator(leaderboard).toString();
                                    KTPlayBridge._callOk(leaderboardId, data, true);
                                } else {
                                    KTPlayBridge._callFail(leaderboardId, "获取排行榜失败", true);
                                }
                            }
                        }
                    );
                }
            });
    }

    public static void reportScore(final float score,
                                   final String leaderboardId,
                                   final int cb_ok,
                                   final int cb_fail)
    {
        KTPlayBridge._setCbOk(leaderboardId, cb_ok);
        KTPlayBridge._setCbFail(leaderboardId, cb_fail);

        KTLeaderboard.reportScore((long) score, leaderboardId, "default", new KTLeaderboard.OnReportScoreListener() {
            @Override
            public void onReportScoreResult(boolean isSuccess,
                                            String leaderboardId,
                                            long score,
                                            String scoreTag,
                                            KTError error) {
                if(isSuccess){
                    // ok
                    KTPlayBridge._callOk(leaderboardId, "OK", true);
                }else{
                    // fail
                    KTPlayBridge._callFail(leaderboardId, error.toString(), true);
                }
            }
        });
    }

    public static void setLoginStatusChangedCallback(final int cb_login, final int cb_logout) {
        KTPlayBridge._setCbOk("loginCb", cb_login);
        KTPlayBridge._setCbOk("logoutCb", cb_logout);

        KTAccountManager.OnLoginStatusChangedListener l = new KTAccountManager.OnLoginStatusChangedListener(){
            public void onLoginStatusChanged(boolean isLoggedIn, KTUser user){
                if (isLoggedIn) {
                    String data = KTPlayConversion.jsonWithKTUser(user).toString();
                    KTPlayBridge._callOk("loginCb", data, false);
                }else {
                    KTPlayBridge._callOk("logoutCb", "logout", false);
                }
            }
        };

        KTAccountManager.setLoginStatusChangedListener(l);
    }

    public static void currentAccount(final int cb){
        KTPlayBridge._setCbOk("currentAccountCb", cb);

        KTUser user = KTAccountManager.currentAccount();
        String user_str = "";
        if (user != null) {
            user_str = KTPlayConversion.jsonWithKTUser(user).toString();
        }

        KTPlayBridge._callOk("currentAccountCb", user_str, true);
    }

    public static void setDidDispatchRewardBlock(final int cb) {
        KTPlayBridge._setCbOk("rewardCb", cb);

        KTPlay.setOnDispatchRewardsListener(new KTPlay.OnDispatchRewardsListener() {
            @Override
            public void onDispatchRewards(KTPlay.Reward reward) {
                String data = KTPlayConversion.jsonWithKTRewardArray(reward.items).toString();
                KTPlayBridge._callOk("rewardCb", data, false);
            }
        });
    }

    public static void setOnNewActivityStatusChangedCallback(final int cb) {
        KTPlayBridge._setCbOk("ActivityCb", cb);

        KTPlay.setOnActivityStatusChangedListener(new KTPlay.OnActivityStatusChangedListener() {
            @Override
            public void onActivityChanged(final boolean hasNewActivity) {
                Cocos2dxHelper.runOnGLThread(
                    new Runnable() {
                        @Override
                        public void run() {
                            String data = hasNewActivity ? "1" : "0";
                            KTPlayBridge._callOk("ActivityCb", data, false);
                        }
                    }
                );
            }
        });
    }
}

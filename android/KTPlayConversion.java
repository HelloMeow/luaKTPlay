package org.cocos2dx.lua;

import com.ktplay.open.KTLeaderboardPaginator;
import com.ktplay.open.KTRewardItem;
import com.ktplay.open.KTUser;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.json.JSONStringer;

import java.util.ArrayList;
import java.util.jar.Pack200;


/**
 * Created by HelloMeowLab on 5/8/16.
 */
public class KTPlayConversion {

    public static JSONObject jsonWithKTUser(KTUser user) {
        JSONObject o = new JSONObject();
        try {
            o.put("userId", user.getUserId());
            o.put("headerUrl", user.getHeaderUrl());
            o.put("nickname", user.getNickname());
            o.put("gender", user.getGender());
            o.put("city", user.getCity());
            o.put("score", user.getScore());
            o.put("birthday", user.getBirthday());
            o.put("rank", user.getRank());
            o.put("scoreTag", user.getScoreTag());
            o.put("originScore", user.getOriginScore());
            o.put("loginType", user.getLoginType());
            o.put("gameUserId", user.getGameUserId());
            o.put("needPresentNickname", user.getNeedPresentNickname());
        } catch (JSONException e) {
            e.printStackTrace();
        }
        return o;
    }

    public static JSONStringer jsonWithKTLeaderboardPaginator(KTLeaderboardPaginator leaderboard) {
        JSONStringer o = new JSONStringer();

        try {
            o.object();

            // add properties
            o.key("total");o.value(leaderboard.getTotal());
            o.key("nextCursor");o.value(leaderboard.getNextCursor());
            o.key("previousCursor");o.value(leaderboard.getPreviousCursor());
            o.key("itemCount");o.value(leaderboard.getItemCount());
            o.key("leaderboardName");o.value(leaderboard.getLeaderboardName());
            o.key("leaderboardIcon");o.value(leaderboard.getLeaderboardIcon());
            o.key("leaderboardId");o.value(leaderboard.getLeaderboardId());
            o.key("myRank");o.value(leaderboard.getMyRank());
            o.key("myScore");o.value(leaderboard.getMyScore());
            o.key("myScoreTag");o.value(leaderboard.getMyScoreTag());
            o.key("myOriginScore");o.value(leaderboard.getMyOriginScore());
            o.key("periodicalSummaryId");o.value(leaderboard.getPeriodicalSummaryId());

            // add users
            JSONArray a = new JSONArray();
            for (KTUser user : leaderboard.getUsers()) {
                a.put(jsonWithKTUser(user));
            }
            o.key("items");o.value(a);

            o.endObject();
        } catch (JSONException e) {
            e.printStackTrace();
        }

        return o;
    }

    public static JSONStringer jsonWithKTRewardArray(ArrayList<KTRewardItem> rewards) {
        JSONStringer o = new JSONStringer();

        try {
            o.object();

            for(KTRewardItem reward : rewards) {
                o.key(reward.getTypeId());
                o.value(reward.getValue());
            }

            o.endObject();

        } catch (JSONException e) {
            e.printStackTrace();
        }

        return o;
    }
}

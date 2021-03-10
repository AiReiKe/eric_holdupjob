Config = {}
Config.Locale = 'tw'

Config.Marker = {
	r = 250, g = 0, b = 0, a = 100,
	x = 1.0, y = 1.0, z = 1.5,
	DrawDistance = 15.0, Type = 1
}

Config.PoliceNumberRequired = 2 --若 call_police 為 true 時, 所需在線警察數
Config.TimerBeforeNewRob    = 600 -- 搶劫完成/取消後的冷卻時間計時器（以秒為單位）
Config.MaxDistance    = 20   -- 與搶劫光圈能離的最大距離，再更遠將取消搶劫

Config.NegativeSociety = false --公庫沒錢時是否能繼續搶
Config.member_holdup = false	--是否允許該公職成員搶自家公庫

Config.GiveBlackMoney = false -- 是否給黑錢？如果false，它將提供現金

Stores = {
	["mafia"] = {
		position = { x = 28.16, y = 537.8, z = 176.02 },
		reward = math.random(1000000, 2000000), --可搶到金額
		nameOfJob = "黑豹會",
		secondsRemaining = 180, -- 觸發到拿到錢過多久，單位: seconds
		lastRobbed = 0,
		job = 'mafia',
		online_player = 0, --所需在線成員數量
		call_police = false, --是否通知警察
		blip = true --地圖上是否顯示
	},

}

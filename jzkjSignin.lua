--需要库
local json = require "dkjson"
local http = require "socket.http"

local process = require "environ.process"

local JZKJ_KEY = process.getenv('jzkjk')
local PUSH_KEY = process.getenv('token')

--     【【  _key  ,token
--[[
	提示：

	芥子空间 【Key值 】请手动获取

	手机选择验证码登陆，然后将获取到的信息输入到网页

	【https://api.bbs.lieyou888.com/user/phone/login/ANDROID/1.1?phone=手机号&vcode=验证码】

	]]

--板块查询
local ID_check_url = "https://api.bbs.lieyou888.com/category/list/ANDROID/1.0"
--板块签到
local signin_url = "https://api.bbs.lieyou888.com/user/signin/ANDROID/1.0?_key="
--云挂机签到
local cloud_signin_url = "https://api.lieyou888.com/signin/create/ANDROID/1.0?_key="
--云挂机信息查询
local cloud_check = "https://api.lieyou888.com/signin/list/ANDROID/1.0?_key="

function all(method,URL,request_body)
  local response_body = {}
  local res, code, response_headers = http.request
   {
      url = URL,
      method = method,
      headers =
        {
            ["Content-Type"] = "application/json; charset=UTF-8";
			["Content-Length"] = #request_body;
        },
		source = ltn12.source.string(request_body),
        sink = ltn12.sink.table(response_body),
   }
  if type(response_body) == "table" then
    backa = table.concat(response_body)   --返回值backa
	return backa
	end
end

function JZKJ_Signin()
local xw = os.clock()
all("GET",signin_url..JZKJ_KEY.."&cat_id="..1,"")
if string.match(backa,"未登录") == "未登录" then  --如果KEY值不可用
	print("KEY错误，请先登录")
	myjzkj:write("KEY错误，请手动替换key值")
else
--KEY值可用

local header =[[
【芥子空间签到脚本已运行！】

---

详细信息如下：

板块id | 板块名称
:--|:--
]]
	myjzkj:write(header)
	all("GET",cloud_signin_url..JZKJ_KEY,"")     --云挂机签到
	all("GET",ID_check_url,"")
	ID_check_back = json.decode(backa)
	local number = 0
for i, w in ipairs(ID_check_back.categories) do
 number = number + 1
	--print(w.categoryID.." | " .. w.title)
	myjzkj:write(w.categoryID.." | " .. w.title.."\n")
	all("GET",signin_url..JZKJ_KEY.."&cat_id="..w.categoryID,"")  --板块签到
end
all("GET",cloud_check..JZKJ_KEY,"")
local cloudb = json.decode(backa)
	myjzkj:write("  \n> 签到板块数:"..number.."\n\n---\n\n")
	myjzkj:write("  \n云挂机 :")
	myjzkj:write("\n - "..cloudb.rewardTip)
	myjzkj:write("\n - 连续签到` "..cloudb.continuousDays.." `天")
	myjzkj:write("\n - 补签卡` "..cloudb.compensationDays.." `张")
end

    local s = 0
	for i=1,10^7 do s = s + i end
	myjzkj:write(string.format("  \n\n脚本运行完成，耗时:` %.2f `秒\n", os.clock() - xw))
	local date=os.date("%Y-%m-%d %H:%M:%S");
	myjzkj:write("  \n > 时间 : ".. date)
end

function main()

myjzkj = io.tmpfile()
	JZKJ_Signin()
myjzkj:seek("set")
content = myjzkj:read("*a")
myjzkj:close()

print(content)
local a = {}
	a["token"] = PUSH_KEY
	a["title"] = "【芥子空间签到】"
	a["content"] = content
	a["template"] = "markdown"
local PUSHP = json.encode(a)

all("POST","http://www.pushplus.plus/send",PUSHP)
print(backa)
end

main()



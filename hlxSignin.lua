--需要库
local json = require "dkjson"
local http = require "socket.http"
--设置你的参数
local process = require "environ.process"

local HLX_KEY = process.getenv('hlxk')
local PUSH_KEY = process.getenv('token')

local bk = 160
--[[说明：key为key值，token 为微信公众号 pushplus推送加 的 token 用于签到完成后推送，可不填，bk不用修改]]
--------------------------------------------------------------------------------------------------------------

local signurl = "http://floor.huluxia.com/user/signin/ANDROID/4.0?market_id=floor_baidu&_key="
local catidurl = 'http://floor.huluxia.com/category/detail/ANDROID/2.0?cat_id='

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

function Signin()		--签到

all("GET",signurl..HLX_KEY.."&cat_id="..1,"")
if string.match(backa,"未登录") == "未登录" then
myhlx:write("  \n【Key值】错误，请及时更改 ")
else
local header = [[
##### 每日签到推送

---
【脚本已运行！】
###### 详细签到内容如下：
板块id|板块名称|获得经验|连签天数
:-:|:--|:-:|:-:
]]
	myhlx:write(header)
	a ,b ,c = 0 , 0 , 0
  while(a<bk)
   do
	a=a+1    --print("cat_id:",a)

	all("GET",signurl..HLX_KEY.."&cat_id="..a,"")
	local aqa = json.decode(backa)
	msg = aqa.msg
	nologin = string.match(msg,'未登录' )
	noe = string.match(msg,'不存在')
	if (msg == nologin) then     --未登录
		print('请登录')
	elseif (msg == noe) then    --板块不存在
		print('板块不存在')
	elseif (msg == "") then     --存在板块
		backa = nil
		all("GET",catidurl..a,"")     ---板块查询
		bdd = json.decode(backa)
			if bdd.msg =="" then
				myhlx:write(a.."|"..bdd.title.."|"..aqa.experienceVal.."|"..aqa.continueDays.."\n")
			else
				myhlx:write(a.."|☑☑☑|"..aqa.experienceVal.."|"..aqa.continueDays.."\n")       --板块查询为：分类不存在，但是签到有经验
				c = c + 1
			end
		b =b + 1
		local cot = 0
		exp = aqa.experienceVal
		exp = cot+exp
	end

		if(a == bk) then
			myhlx:write("\n---")
			myhlx:write("  \n共签到` "..b.." `个板块   \n其中` "..c.." `个板块不存在，但签到成功有经验(☑☑☑)")
			myhlx:write("  \n获得经验总值 : ` ".. exp*b.." `")

			break
		end  	--if
	end  		--while
 end  			 --if
end				--function

function main()           --主函数

	myhlx = io.tmpfile()
	local xw = os.clock()
	Signin()                --签到

	local s = 0
	for i=1,10^7 do s = s + i end

	myhlx:write(string.format("  \n脚本运行完成，耗时:` %.2f `秒\n", os.clock() - xw))
	local date=os.date("%Y-%m-%d %H:%M:%S");
	myhlx:write("  \n > 时间 : ".. date)

    myhlx:seek("set")
    content = myhlx:read("*a");
    myhlx:close();
	print(content)    --推送内容content

	local PUSH = {}
	PUSH["token"] = PUSH_KEY
	PUSH["title"] = "[葫芦侠3楼签到]"
	PUSH["content"] = content
	PUSH["template"] = "markdown"

local PUSHP = json.encode(PUSH)
all("POST","http://www.pushplus.plus/send",PUSHP)     --推送
print(backa)     --推送成功，返回响应

end

main()

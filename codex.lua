-- Please run
-- :lua Prompt='Your questions'
-- before executing this script by
-- :luafile codex.lua

ApiKey = ""
Url = "https://api.openai.com/v1/completions"
--Prompt = 'Can you write hello world in golang?'
Temperature = 0
--Model = "code-cushman-001"
--Model = "code-davinci-002"
Model = "text-davinci-003"

CodeGpt = {}

function CodeGpt:new(apikey, url, temp, model, prompt)
  local obj = {
    apikey = apikey,
    url = url,
    temp = temp,
    model = model,
    prompt = prompt
  }

  setmetatable(obj, self)
  self.__index = self

  return obj
end

function CodeGpt:gen_header()
  local output = " -H 'Content-Type: application/json' -H 'Authorization: Bearer " .. self.apikey .. "' "
  return output
end

function CodeGpt:get_tokens()
  local count = 100
  for _ in string.gmatch(self.prompt, "%S+") do
    count = count + 1
  end

  return count
end

function CodeGpt:gen_request_body()
  local token = self:get_tokens()
  local rq = { model = self.model, prompt = self.prompt, max_tokens = token, temperature = self.temp }
  return "-d '" .. vim.fn.json_encode(rq) .. "'"
end

function CodeGpt:get_request()
  return "curl " .. self.url .. self:gen_header() .. self:gen_request_body()
end

function CodeGpt:request()
  local result = vim.fn.system(self:get_request())

  -- filter json result
  local json_str = string.match(result, "{.*}")
  local json_obj = vim.fn.json_decode(json_str)
  if json_obj ~= nil then
    if json_obj.error ~= nil and json_obj.error.message ~= "" then
      print(json_obj.error.message)
    elseif json_obj.choices ~= nil and #json_obj.choices > 0 then
      print(json_obj.choices[1].text)
    end
  end
end

local codeai = CodeGpt:new(ApiKey, Url, Temperature, Model, Prompt)
print(codeai:request())

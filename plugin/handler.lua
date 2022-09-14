-- If you're not sure your plugin is executing, uncomment the line below and restart Kong
-- then it will throw an error which indicates the plugin is being loaded at least.

--assert(ngx.get_phase() == "timer", "The world is coming to an end!")

---------------------------------------------------------------------------------------------
-- In the code below, just remove the opening brackets; `[[` to enable a specific handler
--
-- The handlers are based on the OpenResty handlers, see the OpenResty docs for details
-- on when exactly they are invoked and what limitations each handler has.
---------------------------------------------------------------------------------------------
local http = require "resty.http"


local serviceCallout = {
  PRIORITY = 1000, -- set the plugin priority, which determines plugin execution order
  VERSION = "0.1", -- version in X.Y.Z format. Check hybrid-mode compatibility requirements.
}

function serviceCallout:init_worker()
  kong.log.debug("saying hi from the 'init_worker' handler")
end

function serviceCallout:access(conf)
  kong.log.inspect(conf)   -- check the logs for a pretty-printed config!
  local client = http.new()
  
  local res, err = client:request_uri(kong.request.get_header('sc-target'), {
    method = kong.request.get_header('sc-method'),
    body = kong.request.get_header('sc-body'),
  })
  kong.response.set_header("service-callout-response",res.body)
end


return serviceCallout

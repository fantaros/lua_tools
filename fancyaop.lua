--fancyAop by fan
-- create the aop
function fancyAop(func)
	local AOP = ( function ()
		local AOP = { ["aop_method"] = nil, ["next_aop"] = nil };
		--constructor
		function AOP:ctor (aop_obj)
			if type(aop_obj) == "function" then
				func, aop_obj = aop_obj, {};
				if setmetatable then
					setmetatable(aop_obj, self);
				end
				self.__index = self;
				aop_obj:setMethod(func);
			else
				aop_obj = aop_obj or {};
				if setmetatable then
					setmetatable(aop_obj, self);
				end
				self.__index = self;
			end
			return aop_obj;
		end
		-- set method
		function AOP:setMethod (method)
			if type(method) == "function" then
				self.aop_method = method;
			end
			return self;
		end
		-- set next aop chain object
		function AOP:setNext (aop)
			if getmetatable(aop) == AOP then
				self.next_aop = aop;
			end
			return self;
		end
		-- get method
		function AOP:getMethod ()
			return self.aop_method;
		end
		-- get the next aop chain object
		function AOP:getNext ()
			return self.next_aop;
		end
		-- mark sth. as the follow aop object
		function AOP:after (param)
			if type(param) == "function" then
				return self:setNext(AOP:ctor():setMethod(param));
			end
			if getmetatable(aop) == AOP then
				return self:setNext(param);
			end
			return self;
		end
		-- mark sth. as the preview aop object
		function AOP:before (param)
			if type(param) == "function" then
				return AOP:ctor():setMethod(param):setNext(self);
			end
			if getmetatable(aop) == AOP then
				return param:setNext(self);
			end
			return self;
		end
		-- round the method
		function AOP:round (param)
			return self:after(param):before(param);
		end
		-- run the aop chain
		function AOP:run (...)
			if self:getMethod() then
				self:getMethod()(unpack(arg));
			end
			if self:getNext() then
				return self:getNext():run(unpack(arg))
			end
		end
		return AOP;
	end ) ( );
	return AOP:ctor(func);
end

-- test code
fancyAop(function (t) print(tostring(t) .. " the first time") end):round(function (t) print("log" .. tostring(t)) end):run(" run this");

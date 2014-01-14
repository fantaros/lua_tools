function fancyAop(func)
	local AOP = ( function ()
		local AOP = { ["aop_method"] = nil, ["next_aop"] = nil };
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
		function AOP:setMethod (method)
			if type(method) == "function" then
				self.aop_method = method;
			end
			return self;
		end
		function AOP:setNext (aop)
			if getmetatable(aop) == AOP then
				self.next_aop = aop;
			end
			return self;
		end
		function AOP:getMethod ()
			return self.aop_method;
		end
		function AOP:getNext ()
			return self.next_aop;
		end
		function AOP:after (param)
			if type(param) == "function" then
				local naop = AOP:ctor();
				naop:setMethod(param);
				self:setNext(naop);
			end
			if getmetatable(aop) == AOP then
				self:setNext(param);
			end
			return self;
		end
		function AOP:before (param)
			local baop = nil;
			if type(param) == "function" then
				baop = AOP:ctor();
				baop:setMethod(param);
				baop:setNext(self);
			end
			if getmetatable(aop) == AOP then
				baop = param;
				self:setNext(param);
			end
			return baop;
		end
		function AOP:round (param)
			local s = self:after(param);
			s = s:before(param);
			return s;
		end
		function AOP:run (...)
			local method = self:getMethod();
			local next_aop = self:getNext();
			if method then
				method(unpack(arg));
			end
			if next_aop then
				return next_aop:run(unpack(arg))
			end
		end
		return AOP;
	end ) ( );
	local self_aop = AOP:ctor(func);
	return self_aop;
end

fancyAop(function () print("1") end):round(function () print("log") end):run();

-- fancyAop by fan
-- no follow details
-- date 2014.01.14
-- fancyAop method to create AOP object
function fancyAop(func)
	local AOP = ( function ()
		-- THE CLASS AOP TABLE
		local AOP = { ["aop_method"] = nil, ["next_aop"] = nil };
		-- constructor
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
		-- set next aop chain
		function AOP:setNext (aop)
			if getmetatable(aop) == AOP then
				self.next_aop = aop;
			end
			return self;
		end
		-- get the method
		function AOP:getMethod ()
			return self.aop_method;
		end
		-- get next
		function AOP:getNext ()
			return self.next_aop;
		end
		-- mark sth. to run after method
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
		-- mark sth. to run before method
		function AOP:before (param)
			if type(param) == "function" then
				local baop = AOP:ctor();
				baop:setMethod(param);
				baop:setNext(self);
				return baop;
			end
			if getmetatable(aop) == AOP then
				self:setNext(param);
				return param;
			end
			return self;
		end
		-- mark sth. to round method
		function AOP:round (param)
			return self:before(param):after(param);
		end
		-- run the aop chain
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

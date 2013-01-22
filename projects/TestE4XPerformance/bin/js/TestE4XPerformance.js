var $hxClasses = $hxClasses || {},$estr = function() { return js.Boot.__string_rec(this,''); };
var Hash = $hxClasses["Hash"] = function() {
	this.h = { };
};
Hash.__name__ = ["Hash"];
Hash.prototype = {
	toString: function() {
		var s = new StringBuf();
		s.b += Std.string("{");
		var it = this.keys();
		while( it.hasNext() ) {
			var i = it.next();
			s.b += Std.string(i);
			s.b += Std.string(" => ");
			s.b += Std.string(Std.string(this.get(i)));
			if(it.hasNext()) s.b += Std.string(", ");
		}
		s.b += Std.string("}");
		return s.b;
	}
	,iterator: function() {
		return { ref : this.h, it : this.keys(), hasNext : function() {
			return this.it.hasNext();
		}, next : function() {
			var i = this.it.next();
			return this.ref["$" + i];
		}};
	}
	,keys: function() {
		var a = [];
		for( var key in this.h ) {
		if(this.h.hasOwnProperty(key)) a.push(key.substr(1));
		}
		return HxOverrides.iter(a);
	}
	,remove: function(key) {
		key = "$" + key;
		if(!this.h.hasOwnProperty(key)) return false;
		delete(this.h[key]);
		return true;
	}
	,exists: function(key) {
		return this.h.hasOwnProperty("$" + key);
	}
	,get: function(key) {
		return this.h["$" + key];
	}
	,set: function(key,value) {
		this.h["$" + key] = value;
	}
	,h: null
	,__class__: Hash
}
var HxOverrides = $hxClasses["HxOverrides"] = function() { }
HxOverrides.__name__ = ["HxOverrides"];
HxOverrides.dateStr = function(date) {
	var m = date.getMonth() + 1;
	var d = date.getDate();
	var h = date.getHours();
	var mi = date.getMinutes();
	var s = date.getSeconds();
	return date.getFullYear() + "-" + (m < 10?"0" + m:"" + m) + "-" + (d < 10?"0" + d:"" + d) + " " + (h < 10?"0" + h:"" + h) + ":" + (mi < 10?"0" + mi:"" + mi) + ":" + (s < 10?"0" + s:"" + s);
}
HxOverrides.strDate = function(s) {
	switch(s.length) {
	case 8:
		var k = s.split(":");
		var d = new Date();
		d.setTime(0);
		d.setUTCHours(k[0]);
		d.setUTCMinutes(k[1]);
		d.setUTCSeconds(k[2]);
		return d;
	case 10:
		var k = s.split("-");
		return new Date(k[0],k[1] - 1,k[2],0,0,0);
	case 19:
		var k = s.split(" ");
		var y = k[0].split("-");
		var t = k[1].split(":");
		return new Date(y[0],y[1] - 1,y[2],t[0],t[1],t[2]);
	default:
		throw "Invalid date format : " + s;
	}
}
HxOverrides.cca = function(s,index) {
	var x = s.charCodeAt(index);
	if(x != x) return undefined;
	return x;
}
HxOverrides.substr = function(s,pos,len) {
	if(pos != null && pos != 0 && len != null && len < 0) return "";
	if(len == null) len = s.length;
	if(pos < 0) {
		pos = s.length + pos;
		if(pos < 0) pos = 0;
	} else if(len < 0) len = s.length + len - pos;
	return s.substr(pos,len);
}
HxOverrides.remove = function(a,obj) {
	var i = 0;
	var l = a.length;
	while(i < l) {
		if(a[i] == obj) {
			a.splice(i,1);
			return true;
		}
		i++;
	}
	return false;
}
HxOverrides.iter = function(a) {
	return { cur : 0, arr : a, hasNext : function() {
		return this.cur < this.arr.length;
	}, next : function() {
		return this.arr[this.cur++];
	}};
}
var IntHash = $hxClasses["IntHash"] = function() {
	this.h = { };
};
IntHash.__name__ = ["IntHash"];
IntHash.prototype = {
	toString: function() {
		var s = new StringBuf();
		s.b += Std.string("{");
		var it = this.keys();
		while( it.hasNext() ) {
			var i = it.next();
			s.b += Std.string(i);
			s.b += Std.string(" => ");
			s.b += Std.string(Std.string(this.get(i)));
			if(it.hasNext()) s.b += Std.string(", ");
		}
		s.b += Std.string("}");
		return s.b;
	}
	,iterator: function() {
		return { ref : this.h, it : this.keys(), hasNext : function() {
			return this.it.hasNext();
		}, next : function() {
			var i = this.it.next();
			return this.ref[i];
		}};
	}
	,keys: function() {
		var a = [];
		for( var key in this.h ) {
		if(this.h.hasOwnProperty(key)) a.push(key | 0);
		}
		return HxOverrides.iter(a);
	}
	,remove: function(key) {
		if(!this.h.hasOwnProperty(key)) return false;
		delete(this.h[key]);
		return true;
	}
	,exists: function(key) {
		return this.h.hasOwnProperty(key);
	}
	,get: function(key) {
		return this.h[key];
	}
	,set: function(key,value) {
		this.h[key] = value;
	}
	,h: null
	,__class__: IntHash
}
var IntIter = $hxClasses["IntIter"] = function(min,max) {
	this.min = min;
	this.max = max;
};
IntIter.__name__ = ["IntIter"];
IntIter.prototype = {
	next: function() {
		return this.min++;
	}
	,hasNext: function() {
		return this.min < this.max;
	}
	,max: null
	,min: null
	,__class__: IntIter
}
var Lambda = $hxClasses["Lambda"] = function() { }
Lambda.__name__ = ["Lambda"];
Lambda.array = function(it) {
	var a = new Array();
	var $it0 = $iterator(it)();
	while( $it0.hasNext() ) {
		var i = $it0.next();
		a.push(i);
	}
	return a;
}
Lambda.list = function(it) {
	var l = new List();
	var $it0 = $iterator(it)();
	while( $it0.hasNext() ) {
		var i = $it0.next();
		l.add(i);
	}
	return l;
}
Lambda.map = function(it,f) {
	var l = new List();
	var $it0 = $iterator(it)();
	while( $it0.hasNext() ) {
		var x = $it0.next();
		l.add(f(x));
	}
	return l;
}
Lambda.mapi = function(it,f) {
	var l = new List();
	var i = 0;
	var $it0 = $iterator(it)();
	while( $it0.hasNext() ) {
		var x = $it0.next();
		l.add(f(i++,x));
	}
	return l;
}
Lambda.has = function(it,elt,cmp) {
	if(cmp == null) {
		var $it0 = $iterator(it)();
		while( $it0.hasNext() ) {
			var x = $it0.next();
			if(x == elt) return true;
		}
	} else {
		var $it1 = $iterator(it)();
		while( $it1.hasNext() ) {
			var x = $it1.next();
			if(cmp(x,elt)) return true;
		}
	}
	return false;
}
Lambda.exists = function(it,f) {
	var $it0 = $iterator(it)();
	while( $it0.hasNext() ) {
		var x = $it0.next();
		if(f(x)) return true;
	}
	return false;
}
Lambda.foreach = function(it,f) {
	var $it0 = $iterator(it)();
	while( $it0.hasNext() ) {
		var x = $it0.next();
		if(!f(x)) return false;
	}
	return true;
}
Lambda.iter = function(it,f) {
	var $it0 = $iterator(it)();
	while( $it0.hasNext() ) {
		var x = $it0.next();
		f(x);
	}
}
Lambda.filter = function(it,f) {
	var l = new List();
	var $it0 = $iterator(it)();
	while( $it0.hasNext() ) {
		var x = $it0.next();
		if(f(x)) l.add(x);
	}
	return l;
}
Lambda.fold = function(it,f,first) {
	var $it0 = $iterator(it)();
	while( $it0.hasNext() ) {
		var x = $it0.next();
		first = f(x,first);
	}
	return first;
}
Lambda.count = function(it,pred) {
	var n = 0;
	if(pred == null) {
		var $it0 = $iterator(it)();
		while( $it0.hasNext() ) {
			var _ = $it0.next();
			n++;
		}
	} else {
		var $it1 = $iterator(it)();
		while( $it1.hasNext() ) {
			var x = $it1.next();
			if(pred(x)) n++;
		}
	}
	return n;
}
Lambda.empty = function(it) {
	return !$iterator(it)().hasNext();
}
Lambda.indexOf = function(it,v) {
	var i = 0;
	var $it0 = $iterator(it)();
	while( $it0.hasNext() ) {
		var v2 = $it0.next();
		if(v == v2) return i;
		i++;
	}
	return -1;
}
Lambda.concat = function(a,b) {
	var l = new List();
	var $it0 = $iterator(a)();
	while( $it0.hasNext() ) {
		var x = $it0.next();
		l.add(x);
	}
	var $it1 = $iterator(b)();
	while( $it1.hasNext() ) {
		var x = $it1.next();
		l.add(x);
	}
	return l;
}
var List = $hxClasses["List"] = function() {
	this.length = 0;
};
List.__name__ = ["List"];
List.prototype = {
	map: function(f) {
		var b = new List();
		var l = this.h;
		while(l != null) {
			var v = l[0];
			l = l[1];
			b.add(f(v));
		}
		return b;
	}
	,filter: function(f) {
		var l2 = new List();
		var l = this.h;
		while(l != null) {
			var v = l[0];
			l = l[1];
			if(f(v)) l2.add(v);
		}
		return l2;
	}
	,join: function(sep) {
		var s = new StringBuf();
		var first = true;
		var l = this.h;
		while(l != null) {
			if(first) first = false; else s.b += Std.string(sep);
			s.b += Std.string(l[0]);
			l = l[1];
		}
		return s.b;
	}
	,toString: function() {
		var s = new StringBuf();
		var first = true;
		var l = this.h;
		s.b += Std.string("{");
		while(l != null) {
			if(first) first = false; else s.b += Std.string(", ");
			s.b += Std.string(Std.string(l[0]));
			l = l[1];
		}
		s.b += Std.string("}");
		return s.b;
	}
	,iterator: function() {
		return { h : this.h, hasNext : function() {
			return this.h != null;
		}, next : function() {
			if(this.h == null) return null;
			var x = this.h[0];
			this.h = this.h[1];
			return x;
		}};
	}
	,remove: function(v) {
		var prev = null;
		var l = this.h;
		while(l != null) {
			if(l[0] == v) {
				if(prev == null) this.h = l[1]; else prev[1] = l[1];
				if(this.q == l) this.q = prev;
				this.length--;
				return true;
			}
			prev = l;
			l = l[1];
		}
		return false;
	}
	,clear: function() {
		this.h = null;
		this.q = null;
		this.length = 0;
	}
	,isEmpty: function() {
		return this.h == null;
	}
	,pop: function() {
		if(this.h == null) return null;
		var x = this.h[0];
		this.h = this.h[1];
		if(this.h == null) this.q = null;
		this.length--;
		return x;
	}
	,last: function() {
		return this.q == null?null:this.q[0];
	}
	,first: function() {
		return this.h == null?null:this.h[0];
	}
	,push: function(item) {
		var x = [item,this.h];
		this.h = x;
		if(this.q == null) this.q = x;
		this.length++;
	}
	,add: function(item) {
		var x = [item];
		if(this.h == null) this.h = x; else this.q[1] = x;
		this.q = x;
		this.length++;
	}
	,length: null
	,q: null
	,h: null
	,__class__: List
}
var PerfTestRunner = $hxClasses["PerfTestRunner"] = function() { }
PerfTestRunner.__name__ = ["PerfTestRunner"];
PerfTestRunner._funcBenchmark = null;
PerfTestRunner._tests = null;
PerfTestRunner._currentTest = null;
PerfTestRunner.addTest = function(name,testFunc,iterations) {
	if(PerfTestRunner._tests == null) {
		PerfTestRunner._tests = new Array();
		PerfTestRunner._funcBenchmark = new PerfTest("Function Benchmark",PerfTestRunner.funcBenchmark,1000000);
	}
	PerfTestRunner._tests.push(new PerfTest(name,testFunc,iterations));
}
PerfTestRunner.runTests = function() {
	PerfTestRunner._currentTest = -1;
	PerfTestRunner.runNextTest();
}
PerfTestRunner.runNextTest = function() {
	var test = PerfTestRunner._currentTest == -1?PerfTestRunner._funcBenchmark:PerfTestRunner._tests[PerfTestRunner._currentTest];
	haxe.Log.trace("Running Test: " + test.name,{ fileName : "PerfTestRunner.hx", lineNumber : 33, className : "PerfTestRunner", methodName : "runNextTest"});
	var start = haxe.Timer.stamp();
	haxe.Log.trace(start,{ fileName : "PerfTestRunner.hx", lineNumber : 35, className : "PerfTestRunner", methodName : "runNextTest"});
	var func = test.testFunc;
	var _g1 = 0, _g = test.iterations;
	while(_g1 < _g) {
		var i = _g1++;
		func();
	}
	var end = haxe.Timer.stamp();
	test.time = end - start;
	if(PerfTestRunner._currentTest != -1) test.time -= PerfTestRunner._funcBenchmark.time / PerfTestRunner._funcBenchmark.iterations * test.iterations;
	var perThousand = test.time / test.iterations * 1000;
	haxe.Log.trace(perThousand / PerfTestRunner.SECOND_FACTOR + "s per 1000 iterations\n",{ fileName : "PerfTestRunner.hx", lineNumber : 46, className : "PerfTestRunner", methodName : "runNextTest"});
	PerfTestRunner._currentTest++;
	if(PerfTestRunner._currentTest < PerfTestRunner._tests.length) PerfTestRunner.runNextTest();
}
PerfTestRunner.funcBenchmark = function() {
}
var PerfTest = $hxClasses["PerfTest"] = function(name,testFunc,iterations) {
	this.name = name;
	this.testFunc = testFunc;
	this.iterations = iterations;
};
PerfTest.__name__ = ["PerfTest"];
PerfTest.prototype = {
	time: null
	,iterations: null
	,testFunc: null
	,name: null
	,__class__: PerfTest
}
var Reflect = $hxClasses["Reflect"] = function() { }
Reflect.__name__ = ["Reflect"];
Reflect.hasField = function(o,field) {
	return Object.prototype.hasOwnProperty.call(o,field);
}
Reflect.field = function(o,field) {
	var v = null;
	try {
		v = o[field];
	} catch( e ) {
	}
	return v;
}
Reflect.setField = function(o,field,value) {
	o[field] = value;
}
Reflect.getProperty = function(o,field) {
	var tmp;
	return o == null?null:o.__properties__ && (tmp = o.__properties__["get_" + field])?o[tmp]():o[field];
}
Reflect.setProperty = function(o,field,value) {
	var tmp;
	if(o.__properties__ && (tmp = o.__properties__["set_" + field])) o[tmp](value); else o[field] = value;
}
Reflect.callMethod = function(o,func,args) {
	return func.apply(o,args);
}
Reflect.fields = function(o) {
	var a = [];
	if(o != null) {
		var hasOwnProperty = Object.prototype.hasOwnProperty;
		for( var f in o ) {
		if(hasOwnProperty.call(o,f)) a.push(f);
		}
	}
	return a;
}
Reflect.isFunction = function(f) {
	return typeof(f) == "function" && !(f.__name__ || f.__ename__);
}
Reflect.compare = function(a,b) {
	return a == b?0:a > b?1:-1;
}
Reflect.compareMethods = function(f1,f2) {
	if(f1 == f2) return true;
	if(!Reflect.isFunction(f1) || !Reflect.isFunction(f2)) return false;
	return f1.scope == f2.scope && f1.method == f2.method && f1.method != null;
}
Reflect.isObject = function(v) {
	if(v == null) return false;
	var t = typeof(v);
	return t == "string" || t == "object" && !v.__enum__ || t == "function" && (v.__name__ || v.__ename__);
}
Reflect.deleteField = function(o,f) {
	if(!Reflect.hasField(o,f)) return false;
	delete(o[f]);
	return true;
}
Reflect.copy = function(o) {
	var o2 = { };
	var _g = 0, _g1 = Reflect.fields(o);
	while(_g < _g1.length) {
		var f = _g1[_g];
		++_g;
		o2[f] = Reflect.field(o,f);
	}
	return o2;
}
Reflect.makeVarArgs = function(f) {
	return function() {
		var a = Array.prototype.slice.call(arguments);
		return f(a);
	};
}
var Std = $hxClasses["Std"] = function() { }
Std.__name__ = ["Std"];
Std["is"] = function(v,t) {
	return js.Boot.__instanceof(v,t);
}
Std.string = function(s) {
	return js.Boot.__string_rec(s,"");
}
Std["int"] = function(x) {
	return x | 0;
}
Std.parseInt = function(x) {
	var v = parseInt(x,10);
	if(v == 0 && (HxOverrides.cca(x,1) == 120 || HxOverrides.cca(x,1) == 88)) v = parseInt(x);
	if(isNaN(v)) return null;
	return v;
}
Std.parseFloat = function(x) {
	return parseFloat(x);
}
Std.random = function(x) {
	return Math.floor(Math.random() * x);
}
var StringBuf = $hxClasses["StringBuf"] = function() {
	this.b = "";
};
StringBuf.__name__ = ["StringBuf"];
StringBuf.prototype = {
	toString: function() {
		return this.b;
	}
	,addSub: function(s,pos,len) {
		this.b += HxOverrides.substr(s,pos,len);
	}
	,addChar: function(c) {
		this.b += String.fromCharCode(c);
	}
	,add: function(x) {
		this.b += Std.string(x);
	}
	,b: null
	,__class__: StringBuf
}
var StringTools = $hxClasses["StringTools"] = function() { }
StringTools.__name__ = ["StringTools"];
StringTools.urlEncode = function(s) {
	return encodeURIComponent(s);
}
StringTools.urlDecode = function(s) {
	return decodeURIComponent(s.split("+").join(" "));
}
StringTools.htmlEscape = function(s) {
	return s.split("&").join("&amp;").split("<").join("&lt;").split(">").join("&gt;");
}
StringTools.htmlUnescape = function(s) {
	return s.split("&gt;").join(">").split("&lt;").join("<").split("&amp;").join("&");
}
StringTools.startsWith = function(s,start) {
	return s.length >= start.length && HxOverrides.substr(s,0,start.length) == start;
}
StringTools.endsWith = function(s,end) {
	var elen = end.length;
	var slen = s.length;
	return slen >= elen && HxOverrides.substr(s,slen - elen,elen) == end;
}
StringTools.isSpace = function(s,pos) {
	var c = HxOverrides.cca(s,pos);
	return c >= 9 && c <= 13 || c == 32;
}
StringTools.ltrim = function(s) {
	var l = s.length;
	var r = 0;
	while(r < l && StringTools.isSpace(s,r)) r++;
	if(r > 0) return HxOverrides.substr(s,r,l - r); else return s;
}
StringTools.rtrim = function(s) {
	var l = s.length;
	var r = 0;
	while(r < l && StringTools.isSpace(s,l - r - 1)) r++;
	if(r > 0) return HxOverrides.substr(s,0,l - r); else return s;
}
StringTools.trim = function(s) {
	return StringTools.ltrim(StringTools.rtrim(s));
}
StringTools.rpad = function(s,c,l) {
	var sl = s.length;
	var cl = c.length;
	while(sl < l) if(l - sl < cl) {
		s += HxOverrides.substr(c,0,l - sl);
		sl = l;
	} else {
		s += c;
		sl += cl;
	}
	return s;
}
StringTools.lpad = function(s,c,l) {
	var ns = "";
	var sl = s.length;
	if(sl >= l) return s;
	var cl = c.length;
	while(sl < l) if(l - sl < cl) {
		ns += HxOverrides.substr(c,0,l - sl);
		sl = l;
	} else {
		ns += c;
		sl += cl;
	}
	return ns + s;
}
StringTools.replace = function(s,sub,by) {
	return s.split(sub).join(by);
}
StringTools.hex = function(n,digits) {
	var s = "";
	var hexChars = "0123456789ABCDEF";
	do {
		s = hexChars.charAt(n & 15) + s;
		n >>>= 4;
	} while(n > 0);
	if(digits != null) while(s.length < digits) s = "0" + s;
	return s;
}
StringTools.fastCodeAt = function(s,index) {
	return s.charCodeAt(index);
}
StringTools.isEOF = function(c) {
	return c != c;
}
var TestE4XPerformance = $hxClasses["TestE4XPerformance"] = function() {
	this._xml = Xml.parse(haxe.Resource.getString("sample-xml"));
	PerfTestRunner.addTest("Get Children",$bind(this,this.getChildren),1000);
	PerfTestRunner.addTest("Get Descendants",$bind(this,this.getDescendants),100);
	PerfTestRunner.addTest("Get Descendant Text",$bind(this,this.getDescText),100);
	PerfTestRunner.runTests();
};
TestE4XPerformance.__name__ = ["TestE4XPerformance"];
TestE4XPerformance.main = function() {
	new TestE4XPerformance();
}
TestE4XPerformance.prototype = {
	getDescText: function() {
		xmlTools.E4X.doRetText(xmlTools.E4X.getNew(this._xml).desc().text());
	}
	,getDescendants: function() {
		xmlTools.E4X.doRetNodes(xmlTools.E4X.getNew(this._xml).desc());
	}
	,getChildren: function() {
		xmlTools.E4X.doRetNodes(xmlTools.E4X.getNew(this._xml).child());
	}
	,_xml: null
	,__class__: TestE4XPerformance
}
var ValueType = $hxClasses["ValueType"] = { __ename__ : ["ValueType"], __constructs__ : ["TNull","TInt","TFloat","TBool","TObject","TFunction","TClass","TEnum","TUnknown"] }
ValueType.TNull = ["TNull",0];
ValueType.TNull.toString = $estr;
ValueType.TNull.__enum__ = ValueType;
ValueType.TInt = ["TInt",1];
ValueType.TInt.toString = $estr;
ValueType.TInt.__enum__ = ValueType;
ValueType.TFloat = ["TFloat",2];
ValueType.TFloat.toString = $estr;
ValueType.TFloat.__enum__ = ValueType;
ValueType.TBool = ["TBool",3];
ValueType.TBool.toString = $estr;
ValueType.TBool.__enum__ = ValueType;
ValueType.TObject = ["TObject",4];
ValueType.TObject.toString = $estr;
ValueType.TObject.__enum__ = ValueType;
ValueType.TFunction = ["TFunction",5];
ValueType.TFunction.toString = $estr;
ValueType.TFunction.__enum__ = ValueType;
ValueType.TClass = function(c) { var $x = ["TClass",6,c]; $x.__enum__ = ValueType; $x.toString = $estr; return $x; }
ValueType.TEnum = function(e) { var $x = ["TEnum",7,e]; $x.__enum__ = ValueType; $x.toString = $estr; return $x; }
ValueType.TUnknown = ["TUnknown",8];
ValueType.TUnknown.toString = $estr;
ValueType.TUnknown.__enum__ = ValueType;
var Type = $hxClasses["Type"] = function() { }
Type.__name__ = ["Type"];
Type.getClass = function(o) {
	if(o == null) return null;
	return o.__class__;
}
Type.getEnum = function(o) {
	if(o == null) return null;
	return o.__enum__;
}
Type.getSuperClass = function(c) {
	return c.__super__;
}
Type.getClassName = function(c) {
	var a = c.__name__;
	return a.join(".");
}
Type.getEnumName = function(e) {
	var a = e.__ename__;
	return a.join(".");
}
Type.resolveClass = function(name) {
	var cl = $hxClasses[name];
	if(cl == null || !cl.__name__) return null;
	return cl;
}
Type.resolveEnum = function(name) {
	var e = $hxClasses[name];
	if(e == null || !e.__ename__) return null;
	return e;
}
Type.createInstance = function(cl,args) {
	switch(args.length) {
	case 0:
		return new cl();
	case 1:
		return new cl(args[0]);
	case 2:
		return new cl(args[0],args[1]);
	case 3:
		return new cl(args[0],args[1],args[2]);
	case 4:
		return new cl(args[0],args[1],args[2],args[3]);
	case 5:
		return new cl(args[0],args[1],args[2],args[3],args[4]);
	case 6:
		return new cl(args[0],args[1],args[2],args[3],args[4],args[5]);
	case 7:
		return new cl(args[0],args[1],args[2],args[3],args[4],args[5],args[6]);
	case 8:
		return new cl(args[0],args[1],args[2],args[3],args[4],args[5],args[6],args[7]);
	default:
		throw "Too many arguments";
	}
	return null;
}
Type.createEmptyInstance = function(cl) {
	function empty() {}; empty.prototype = cl.prototype;
	return new empty();
}
Type.createEnum = function(e,constr,params) {
	var f = Reflect.field(e,constr);
	if(f == null) throw "No such constructor " + constr;
	if(Reflect.isFunction(f)) {
		if(params == null) throw "Constructor " + constr + " need parameters";
		return f.apply(e,params);
	}
	if(params != null && params.length != 0) throw "Constructor " + constr + " does not need parameters";
	return f;
}
Type.createEnumIndex = function(e,index,params) {
	var c = e.__constructs__[index];
	if(c == null) throw index + " is not a valid enum constructor index";
	return Type.createEnum(e,c,params);
}
Type.getInstanceFields = function(c) {
	var a = [];
	for(var i in c.prototype) a.push(i);
	HxOverrides.remove(a,"__class__");
	HxOverrides.remove(a,"__properties__");
	return a;
}
Type.getClassFields = function(c) {
	var a = Reflect.fields(c);
	HxOverrides.remove(a,"__name__");
	HxOverrides.remove(a,"__interfaces__");
	HxOverrides.remove(a,"__properties__");
	HxOverrides.remove(a,"__super__");
	HxOverrides.remove(a,"prototype");
	return a;
}
Type.getEnumConstructs = function(e) {
	var a = e.__constructs__;
	return a.slice();
}
Type["typeof"] = function(v) {
	switch(typeof(v)) {
	case "boolean":
		return ValueType.TBool;
	case "string":
		return ValueType.TClass(String);
	case "number":
		if(Math.ceil(v) == v % 2147483648.0) return ValueType.TInt;
		return ValueType.TFloat;
	case "object":
		if(v == null) return ValueType.TNull;
		var e = v.__enum__;
		if(e != null) return ValueType.TEnum(e);
		var c = v.__class__;
		if(c != null) return ValueType.TClass(c);
		return ValueType.TObject;
	case "function":
		if(v.__name__ || v.__ename__) return ValueType.TObject;
		return ValueType.TFunction;
	case "undefined":
		return ValueType.TNull;
	default:
		return ValueType.TUnknown;
	}
}
Type.enumEq = function(a,b) {
	if(a == b) return true;
	try {
		if(a[0] != b[0]) return false;
		var _g1 = 2, _g = a.length;
		while(_g1 < _g) {
			var i = _g1++;
			if(!Type.enumEq(a[i],b[i])) return false;
		}
		var e = a.__enum__;
		if(e != b.__enum__ || e == null) return false;
	} catch( e ) {
		return false;
	}
	return true;
}
Type.enumConstructor = function(e) {
	return e[0];
}
Type.enumParameters = function(e) {
	return e.slice(2);
}
Type.enumIndex = function(e) {
	return e[1];
}
Type.allEnums = function(e) {
	var all = [];
	var cst = e.__constructs__;
	var _g = 0;
	while(_g < cst.length) {
		var c = cst[_g];
		++_g;
		var v = Reflect.field(e,c);
		if(!Reflect.isFunction(v)) all.push(v);
	}
	return all;
}
var Xml = $hxClasses["Xml"] = function() {
};
Xml.__name__ = ["Xml"];
Xml.Element = null;
Xml.PCData = null;
Xml.CData = null;
Xml.Comment = null;
Xml.DocType = null;
Xml.Prolog = null;
Xml.Document = null;
Xml.parse = function(str) {
	return haxe.xml.Parser.parse(str);
}
Xml.createElement = function(name) {
	var r = new Xml();
	r.nodeType = Xml.Element;
	r._children = new Array();
	r._attributes = new Hash();
	r.setNodeName(name);
	return r;
}
Xml.createPCData = function(data) {
	var r = new Xml();
	r.nodeType = Xml.PCData;
	r.setNodeValue(data);
	return r;
}
Xml.createCData = function(data) {
	var r = new Xml();
	r.nodeType = Xml.CData;
	r.setNodeValue(data);
	return r;
}
Xml.createComment = function(data) {
	var r = new Xml();
	r.nodeType = Xml.Comment;
	r.setNodeValue(data);
	return r;
}
Xml.createDocType = function(data) {
	var r = new Xml();
	r.nodeType = Xml.DocType;
	r.setNodeValue(data);
	return r;
}
Xml.createProlog = function(data) {
	var r = new Xml();
	r.nodeType = Xml.Prolog;
	r.setNodeValue(data);
	return r;
}
Xml.createDocument = function() {
	var r = new Xml();
	r.nodeType = Xml.Document;
	r._children = new Array();
	return r;
}
Xml.prototype = {
	toString: function() {
		if(this.nodeType == Xml.PCData) return this._nodeValue;
		if(this.nodeType == Xml.CData) return "<![CDATA[" + this._nodeValue + "]]>";
		if(this.nodeType == Xml.Comment) return "<!--" + this._nodeValue + "-->";
		if(this.nodeType == Xml.DocType) return "<!DOCTYPE " + this._nodeValue + ">";
		if(this.nodeType == Xml.Prolog) return "<?" + this._nodeValue + "?>";
		var s = new StringBuf();
		if(this.nodeType == Xml.Element) {
			s.b += Std.string("<");
			s.b += Std.string(this._nodeName);
			var $it0 = this._attributes.keys();
			while( $it0.hasNext() ) {
				var k = $it0.next();
				s.b += Std.string(" ");
				s.b += Std.string(k);
				s.b += Std.string("=\"");
				s.b += Std.string(this._attributes.get(k));
				s.b += Std.string("\"");
			}
			if(this._children.length == 0) {
				s.b += Std.string("/>");
				return s.b;
			}
			s.b += Std.string(">");
		}
		var $it1 = this.iterator();
		while( $it1.hasNext() ) {
			var x = $it1.next();
			s.b += Std.string(x.toString());
		}
		if(this.nodeType == Xml.Element) {
			s.b += Std.string("</");
			s.b += Std.string(this._nodeName);
			s.b += Std.string(">");
		}
		return s.b;
	}
	,insertChild: function(x,pos) {
		if(this._children == null) throw "bad nodetype";
		if(x._parent != null) HxOverrides.remove(x._parent._children,x);
		x._parent = this;
		this._children.splice(pos,0,x);
	}
	,removeChild: function(x) {
		if(this._children == null) throw "bad nodetype";
		var b = HxOverrides.remove(this._children,x);
		if(b) x._parent = null;
		return b;
	}
	,addChild: function(x) {
		if(this._children == null) throw "bad nodetype";
		if(x._parent != null) HxOverrides.remove(x._parent._children,x);
		x._parent = this;
		this._children.push(x);
	}
	,firstElement: function() {
		if(this._children == null) throw "bad nodetype";
		var cur = 0;
		var l = this._children.length;
		while(cur < l) {
			var n = this._children[cur];
			if(n.nodeType == Xml.Element) return n;
			cur++;
		}
		return null;
	}
	,firstChild: function() {
		if(this._children == null) throw "bad nodetype";
		return this._children[0];
	}
	,elementsNamed: function(name) {
		if(this._children == null) throw "bad nodetype";
		return { cur : 0, x : this._children, hasNext : function() {
			var k = this.cur;
			var l = this.x.length;
			while(k < l) {
				var n = this.x[k];
				if(n.nodeType == Xml.Element && n._nodeName == name) break;
				k++;
			}
			this.cur = k;
			return k < l;
		}, next : function() {
			var k = this.cur;
			var l = this.x.length;
			while(k < l) {
				var n = this.x[k];
				k++;
				if(n.nodeType == Xml.Element && n._nodeName == name) {
					this.cur = k;
					return n;
				}
			}
			return null;
		}};
	}
	,elements: function() {
		if(this._children == null) throw "bad nodetype";
		return { cur : 0, x : this._children, hasNext : function() {
			var k = this.cur;
			var l = this.x.length;
			while(k < l) {
				if(this.x[k].nodeType == Xml.Element) break;
				k += 1;
			}
			this.cur = k;
			return k < l;
		}, next : function() {
			var k = this.cur;
			var l = this.x.length;
			while(k < l) {
				var n = this.x[k];
				k += 1;
				if(n.nodeType == Xml.Element) {
					this.cur = k;
					return n;
				}
			}
			return null;
		}};
	}
	,iterator: function() {
		if(this._children == null) throw "bad nodetype";
		return { cur : 0, x : this._children, hasNext : function() {
			return this.cur < this.x.length;
		}, next : function() {
			return this.x[this.cur++];
		}};
	}
	,attributes: function() {
		if(this.nodeType != Xml.Element) throw "bad nodeType";
		return this._attributes.keys();
	}
	,exists: function(att) {
		if(this.nodeType != Xml.Element) throw "bad nodeType";
		return this._attributes.exists(att);
	}
	,remove: function(att) {
		if(this.nodeType != Xml.Element) throw "bad nodeType";
		this._attributes.remove(att);
	}
	,set: function(att,value) {
		if(this.nodeType != Xml.Element) throw "bad nodeType";
		this._attributes.set(att,value);
	}
	,get: function(att) {
		if(this.nodeType != Xml.Element) throw "bad nodeType";
		return this._attributes.get(att);
	}
	,getParent: function() {
		return this._parent;
	}
	,setNodeValue: function(v) {
		if(this.nodeType == Xml.Element || this.nodeType == Xml.Document) throw "bad nodeType";
		return this._nodeValue = v;
	}
	,getNodeValue: function() {
		if(this.nodeType == Xml.Element || this.nodeType == Xml.Document) throw "bad nodeType";
		return this._nodeValue;
	}
	,setNodeName: function(n) {
		if(this.nodeType != Xml.Element) throw "bad nodeType";
		return this._nodeName = n;
	}
	,getNodeName: function() {
		if(this.nodeType != Xml.Element) throw "bad nodeType";
		return this._nodeName;
	}
	,_parent: null
	,_children: null
	,_attributes: null
	,_nodeValue: null
	,_nodeName: null
	,parent: null
	,nodeValue: null
	,nodeName: null
	,nodeType: null
	,__class__: Xml
	,__properties__: {set_nodeName:"setNodeName",get_nodeName:"getNodeName",set_nodeValue:"setNodeValue",get_nodeValue:"getNodeValue",get_parent:"getParent"}
}
var haxe = haxe || {}
haxe.Log = $hxClasses["haxe.Log"] = function() { }
haxe.Log.__name__ = ["haxe","Log"];
haxe.Log.trace = function(v,infos) {
	js.Boot.__trace(v,infos);
}
haxe.Log.clear = function() {
	js.Boot.__clear_trace();
}
haxe.Resource = $hxClasses["haxe.Resource"] = function() { }
haxe.Resource.__name__ = ["haxe","Resource"];
haxe.Resource.content = null;
haxe.Resource.listNames = function() {
	var names = new Array();
	var _g = 0, _g1 = haxe.Resource.content;
	while(_g < _g1.length) {
		var x = _g1[_g];
		++_g;
		names.push(x.name);
	}
	return names;
}
haxe.Resource.getString = function(name) {
	var _g = 0, _g1 = haxe.Resource.content;
	while(_g < _g1.length) {
		var x = _g1[_g];
		++_g;
		if(x.name == name) {
			if(x.str != null) return x.str;
			var b = haxe.Unserializer.run(x.data);
			return b.toString();
		}
	}
	return null;
}
haxe.Resource.getBytes = function(name) {
	var _g = 0, _g1 = haxe.Resource.content;
	while(_g < _g1.length) {
		var x = _g1[_g];
		++_g;
		if(x.name == name) {
			if(x.str != null) return haxe.io.Bytes.ofString(x.str);
			return haxe.Unserializer.run(x.data);
		}
	}
	return null;
}
haxe.Timer = $hxClasses["haxe.Timer"] = function(time_ms) {
	var me = this;
	this.id = window.setInterval(function() {
		me.run();
	},time_ms);
};
haxe.Timer.__name__ = ["haxe","Timer"];
haxe.Timer.delay = function(f,time_ms) {
	var t = new haxe.Timer(time_ms);
	t.run = function() {
		t.stop();
		f();
	};
	return t;
}
haxe.Timer.measure = function(f,pos) {
	var t0 = haxe.Timer.stamp();
	var r = f();
	haxe.Log.trace(haxe.Timer.stamp() - t0 + "s",pos);
	return r;
}
haxe.Timer.stamp = function() {
	return new Date().getTime() / 1000;
}
haxe.Timer.prototype = {
	run: function() {
	}
	,stop: function() {
		if(this.id == null) return;
		window.clearInterval(this.id);
		this.id = null;
	}
	,id: null
	,__class__: haxe.Timer
}
haxe.Unserializer = $hxClasses["haxe.Unserializer"] = function(buf) {
	this.buf = buf;
	this.length = buf.length;
	this.pos = 0;
	this.scache = new Array();
	this.cache = new Array();
	var r = haxe.Unserializer.DEFAULT_RESOLVER;
	if(r == null) {
		r = Type;
		haxe.Unserializer.DEFAULT_RESOLVER = r;
	}
	this.setResolver(r);
};
haxe.Unserializer.__name__ = ["haxe","Unserializer"];
haxe.Unserializer.initCodes = function() {
	var codes = new Array();
	var _g1 = 0, _g = haxe.Unserializer.BASE64.length;
	while(_g1 < _g) {
		var i = _g1++;
		codes[haxe.Unserializer.BASE64.charCodeAt(i)] = i;
	}
	return codes;
}
haxe.Unserializer.run = function(v) {
	return new haxe.Unserializer(v).unserialize();
}
haxe.Unserializer.prototype = {
	unserialize: function() {
		switch(this.buf.charCodeAt(this.pos++)) {
		case 110:
			return null;
		case 116:
			return true;
		case 102:
			return false;
		case 122:
			return 0;
		case 105:
			return this.readDigits();
		case 100:
			var p1 = this.pos;
			while(true) {
				var c = this.buf.charCodeAt(this.pos);
				if(c >= 43 && c < 58 || c == 101 || c == 69) this.pos++; else break;
			}
			return Std.parseFloat(HxOverrides.substr(this.buf,p1,this.pos - p1));
		case 121:
			var len = this.readDigits();
			if(this.buf.charCodeAt(this.pos++) != 58 || this.length - this.pos < len) throw "Invalid string length";
			var s = HxOverrides.substr(this.buf,this.pos,len);
			this.pos += len;
			s = StringTools.urlDecode(s);
			this.scache.push(s);
			return s;
		case 107:
			return Math.NaN;
		case 109:
			return Math.NEGATIVE_INFINITY;
		case 112:
			return Math.POSITIVE_INFINITY;
		case 97:
			var buf = this.buf;
			var a = new Array();
			this.cache.push(a);
			while(true) {
				var c = this.buf.charCodeAt(this.pos);
				if(c == 104) {
					this.pos++;
					break;
				}
				if(c == 117) {
					this.pos++;
					var n = this.readDigits();
					a[a.length + n - 1] = null;
				} else a.push(this.unserialize());
			}
			return a;
		case 111:
			var o = { };
			this.cache.push(o);
			this.unserializeObject(o);
			return o;
		case 114:
			var n = this.readDigits();
			if(n < 0 || n >= this.cache.length) throw "Invalid reference";
			return this.cache[n];
		case 82:
			var n = this.readDigits();
			if(n < 0 || n >= this.scache.length) throw "Invalid string reference";
			return this.scache[n];
		case 120:
			throw this.unserialize();
			break;
		case 99:
			var name = this.unserialize();
			var cl = this.resolver.resolveClass(name);
			if(cl == null) throw "Class not found " + name;
			var o = Type.createEmptyInstance(cl);
			this.cache.push(o);
			this.unserializeObject(o);
			return o;
		case 119:
			var name = this.unserialize();
			var edecl = this.resolver.resolveEnum(name);
			if(edecl == null) throw "Enum not found " + name;
			var e = this.unserializeEnum(edecl,this.unserialize());
			this.cache.push(e);
			return e;
		case 106:
			var name = this.unserialize();
			var edecl = this.resolver.resolveEnum(name);
			if(edecl == null) throw "Enum not found " + name;
			this.pos++;
			var index = this.readDigits();
			var tag = Type.getEnumConstructs(edecl)[index];
			if(tag == null) throw "Unknown enum index " + name + "@" + index;
			var e = this.unserializeEnum(edecl,tag);
			this.cache.push(e);
			return e;
		case 108:
			var l = new List();
			this.cache.push(l);
			var buf = this.buf;
			while(this.buf.charCodeAt(this.pos) != 104) l.add(this.unserialize());
			this.pos++;
			return l;
		case 98:
			var h = new Hash();
			this.cache.push(h);
			var buf = this.buf;
			while(this.buf.charCodeAt(this.pos) != 104) {
				var s = this.unserialize();
				h.set(s,this.unserialize());
			}
			this.pos++;
			return h;
		case 113:
			var h = new IntHash();
			this.cache.push(h);
			var buf = this.buf;
			var c = this.buf.charCodeAt(this.pos++);
			while(c == 58) {
				var i = this.readDigits();
				h.set(i,this.unserialize());
				c = this.buf.charCodeAt(this.pos++);
			}
			if(c != 104) throw "Invalid IntHash format";
			return h;
		case 118:
			var d = HxOverrides.strDate(HxOverrides.substr(this.buf,this.pos,19));
			this.cache.push(d);
			this.pos += 19;
			return d;
		case 115:
			var len = this.readDigits();
			var buf = this.buf;
			if(this.buf.charCodeAt(this.pos++) != 58 || this.length - this.pos < len) throw "Invalid bytes length";
			var codes = haxe.Unserializer.CODES;
			if(codes == null) {
				codes = haxe.Unserializer.initCodes();
				haxe.Unserializer.CODES = codes;
			}
			var i = this.pos;
			var rest = len & 3;
			var size = (len >> 2) * 3 + (rest >= 2?rest - 1:0);
			var max = i + (len - rest);
			var bytes = haxe.io.Bytes.alloc(size);
			var bpos = 0;
			while(i < max) {
				var c1 = codes[buf.charCodeAt(i++)];
				var c2 = codes[buf.charCodeAt(i++)];
				bytes.b[bpos++] = (c1 << 2 | c2 >> 4) & 255;
				var c3 = codes[buf.charCodeAt(i++)];
				bytes.b[bpos++] = (c2 << 4 | c3 >> 2) & 255;
				var c4 = codes[buf.charCodeAt(i++)];
				bytes.b[bpos++] = (c3 << 6 | c4) & 255;
			}
			if(rest >= 2) {
				var c1 = codes[buf.charCodeAt(i++)];
				var c2 = codes[buf.charCodeAt(i++)];
				bytes.b[bpos++] = (c1 << 2 | c2 >> 4) & 255;
				if(rest == 3) {
					var c3 = codes[buf.charCodeAt(i++)];
					bytes.b[bpos++] = (c2 << 4 | c3 >> 2) & 255;
				}
			}
			this.pos += len;
			this.cache.push(bytes);
			return bytes;
		case 67:
			var name = this.unserialize();
			var cl = this.resolver.resolveClass(name);
			if(cl == null) throw "Class not found " + name;
			var o = Type.createEmptyInstance(cl);
			this.cache.push(o);
			o.hxUnserialize(this);
			if(this.buf.charCodeAt(this.pos++) != 103) throw "Invalid custom data";
			return o;
		default:
		}
		this.pos--;
		throw "Invalid char " + this.buf.charAt(this.pos) + " at position " + this.pos;
	}
	,unserializeEnum: function(edecl,tag) {
		if(this.buf.charCodeAt(this.pos++) != 58) throw "Invalid enum format";
		var nargs = this.readDigits();
		if(nargs == 0) return Type.createEnum(edecl,tag);
		var args = new Array();
		while(nargs-- > 0) args.push(this.unserialize());
		return Type.createEnum(edecl,tag,args);
	}
	,unserializeObject: function(o) {
		while(true) {
			if(this.pos >= this.length) throw "Invalid object";
			if(this.buf.charCodeAt(this.pos) == 103) break;
			var k = this.unserialize();
			if(!js.Boot.__instanceof(k,String)) throw "Invalid object key";
			var v = this.unserialize();
			o[k] = v;
		}
		this.pos++;
	}
	,readDigits: function() {
		var k = 0;
		var s = false;
		var fpos = this.pos;
		while(true) {
			var c = this.buf.charCodeAt(this.pos);
			if(c != c) break;
			if(c == 45) {
				if(this.pos != fpos) break;
				s = true;
				this.pos++;
				continue;
			}
			if(c < 48 || c > 57) break;
			k = k * 10 + (c - 48);
			this.pos++;
		}
		if(s) k *= -1;
		return k;
	}
	,get: function(p) {
		return this.buf.charCodeAt(p);
	}
	,getResolver: function() {
		return this.resolver;
	}
	,setResolver: function(r) {
		if(r == null) this.resolver = { resolveClass : function(_) {
			return null;
		}, resolveEnum : function(_) {
			return null;
		}}; else this.resolver = r;
	}
	,resolver: null
	,scache: null
	,cache: null
	,length: null
	,pos: null
	,buf: null
	,__class__: haxe.Unserializer
}
if(!haxe.io) haxe.io = {}
haxe.io.Bytes = $hxClasses["haxe.io.Bytes"] = function(length,b) {
	this.length = length;
	this.b = b;
};
haxe.io.Bytes.__name__ = ["haxe","io","Bytes"];
haxe.io.Bytes.alloc = function(length) {
	var a = new Array();
	var _g = 0;
	while(_g < length) {
		var i = _g++;
		a.push(0);
	}
	return new haxe.io.Bytes(length,a);
}
haxe.io.Bytes.ofString = function(s) {
	var a = new Array();
	var _g1 = 0, _g = s.length;
	while(_g1 < _g) {
		var i = _g1++;
		var c = s.charCodeAt(i);
		if(c <= 127) a.push(c); else if(c <= 2047) {
			a.push(192 | c >> 6);
			a.push(128 | c & 63);
		} else if(c <= 65535) {
			a.push(224 | c >> 12);
			a.push(128 | c >> 6 & 63);
			a.push(128 | c & 63);
		} else {
			a.push(240 | c >> 18);
			a.push(128 | c >> 12 & 63);
			a.push(128 | c >> 6 & 63);
			a.push(128 | c & 63);
		}
	}
	return new haxe.io.Bytes(a.length,a);
}
haxe.io.Bytes.ofData = function(b) {
	return new haxe.io.Bytes(b.length,b);
}
haxe.io.Bytes.prototype = {
	getData: function() {
		return this.b;
	}
	,toHex: function() {
		var s = new StringBuf();
		var chars = [];
		var str = "0123456789abcdef";
		var _g1 = 0, _g = str.length;
		while(_g1 < _g) {
			var i = _g1++;
			chars.push(HxOverrides.cca(str,i));
		}
		var _g1 = 0, _g = this.length;
		while(_g1 < _g) {
			var i = _g1++;
			var c = this.b[i];
			s.b += String.fromCharCode(chars[c >> 4]);
			s.b += String.fromCharCode(chars[c & 15]);
		}
		return s.b;
	}
	,toString: function() {
		return this.readString(0,this.length);
	}
	,readString: function(pos,len) {
		if(pos < 0 || len < 0 || pos + len > this.length) throw haxe.io.Error.OutsideBounds;
		var s = "";
		var b = this.b;
		var fcc = String.fromCharCode;
		var i = pos;
		var max = pos + len;
		while(i < max) {
			var c = b[i++];
			if(c < 128) {
				if(c == 0) break;
				s += fcc(c);
			} else if(c < 224) s += fcc((c & 63) << 6 | b[i++] & 127); else if(c < 240) {
				var c2 = b[i++];
				s += fcc((c & 31) << 12 | (c2 & 127) << 6 | b[i++] & 127);
			} else {
				var c2 = b[i++];
				var c3 = b[i++];
				s += fcc((c & 15) << 18 | (c2 & 127) << 12 | c3 << 6 & 127 | b[i++] & 127);
			}
		}
		return s;
	}
	,compare: function(other) {
		var b1 = this.b;
		var b2 = other.b;
		var len = this.length < other.length?this.length:other.length;
		var _g = 0;
		while(_g < len) {
			var i = _g++;
			if(b1[i] != b2[i]) return b1[i] - b2[i];
		}
		return this.length - other.length;
	}
	,sub: function(pos,len) {
		if(pos < 0 || len < 0 || pos + len > this.length) throw haxe.io.Error.OutsideBounds;
		return new haxe.io.Bytes(len,this.b.slice(pos,pos + len));
	}
	,blit: function(pos,src,srcpos,len) {
		if(pos < 0 || srcpos < 0 || len < 0 || pos + len > this.length || srcpos + len > src.length) throw haxe.io.Error.OutsideBounds;
		var b1 = this.b;
		var b2 = src.b;
		if(b1 == b2 && pos > srcpos) {
			var i = len;
			while(i > 0) {
				i--;
				b1[i + pos] = b2[i + srcpos];
			}
			return;
		}
		var _g = 0;
		while(_g < len) {
			var i = _g++;
			b1[i + pos] = b2[i + srcpos];
		}
	}
	,set: function(pos,v) {
		this.b[pos] = v & 255;
	}
	,get: function(pos) {
		return this.b[pos];
	}
	,b: null
	,length: null
	,__class__: haxe.io.Bytes
}
haxe.io.Error = $hxClasses["haxe.io.Error"] = { __ename__ : ["haxe","io","Error"], __constructs__ : ["Blocked","Overflow","OutsideBounds","Custom"] }
haxe.io.Error.Blocked = ["Blocked",0];
haxe.io.Error.Blocked.toString = $estr;
haxe.io.Error.Blocked.__enum__ = haxe.io.Error;
haxe.io.Error.Overflow = ["Overflow",1];
haxe.io.Error.Overflow.toString = $estr;
haxe.io.Error.Overflow.__enum__ = haxe.io.Error;
haxe.io.Error.OutsideBounds = ["OutsideBounds",2];
haxe.io.Error.OutsideBounds.toString = $estr;
haxe.io.Error.OutsideBounds.__enum__ = haxe.io.Error;
haxe.io.Error.Custom = function(e) { var $x = ["Custom",3,e]; $x.__enum__ = haxe.io.Error; $x.toString = $estr; return $x; }
if(!haxe.xml) haxe.xml = {}
haxe.xml.Parser = $hxClasses["haxe.xml.Parser"] = function() { }
haxe.xml.Parser.__name__ = ["haxe","xml","Parser"];
haxe.xml.Parser.parse = function(str) {
	var doc = Xml.createDocument();
	haxe.xml.Parser.doParse(str,0,doc);
	return doc;
}
haxe.xml.Parser.doParse = function(str,p,parent) {
	if(p == null) p = 0;
	var xml = null;
	var state = 1;
	var next = 1;
	var aname = null;
	var start = 0;
	var nsubs = 0;
	var nbrackets = 0;
	var c = str.charCodeAt(p);
	while(!(c != c)) {
		switch(state) {
		case 0:
			switch(c) {
			case 10:case 13:case 9:case 32:
				break;
			default:
				state = next;
				continue;
			}
			break;
		case 1:
			switch(c) {
			case 60:
				state = 0;
				next = 2;
				break;
			default:
				start = p;
				state = 13;
				continue;
			}
			break;
		case 13:
			if(c == 60) {
				var child = Xml.createPCData(HxOverrides.substr(str,start,p - start));
				parent.addChild(child);
				nsubs++;
				state = 0;
				next = 2;
			}
			break;
		case 17:
			if(c == 93 && str.charCodeAt(p + 1) == 93 && str.charCodeAt(p + 2) == 62) {
				var child = Xml.createCData(HxOverrides.substr(str,start,p - start));
				parent.addChild(child);
				nsubs++;
				p += 2;
				state = 1;
			}
			break;
		case 2:
			switch(c) {
			case 33:
				if(str.charCodeAt(p + 1) == 91) {
					p += 2;
					if(HxOverrides.substr(str,p,6).toUpperCase() != "CDATA[") throw "Expected <![CDATA[";
					p += 5;
					state = 17;
					start = p + 1;
				} else if(str.charCodeAt(p + 1) == 68 || str.charCodeAt(p + 1) == 100) {
					if(HxOverrides.substr(str,p + 2,6).toUpperCase() != "OCTYPE") throw "Expected <!DOCTYPE";
					p += 8;
					state = 16;
					start = p + 1;
				} else if(str.charCodeAt(p + 1) != 45 || str.charCodeAt(p + 2) != 45) throw "Expected <!--"; else {
					p += 2;
					state = 15;
					start = p + 1;
				}
				break;
			case 63:
				state = 14;
				start = p;
				break;
			case 47:
				if(parent == null) throw "Expected node name";
				start = p + 1;
				state = 0;
				next = 10;
				break;
			default:
				state = 3;
				start = p;
				continue;
			}
			break;
		case 3:
			if(!(c >= 97 && c <= 122 || c >= 65 && c <= 90 || c >= 48 && c <= 57 || c == 58 || c == 46 || c == 95 || c == 45)) {
				if(p == start) throw "Expected node name";
				xml = Xml.createElement(HxOverrides.substr(str,start,p - start));
				parent.addChild(xml);
				state = 0;
				next = 4;
				continue;
			}
			break;
		case 4:
			switch(c) {
			case 47:
				state = 11;
				nsubs++;
				break;
			case 62:
				state = 9;
				nsubs++;
				break;
			default:
				state = 5;
				start = p;
				continue;
			}
			break;
		case 5:
			if(!(c >= 97 && c <= 122 || c >= 65 && c <= 90 || c >= 48 && c <= 57 || c == 58 || c == 46 || c == 95 || c == 45)) {
				var tmp;
				if(start == p) throw "Expected attribute name";
				tmp = HxOverrides.substr(str,start,p - start);
				aname = tmp;
				if(xml.exists(aname)) throw "Duplicate attribute";
				state = 0;
				next = 6;
				continue;
			}
			break;
		case 6:
			switch(c) {
			case 61:
				state = 0;
				next = 7;
				break;
			default:
				throw "Expected =";
			}
			break;
		case 7:
			switch(c) {
			case 34:case 39:
				state = 8;
				start = p;
				break;
			default:
				throw "Expected \"";
			}
			break;
		case 8:
			if(c == str.charCodeAt(start)) {
				var val = HxOverrides.substr(str,start + 1,p - start - 1);
				xml.set(aname,val);
				state = 0;
				next = 4;
			}
			break;
		case 9:
			p = haxe.xml.Parser.doParse(str,p,xml);
			start = p;
			state = 1;
			break;
		case 11:
			switch(c) {
			case 62:
				state = 1;
				break;
			default:
				throw "Expected >";
			}
			break;
		case 12:
			switch(c) {
			case 62:
				if(nsubs == 0) parent.addChild(Xml.createPCData(""));
				return p;
			default:
				throw "Expected >";
			}
			break;
		case 10:
			if(!(c >= 97 && c <= 122 || c >= 65 && c <= 90 || c >= 48 && c <= 57 || c == 58 || c == 46 || c == 95 || c == 45)) {
				if(start == p) throw "Expected node name";
				var v = HxOverrides.substr(str,start,p - start);
				if(v != parent.getNodeName()) throw "Expected </" + parent.getNodeName() + ">";
				state = 0;
				next = 12;
				continue;
			}
			break;
		case 15:
			if(c == 45 && str.charCodeAt(p + 1) == 45 && str.charCodeAt(p + 2) == 62) {
				parent.addChild(Xml.createComment(HxOverrides.substr(str,start,p - start)));
				p += 2;
				state = 1;
			}
			break;
		case 16:
			if(c == 91) nbrackets++; else if(c == 93) nbrackets--; else if(c == 62 && nbrackets == 0) {
				parent.addChild(Xml.createDocType(HxOverrides.substr(str,start,p - start)));
				state = 1;
			}
			break;
		case 14:
			if(c == 63 && str.charCodeAt(p + 1) == 62) {
				p++;
				var str1 = HxOverrides.substr(str,start + 1,p - start - 2);
				parent.addChild(Xml.createProlog(str1));
				state = 1;
			}
			break;
		}
		c = str.charCodeAt(++p);
	}
	if(state == 1) {
		start = p;
		state = 13;
	}
	if(state == 13) {
		if(p != start || nsubs == 0) parent.addChild(Xml.createPCData(HxOverrides.substr(str,start,p - start)));
		return p;
	}
	throw "Unexpected end";
}
haxe.xml.Parser.isValidChar = function(c) {
	return c >= 97 && c <= 122 || c >= 65 && c <= 90 || c >= 48 && c <= 57 || c == 58 || c == 46 || c == 95 || c == 45;
}
var js = js || {}
js.Boot = $hxClasses["js.Boot"] = function() { }
js.Boot.__name__ = ["js","Boot"];
js.Boot.__unhtml = function(s) {
	return s.split("&").join("&amp;").split("<").join("&lt;").split(">").join("&gt;");
}
js.Boot.__trace = function(v,i) {
	var msg = i != null?i.fileName + ":" + i.lineNumber + ": ":"";
	msg += js.Boot.__string_rec(v,"");
	var d;
	if(typeof(document) != "undefined" && (d = document.getElementById("haxe:trace")) != null) d.innerHTML += js.Boot.__unhtml(msg) + "<br/>"; else if(typeof(console) != "undefined" && console.log != null) console.log(msg);
}
js.Boot.__clear_trace = function() {
	var d = document.getElementById("haxe:trace");
	if(d != null) d.innerHTML = "";
}
js.Boot.isClass = function(o) {
	return o.__name__;
}
js.Boot.isEnum = function(e) {
	return e.__ename__;
}
js.Boot.getClass = function(o) {
	return o.__class__;
}
js.Boot.__string_rec = function(o,s) {
	if(o == null) return "null";
	if(s.length >= 5) return "<...>";
	var t = typeof(o);
	if(t == "function" && (o.__name__ || o.__ename__)) t = "object";
	switch(t) {
	case "object":
		if(o instanceof Array) {
			if(o.__enum__) {
				if(o.length == 2) return o[0];
				var str = o[0] + "(";
				s += "\t";
				var _g1 = 2, _g = o.length;
				while(_g1 < _g) {
					var i = _g1++;
					if(i != 2) str += "," + js.Boot.__string_rec(o[i],s); else str += js.Boot.__string_rec(o[i],s);
				}
				return str + ")";
			}
			var l = o.length;
			var i;
			var str = "[";
			s += "\t";
			var _g = 0;
			while(_g < l) {
				var i1 = _g++;
				str += (i1 > 0?",":"") + js.Boot.__string_rec(o[i1],s);
			}
			str += "]";
			return str;
		}
		var tostr;
		try {
			tostr = o.toString;
		} catch( e ) {
			return "???";
		}
		if(tostr != null && tostr != Object.toString) {
			var s2 = o.toString();
			if(s2 != "[object Object]") return s2;
		}
		var k = null;
		var str = "{\n";
		s += "\t";
		var hasp = o.hasOwnProperty != null;
		for( var k in o ) { ;
		if(hasp && !o.hasOwnProperty(k)) {
			continue;
		}
		if(k == "prototype" || k == "__class__" || k == "__super__" || k == "__interfaces__" || k == "__properties__") {
			continue;
		}
		if(str.length != 2) str += ", \n";
		str += s + k + " : " + js.Boot.__string_rec(o[k],s);
		}
		s = s.substring(1);
		str += "\n" + s + "}";
		return str;
	case "function":
		return "<function>";
	case "string":
		return o;
	default:
		return String(o);
	}
}
js.Boot.__interfLoop = function(cc,cl) {
	if(cc == null) return false;
	if(cc == cl) return true;
	var intf = cc.__interfaces__;
	if(intf != null) {
		var _g1 = 0, _g = intf.length;
		while(_g1 < _g) {
			var i = _g1++;
			var i1 = intf[i];
			if(i1 == cl || js.Boot.__interfLoop(i1,cl)) return true;
		}
	}
	return js.Boot.__interfLoop(cc.__super__,cl);
}
js.Boot.__instanceof = function(o,cl) {
	try {
		if(o instanceof cl) {
			if(cl == Array) return o.__enum__ == null;
			return true;
		}
		if(js.Boot.__interfLoop(o.__class__,cl)) return true;
	} catch( e ) {
		if(cl == null) return false;
	}
	switch(cl) {
	case Int:
		return Math.ceil(o%2147483648.0) === o;
	case Float:
		return typeof(o) == "number";
	case Bool:
		return o === true || o === false;
	case String:
		return typeof(o) == "string";
	case Dynamic:
		return true;
	default:
		if(o == null) return false;
		if(cl == Class && o.__name__ != null) return true; else null;
		if(cl == Enum && o.__ename__ != null) return true; else null;
		return o.__enum__ == cl;
	}
}
js.Boot.__cast = function(o,t) {
	if(js.Boot.__instanceof(o,t)) return o; else throw "Cannot cast " + Std.string(o) + " to " + Std.string(t);
}
var xmlTools = xmlTools || {}
xmlTools.E4X = $hxClasses["xmlTools.E4X"] = function(value) {
	if(value != null) this.setXml(value);
};
xmlTools.E4X.__name__ = ["xmlTools","E4X"];
xmlTools.E4X.getNew = function(xml) {
	var ret;
	if(xmlTools.E4X._pool.length > 0) {
		ret = xmlTools.E4X._pool.pop();
		ret.setXml(xml);
	} else ret = new xmlTools.E4X(xml);
	return ret;
}
xmlTools.E4X.doRetNodes = function(e4X) {
	var ret = e4X.retNodes();
	xmlTools.E4X._pool.push(e4X);
	return ret;
}
xmlTools.E4X.doRetAttribs = function(e4X) {
	var ret = e4X.retAttribs();
	xmlTools.E4X._pool.push(e4X);
	return ret;
}
xmlTools.E4X.doRetText = function(e4X) {
	var ret = e4X.retText();
	xmlTools.E4X._pool.push(e4X);
	return ret;
}
xmlTools.E4X.doHasNodes = function(e4X) {
	var ret = e4X.hasNodes();
	xmlTools.E4X._pool.push(e4X);
	return ret;
}
xmlTools.E4X.doHasAttribs = function(e4X) {
	var ret = e4X.hasAttribs();
	xmlTools.E4X._pool.push(e4X);
	return ret;
}
xmlTools.E4X.doHasText = function(e4X) {
	var ret = e4X.hasText();
	xmlTools.E4X._pool.push(e4X);
	return ret;
}
xmlTools.E4X.doHas = function(e4X) {
	var ret = e4X.has();
	xmlTools.E4X._pool.push(e4X);
	return ret;
}
xmlTools.E4X.prototype = {
	has: function() {
		switch( (this._retState)[1] ) {
		case 0:
			return this.hasNodes();
		case 1:
			return this.hasAttribs();
		case 2:
			return this.hasText();
		}
		throw "Invalid return code";
	}
	,hasText: function() {
		return this._texts != null && !this._texts.isEmpty();
	}
	,hasAttribs: function() {
		return this._attributes != null && !this._attributes.isEmpty();
	}
	,hasNodes: function() {
		return this._nodes != null && !this._nodes.isEmpty();
	}
	,retText: function() {
		return this._texts.iterator();
	}
	,retAttribs: function() {
		return this._attributes.iterator();
	}
	,retNodes: function() {
		return this._nodes.iterator();
	}
	,text: function(x) {
		var it = this._nodes.iterator();
		var itt;
		var newText = new List();
		var newNodes = new List();
		var node;
		var vnode;
		var tnode;
		while(it.hasNext()) {
			node = it.next();
			var type = node.nodeType;
			if(type == Xml.Element) {
				itt = node.iterator();
				while(itt.hasNext()) {
					vnode = itt.next();
					var subType = vnode.nodeType;
					if(subType == Xml.CData || subType == Xml.PCData) {
						tnode = vnode.getNodeValue();
						if(x != null) {
							if(x(tnode,vnode)) {
								newText.add(tnode);
								newNodes.add(vnode);
							}
						} else {
							newText.add(tnode);
							newNodes.add(vnode);
						}
					}
				}
			} else if(type == Xml.CData || type == Xml.PCData) {
				tnode = node.getNodeValue();
				if(x != null) {
					if(x(tnode,node)) {
						newText.add(tnode);
						newNodes.add(node);
					}
				} else {
					newText.add(tnode);
					newNodes.add(node);
				}
			}
		}
		this._nodes = newNodes;
		this._texts = newText;
		this._retState = xmlTools.E4XReturnState.Text;
		return this;
	}
	,a: function(x) {
		var it = this._nodes.iterator();
		var ait;
		var node;
		var atts = null;
		var newAttribs = new List();
		var s;
		var vs;
		var newNodes = new List();
		while(it.hasNext()) {
			node = it.next();
			if(node.nodeType != Xml.Element) continue;
			ait = node.attributes();
			atts = null;
			while(ait.hasNext()) if(x == null) {
				if(atts == null) atts = new Hash();
				s = ait.next();
				atts.set(s,node.get(s));
				newNodes.add(node);
			} else {
				s = ait.next();
				vs = node.get(s);
				if(x(s,vs,node)) {
					if(atts == null) atts = new Hash();
					atts.set(s,vs);
					newNodes.add(node);
				}
			}
			if(atts != null) newAttribs.add(atts);
		}
		this._attributes = newAttribs;
		this._nodes = newNodes;
		this._retState = xmlTools.E4XReturnState.Attribute;
		return this;
	}
	,ances: function(x) {
		var it = this._nodes.iterator();
		var itw;
		var newNodes = new List();
		var node;
		var pnode;
		var i = 0;
		while(it.hasNext()) {
			node = it.next();
			pnode = node.getParent();
			if(pnode != null) {
				if(!Lambda.has(newNodes,pnode)) {
					if(x != null) {
						if(x(node,i)) newNodes.add(node);
					} else newNodes.add(node);
				}
			}
		}
		this._nodes = newNodes;
		this._retState = xmlTools.E4XReturnState.Node;
		return this;
	}
	,desc: function(x) {
		var it = this._nodes.iterator();
		var newNodes = new List();
		var node;
		var iterators = new Array();
		if(it.hasNext()) while(true) {
			node = it.next();
			if(x != null) {
				if(x(node)) newNodes.add(node);
			} else newNodes.add(node);
			if(node.nodeType == Xml.Element) {
				var subIt = node.iterator();
				if(subIt.hasNext()) {
					if(it.hasNext()) iterators.push(it);
					it = subIt;
				}
			}
			if(!it.hasNext()) {
				if(iterators.length == 0) break; else it = iterators.pop();
			}
		}
		this._nodes = newNodes;
		this._retState = xmlTools.E4XReturnState.Node;
		return this;
	}
	,child: function(x) {
		var it = this._nodes.iterator();
		var subIt;
		var a = new List();
		var node;
		var i;
		while(it.hasNext()) {
			node = it.next();
			if(node.nodeType == Xml.Element) {
				i = 0;
				subIt = node.iterator();
				while(subIt.hasNext()) {
					node = subIt.next();
					if(x != null) {
						if(x(node,i)) a.add(node);
					} else a.add(node);
					i++;
				}
			}
		}
		this._nodes = a;
		this._retState = xmlTools.E4XReturnState.Node;
		return this;
	}
	,setXml: function(xml) {
		this._attributes = new List();
		this._texts = new List();
		this._root = xml;
		this._retState = xmlTools.E4XReturnState.Node;
		this._nodes = new List();
		if(xml != null && xml.nodeType == Xml.Document) this._nodes.add(xml.firstElement()); else if(xml != null) this._nodes.add(xml);
	}
	,_retState: null
	,_texts: null
	,_attributes: null
	,_nodes: null
	,_parent: null
	,_root: null
	,__class__: xmlTools.E4X
}
xmlTools.E4XReturnState = $hxClasses["xmlTools.E4XReturnState"] = { __ename__ : ["xmlTools","E4XReturnState"], __constructs__ : ["Node","Attribute","Text"] }
xmlTools.E4XReturnState.Node = ["Node",0];
xmlTools.E4XReturnState.Node.toString = $estr;
xmlTools.E4XReturnState.Node.__enum__ = xmlTools.E4XReturnState;
xmlTools.E4XReturnState.Attribute = ["Attribute",1];
xmlTools.E4XReturnState.Attribute.toString = $estr;
xmlTools.E4XReturnState.Attribute.__enum__ = xmlTools.E4XReturnState;
xmlTools.E4XReturnState.Text = ["Text",2];
xmlTools.E4XReturnState.Text.toString = $estr;
xmlTools.E4XReturnState.Text.__enum__ = xmlTools.E4XReturnState;
function $iterator(o) { if( o instanceof Array ) return function() { return HxOverrides.iter(o); }; return typeof(o.iterator) == 'function' ? $bind(o,o.iterator) : o.iterator; };
var $_;
function $bind(o,m) { var f = function(){ return f.method.apply(f.scope, arguments); }; f.scope = o; f.method = m; return f; };
if(Array.prototype.indexOf) HxOverrides.remove = function(a,o) {
	var i = a.indexOf(o);
	if(i == -1) return false;
	a.splice(i,1);
	return true;
}; else null;
Math.__name__ = ["Math"];
Math.NaN = Number.NaN;
Math.NEGATIVE_INFINITY = Number.NEGATIVE_INFINITY;
Math.POSITIVE_INFINITY = Number.POSITIVE_INFINITY;
$hxClasses.Math = Math;
Math.isFinite = function(i) {
	return isFinite(i);
};
Math.isNaN = function(i) {
	return isNaN(i);
};
String.prototype.__class__ = $hxClasses.String = String;
String.__name__ = ["String"];
Array.prototype.__class__ = $hxClasses.Array = Array;
Array.__name__ = ["Array"];
Date.prototype.__class__ = $hxClasses.Date = Date;
Date.__name__ = ["Date"];
var Int = $hxClasses.Int = { __name__ : ["Int"]};
var Dynamic = $hxClasses.Dynamic = { __name__ : ["Dynamic"]};
var Float = $hxClasses.Float = Number;
Float.__name__ = ["Float"];
var Bool = $hxClasses.Bool = Boolean;
Bool.__ename__ = ["Bool"];
var Class = $hxClasses.Class = { __name__ : ["Class"]};
var Enum = { };
var Void = $hxClasses.Void = { __ename__ : ["Void"]};
Xml.Element = "element";
Xml.PCData = "pcdata";
Xml.CData = "cdata";
Xml.Comment = "comment";
Xml.DocType = "doctype";
Xml.Prolog = "prolog";
Xml.Document = "document";
haxe.Resource.content = [{ name : "sample-xml", data : "s6160:PD94bWwgdmVyc2lvbj0iMS4wIj8%DQo8bnV0cml0aW9uPg0KDQo8ZGFpbHktdmFsdWVzPg0KCTx0b3RhbC1mYXQgdW5pdHM9ImciPjY1PC90b3RhbC1mYXQ%DQoJPHNhdHVyYXRlZC1mYXQgdW5pdHM9ImciPjIwPC9zYXR1cmF0ZWQtZmF0Pg0KCTxjaG9sZXN0ZXJvbCB1bml0cz0ibWciPjMwMDwvY2hvbGVzdGVyb2w%DQoJPHNvZGl1bSB1bml0cz0ibWciPjI0MDA8L3NvZGl1bT4NCgk8Y2FyYiB1bml0cz0iZyI%MzAwPC9jYXJiPg0KCTxmaWJlciB1bml0cz0iZyI%MjU8L2ZpYmVyPg0KCTxwcm90ZWluIHVuaXRzPSJnIj41MDwvcHJvdGVpbj4NCjwvZGFpbHktdmFsdWVzPg0KDQo8Zm9vZD4NCgk8bmFtZT5Bdm9jYWRvIERpcDwvbmFtZT4NCgk8bWZyPlN1bm55ZGFsZTwvbWZyPg0KCTxzZXJ2aW5nIHVuaXRzPSJnIj4yOTwvc2VydmluZz4NCgk8Y2Fsb3JpZXMgdG90YWw9IjExMCIgZmF0PSIxMDAiLz4NCgk8dG90YWwtZmF0PjExPC90b3RhbC1mYXQ%DQoJPHNhdHVyYXRlZC1mYXQ%Mzwvc2F0dXJhdGVkLWZhdD4NCgk8Y2hvbGVzdGVyb2w%NTwvY2hvbGVzdGVyb2w%DQoJPHNvZGl1bT4yMTA8L3NvZGl1bT4NCgk8Y2FyYj4yPC9jYXJiPg0KCTxmaWJlcj4wPC9maWJlcj4NCgk8cHJvdGVpbj4xPC9wcm90ZWluPg0KCTx2aXRhbWlucz4NCgkJPGE%MDwvYT4NCgkJPGM%MDwvYz4NCgk8L3ZpdGFtaW5zPg0KCTxtaW5lcmFscz4NCgkJPGNhPjA8L2NhPg0KCQk8ZmU%MDwvZmU%DQoJPC9taW5lcmFscz4NCjwvZm9vZD4NCg0KPGZvb2Q%DQoJPG5hbWU%QmFnZWxzLCBOZXcgWW9yayBTdHlsZSA8L25hbWU%DQoJPG1mcj5UaG9tcHNvbjwvbWZyPg0KCTxzZXJ2aW5nIHVuaXRzPSJnIj4xMDQ8L3NlcnZpbmc%DQoJPGNhbG9yaWVzIHRvdGFsPSIzMDAiIGZhdD0iMzUiLz4NCgk8dG90YWwtZmF0PjQ8L3RvdGFsLWZhdD4NCgk8c2F0dXJhdGVkLWZhdD4xPC9zYXR1cmF0ZWQtZmF0Pg0KCTxjaG9sZXN0ZXJvbD4wPC9jaG9sZXN0ZXJvbD4NCgk8c29kaXVtPjUxMDwvc29kaXVtPg0KCTxjYXJiPjU0PC9jYXJiPg0KCTxmaWJlcj4zPC9maWJlcj4NCgk8cHJvdGVpbj4xMTwvcHJvdGVpbj4NCgk8dml0YW1pbnM%DQoJCTxhPjA8L2E%DQoJCTxjPjA8L2M%DQoJPC92aXRhbWlucz4NCgk8bWluZXJhbHM%DQoJCTxjYT44PC9jYT4NCgkJPGZlPjIwPC9mZT4NCgk8L21pbmVyYWxzPg0KPC9mb29kPg0KDQo8Zm9vZD4NCgk8bmFtZT5CZWVmIEZyYW5rZnVydGVyLCBRdWFydGVyIFBvdW5kIDwvbmFtZT4NCgk8bWZyPkFybWl0YWdlPC9tZnI%DQoJPHNlcnZpbmcgdW5pdHM9ImciPjExNTwvc2VydmluZz4NCgk8Y2Fsb3JpZXMgdG90YWw9IjM3MCIgZmF0PSIyOTAiLz4NCgk8dG90YWwtZmF0PjMyPC90b3RhbC1mYXQ%DQoJPHNhdHVyYXRlZC1mYXQ%MTU8L3NhdHVyYXRlZC1mYXQ%DQoJPGNob2xlc3Rlcm9sPjY1PC9jaG9sZXN0ZXJvbD4NCgk8c29kaXVtPjExMDA8L3NvZGl1bT4NCgk8Y2FyYj44PC9jYXJiPg0KCTxmaWJlcj4wPC9maWJlcj4NCgk8cHJvdGVpbj4xMzwvcHJvdGVpbj4NCgk8dml0YW1pbnM%DQoJCTxhPjA8L2E%DQoJCTxjPjI8L2M%DQoJPC92aXRhbWlucz4NCgk8bWluZXJhbHM%DQoJCTxjYT4xPC9jYT4NCgkJPGZlPjY8L2ZlPg0KCTwvbWluZXJhbHM%DQo8L2Zvb2Q%DQoNCjxmb29kPg0KCTxuYW1lPkNoaWNrZW4gUG90IFBpZTwvbmFtZT4NCgk8bWZyPkxha2Vzb248L21mcj4NCgk8c2VydmluZyB1bml0cz0iZyI%MTk4PC9zZXJ2aW5nPg0KCTxjYWxvcmllcyB0b3RhbD0iNDEwIiBmYXQ9IjIwMCIvPg0KCTx0b3RhbC1mYXQ%MjI8L3RvdGFsLWZhdD4NCgk8c2F0dXJhdGVkLWZhdD45PC9zYXR1cmF0ZWQtZmF0Pg0KCTxjaG9sZXN0ZXJvbD4yNTwvY2hvbGVzdGVyb2w%DQoJPHNvZGl1bT44MTA8L3NvZGl1bT4NCgk8Y2FyYj40MjwvY2FyYj4NCgk8ZmliZXI%MjwvZmliZXI%DQoJPHByb3RlaW4%MTA8L3Byb3RlaW4%DQoJPHZpdGFtaW5zPg0KCQk8YT4yMDwvYT4NCgkJPGM%MjwvYz4NCgk8L3ZpdGFtaW5zPg0KCTxtaW5lcmFscz4NCgkJPGNhPjI8L2NhPg0KCQk8ZmU%MTA8L2ZlPg0KCTwvbWluZXJhbHM%DQo8L2Zvb2Q%DQoNCjxmb29kPg0KCTxuYW1lPkNvbGUgU2xhdzwvbmFtZT4NCgk8bWZyPkZyZXNoIFF1aWNrPC9tZnI%DQoJPHNlcnZpbmcgdW5pdHM9IiBjdXAiPjEuNTwvc2VydmluZz4NCgk8Y2Fsb3JpZXMgdG90YWw9IjIwIiBmYXQ9IjAiLz4NCgk8dG90YWwtZmF0PjA8L3RvdGFsLWZhdD4NCgk8c2F0dXJhdGVkLWZhdD4wPC9zYXR1cmF0ZWQtZmF0Pg0KCTxjaG9sZXN0ZXJvbD4wPC9jaG9sZXN0ZXJvbD4NCgk8c29kaXVtPjE1PC9zb2RpdW0%DQoJPGNhcmI%NTwvY2FyYj4NCgk8ZmliZXI%MjwvZmliZXI%DQoJPHByb3RlaW4%MTwvcHJvdGVpbj4NCgk8dml0YW1pbnM%DQoJCTxhPjMwPC9hPg0KCQk8Yz40NTwvYz4NCgk8L3ZpdGFtaW5zPg0KCTxtaW5lcmFscz4NCgkJPGNhPjQ8L2NhPg0KCQk8ZmU%MjwvZmU%DQoJPC9taW5lcmFscz4NCjwvZm9vZD4NCg0KPGZvb2Q%DQoJPG5hbWU%RWdnczwvbmFtZT4NCgk8bWZyPkdvb2RwYXRoPC9tZnI%DQoJPHNlcnZpbmcgdW5pdHM9ImciPjUwPC9zZXJ2aW5nPg0KCTxjYWxvcmllcyB0b3RhbD0iNzAiIGZhdD0iNDAiLz4NCgk8dG90YWwtZmF0PjQuNTwvdG90YWwtZmF0Pg0KCTxzYXR1cmF0ZWQtZmF0PjEuNTwvc2F0dXJhdGVkLWZhdD4NCgk8Y2hvbGVzdGVyb2w%MjE1PC9jaG9sZXN0ZXJvbD4NCgk8c29kaXVtPjY1PC9zb2RpdW0%DQoJPGNhcmI%MTwvY2FyYj4NCgk8ZmliZXI%MDwvZmliZXI%DQoJPHByb3RlaW4%NjwvcHJvdGVpbj4NCgk8dml0YW1pbnM%DQoJCTxhPjY8L2E%DQoJCTxjPjA8L2M%DQoJPC92aXRhbWlucz4NCgk8bWluZXJhbHM%DQoJCTxjYT4yPC9jYT4NCgkJPGZlPjQ8L2ZlPg0KCTwvbWluZXJhbHM%DQo8L2Zvb2Q%DQoNCjxmb29kPg0KCTxuYW1lPkhhemVsbnV0IFNwcmVhZDwvbmFtZT4NCgk8bWZyPkZlcnJlaXJhPC9tZnI%DQoJPHNlcnZpbmcgdW5pdHM9InRic3AiPjI8L3NlcnZpbmc%DQoJPGNhbG9yaWVzIHRvdGFsPSIyMDAiIGZhdD0iOTAiLz4NCgk8dG90YWwtZmF0PjEwPC90b3RhbC1mYXQ%DQoJPHNhdHVyYXRlZC1mYXQ%Mjwvc2F0dXJhdGVkLWZhdD4NCgk8Y2hvbGVzdGVyb2w%MDwvY2hvbGVzdGVyb2w%DQoJPHNvZGl1bT4yMDwvc29kaXVtPg0KCTxjYXJiPjIzPC9jYXJiPg0KCTxmaWJlcj4yPC9maWJlcj4NCgk8cHJvdGVpbj4zPC9wcm90ZWluPg0KCTx2aXRhbWlucz4NCgkJPGE%MDwvYT4NCgkJPGM%MDwvYz4NCgk8L3ZpdGFtaW5zPg0KCTxtaW5lcmFscz4NCgkJPGNhPjY8L2NhPg0KCQk8ZmU%NDwvZmU%DQoJPC9taW5lcmFscz4NCjwvZm9vZD4NCg0KPGZvb2Q%DQoJPG5hbWU%UG90YXRvIENoaXBzPC9uYW1lPg0KCTxtZnI%TGVlczwvbWZyPg0KCTxzZXJ2aW5nIHVuaXRzPSJnIj4yODwvc2VydmluZz4NCgk8Y2Fsb3JpZXMgdG90YWw9IjE1MCIgZmF0PSI5MCIvPg0KCTx0b3RhbC1mYXQ%MTA8L3RvdGFsLWZhdD4NCgk8c2F0dXJhdGVkLWZhdD4zPC9zYXR1cmF0ZWQtZmF0Pg0KCTxjaG9sZXN0ZXJvbD4wPC9jaG9sZXN0ZXJvbD4NCgk8c29kaXVtPjE4MDwvc29kaXVtPg0KCTxjYXJiPjE1PC9jYXJiPg0KCTxmaWJlcj4xPC9maWJlcj4NCgk8cHJvdGVpbj4yPC9wcm90ZWluPg0KCTx2aXRhbWlucz4NCgkJPGE%MDwvYT4NCgkJPGM%MTA8L2M%DQoJPC92aXRhbWlucz4NCgk8bWluZXJhbHM%DQoJCTxjYT4wPC9jYT4NCgkJPGZlPjA8L2ZlPg0KCTwvbWluZXJhbHM%DQo8L2Zvb2Q%DQoNCjxmb29kPg0KCTxuYW1lPlNveSBQYXR0aWVzLCBHcmlsbGVkPC9uYW1lPg0KCTxtZnI%R2FyZGVucHJvZHVjdHM8L21mcj4NCgk8c2VydmluZyB1bml0cz0iZyI%OTY8L3NlcnZpbmc%DQoJPGNhbG9yaWVzIHRvdGFsPSIxNjAiIGZhdD0iNDUiLz4NCgk8dG90YWwtZmF0PjU8L3RvdGFsLWZhdD4NCgk8c2F0dXJhdGVkLWZhdD4wPC9zYXR1cmF0ZWQtZmF0Pg0KCTxjaG9sZXN0ZXJvbD4wPC9jaG9sZXN0ZXJvbD4NCgk8c29kaXVtPjQyMDwvc29kaXVtPg0KCTxjYXJiPjEwPC9jYXJiPg0KCTxmaWJlcj40PC9maWJlcj4NCgk8cHJvdGVpbj45PC9wcm90ZWluPg0KCTx2aXRhbWlucz4NCgkJPGE%MDwvYT4NCgkJPGM%MDwvYz4NCgk8L3ZpdGFtaW5zPg0KCTxtaW5lcmFscz4NCgkJPGNhPjA8L2NhPg0KCQk8ZmU%MDwvZmU%DQoJPC9taW5lcmFscz4NCjwvZm9vZD4NCg0KPGZvb2Q%DQoJPG5hbWU%VHJ1ZmZsZXMsIERhcmsgQ2hvY29sYXRlPC9uYW1lPg0KCTxtZnI%THluZG9uJ3M8L21mcj4NCgk8c2VydmluZyB1bml0cz0iZyI%Mzk8L3NlcnZpbmc%DQoJPGNhbG9yaWVzIHRvdGFsPSIyMjAiIGZhdD0iMTcwIi8%DQoJPHRvdGFsLWZhdD4xOTwvdG90YWwtZmF0Pg0KCTxzYXR1cmF0ZWQtZmF0PjE0PC9zYXR1cmF0ZWQtZmF0Pg0KCTxjaG9sZXN0ZXJvbD4yNTwvY2hvbGVzdGVyb2w%DQoJPHNvZGl1bT4xMDwvc29kaXVtPg0KCTxjYXJiPjE2PC9jYXJiPg0KCTxmaWJlcj4xPC9maWJlcj4NCgk8cHJvdGVpbj4xPC9wcm90ZWluPg0KCTx2aXRhbWlucz4NCgkJPGE%MDwvYT4NCgkJPGM%MDwvYz4NCgk8L3ZpdGFtaW5zPg0KCTxtaW5lcmFscz4NCgkJPGNhPjA8L2NhPg0KCQk8ZmU%MDwvZmU%DQoJPC9taW5lcmFscz4NCjwvZm9vZD4NCg0KPC9udXRyaXRpb24%"}];
PerfTestRunner.SECOND_FACTOR = 1;
haxe.Unserializer.DEFAULT_RESOLVER = Type;
haxe.Unserializer.BASE64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789%:";
haxe.Unserializer.CODES = null;
xmlTools.E4X._pool = new Array();
TestE4XPerformance.main();

class BaseDOMManager

	injectCSS: (target, css) ->
		#console.log css
		for i of css
			do (i) =>
				target.style[i] = css[i]

	getOffset: (ele) =>
		o = {x:0,y:0}
		while ele
			if ele.nodeName[0]!='#'
				o.x += ele.offsetLeft-ele.scrollLeft
				o.y += ele.offsetTop-ele.scrollTop
			ele = ele.parentNode
		o

	addEvent: (target, name,func) ->
		if target.attachEvent
			return target.attachEvent 'on'+name, func
		else
			return target.addEventListener name, func

	ajaxRequest: (url,callBack,type) ->
		if type==undefined
			#type = 'json'
			type = 'text'
		request = null
		nativeEval = window['eval']
		if window.ActiveXObject
			try
				request = new ActiveXObject "Msxml2.XMLHTTP"
			catch err
				# ...
			if request == null
				try
					request = new ActiveXObject "Microsoft.XMLHTTPP"
				catch e
					# ...
		else
			try
				request = new XMLHttpRequest()
			catch err
				# ...

		if request
			request.onreadystatechange = () =>
				if request.readyState==4
					if request.status==200
						if type=='json'
							callBack nativeEval "(" + request.responseText + ")"
						else
							callBack request #.responseText
			request.open "GET", url
			request.send null

		return request

	parseDOM: (xmlString) ->
		if window.DOMParser
			parser=new DOMParser()
			xmlDoc=parser.parseFromString xmlString,"text/xml"
		else
			xmlDoc=new ActiveXObject "Microsoft.XMLDOM"
			xmlDoc.async = false
			xmlDoc.loadXML xmlString
		xmlDoc

	trim: (string) ->
		return string.replace /^\s+|\s+$/g, ''


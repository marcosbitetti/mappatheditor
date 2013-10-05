ace = ace or null

if console == undefined
	console = {
		log: (str) ->
			str
	}

class EditorView extends BaseDOMManager

	class Point
		@id = 0

		@size = 4

		constructor: (@x,@y) ->
			@_id = Point.id
			Point.id += 1
			@links = []
			@id = null

		connect: (pt) ->
			if not @hasLink pt
				@links.push pt
				pt.links.push this

		hasLink: (pt) ->
			v = false
			for j in @links
				do (j) =>
					if j._id == pt._id
						v = true
			v
		removeReferences: ()->
			for j in @links
				do (j) =>
					j.links.splice j.links.indexOf(this), 1


	constructor: (name, @cenario) ->
		@canvas = document.getElementById name

		@addEvent @canvas, 'mousedown', @mousedown
		@addEvent @canvas, 'mouseup', @mouseup
		@addEvent @canvas, 'mousemove', @mousemove
		@isDown = false
		@isUp = false
		@isDraggin = false
		@isConnect = false

		@points = []

		# ui
		@addEvent document.getElementById('btSalvar'), 'click', @salvar
		@addEvent document.getElementById('btLoad'), 'click', @load
		@editorStructControl = new EditorControl 'mapStruct', ''
		@codeResult = new EditorControl 'dados', '{}', 'cobalt'
		@codeResult.editor.renderer.setShowGutter false

		@properties = new EditorControl 'propertiesEditor', '{}'

		@addEvent window, 'resize', @resize
		@addEvent @canvas, 'mouseover', (e) =>
			@codeResult.editor.blur()
			@editorStructControl.editor.blur()
			@properties.editor.blur()
			@canvas.focus()

		@idField = document.getElementById 'pointID'
		@addEvent @idField, 'change', @alteraPointID

		@defaultData()

		@resize null

	resize: (e) =>
		if @canvas.parentElement != null
			@cenario.rec.width = @canvas.width = @canvas.parentElement.offsetWidth
			@cenario.rec.height = @canvas.height = @canvas.parentElement.offsetHeight

	pointUnder: (x,y) ->
		dd = Point.size * Point.size
		i = 0
		while i<@points.length
			point = @points[i]
			i += 1
			d = (Math.pow (point.x-x),2) +
				(Math.pow (point.y-y),2)
			if d<dd
				return point
		null

	alteraPointID: (e) =>
		console.log e
		if @last != null and @last != undefined
			@last.id = @idField.value

	mousedown: (e) =>
		o = @getOffset @canvas
		x = e.x-o.x + @cenario.rec.x
		y = e.y-o.y + @cenario.rec.y
		@idField.value = ''
		@over = @pointUnder x, y
		if @over != null
			if e.shiftKey
				@isConnect = true
				#@last = @over
			else
				@isDraggin = true
				if @over.id
					@idField.value = @over.id
		@isDown = true
		false

	mouseup: (e) =>
		o = @getOffset @canvas
		x = e.x-o.x + @cenario.rec.x
		y = e.y-o.y + @cenario.rec.y
		@isDown = false

		if @isConnect
			p = @pointUnder x,y
			console.log p
			if p!=null
				@over.connect p
		else
			if not @isDraggin
				if e.shiftKey
					
				else
					if e.ctrlKey

					else
						old = @last
						@last = new Point x, y
						@points.push @last
						if old != undefined and old != null
							@last.connect old
			else
				if e.ctrlKey and @over != null #remove
					@points.splice @points.indexOf(@over), 1
					@over.removeReferences()
					@last = null
				else
					@last = @over

				@over.x = x
				@over.y = y
				@over = null
		@isDraggin = false
		@isConnect = false

	mousemove: (e) =>
		if @isDraggin
			o = @getOffset @canvas
			x = e.x-o.x + @cenario.rec.x
			y = e.y-o.y + @cenario.rec.y
			@over.x = x
			@over.y = y
		if @isConnect
			o = @getOffset @canvas
			@conx = e.x-o.x + @cenario.rec.x
			@cony = e.y-o.y + @cenario.rec.y
			e.preventDefault()
			e.stopPropagation()


	# remapear os indices seria mais rápido em termos de desempenho
	# mas foi mais rapido para programar pegando o indice.
	getPontIndex: (pt) =>
		i = 0
		while i<@points.length
			if @points[i].x==pt.x and @points[i].y==pt.y
				return i
			i += 1
		-1

	defaultData: () ->
		@points = []
		@editorStructControl.editor.setValue  """{
	"imagens": [
		["textures/cenarios/...",0,0],
		["textures/cenarios/...",0,512],
		["textures/cenarios/...",768,0],
		["textures/cenarios/...",768,512]
	]
	}""", 0
		@codeResult.editor.setValue '{}', 0
		@properties.editor.setValue '{}', 0

	salvar: () =>
		#o = window.eval "(" + @editorStructControl.editor.getValue() + ")"
		v = "{\n"

		val = @editorStructControl.editor.getValue() 
		v += val.substring val.indexOf("{")+1, val.lastIndexOf("}")-1
		v += ",\n\"points\":[  \n"
		
		for pt in @points
			do (pt) =>
				v += "\t{ \"x\":" + pt.x
				v += ", \"y\":" + pt.y
				if pt.id != null
					v += ", \"id\":\""+pt.id+"\""
				v += ", \"links\":[ "
				for j in pt.links
					do (j) =>
						v += @getPontIndex(j) + ","
				v = v.substring 0, v.length-1
				v += "]},\n"
		v = v.substring 0, v.length-2
		v += "\n] }"

		@codeResult.editor.setValue v,0

		# salva no LocalStorage
		if (window.localStorage)
			window.localStorage.setItem "mapa", v


	load: () =>
		
		if (window.localStorage)
			v = window.localStorage.getItem "mapa"
			@codeResult.editor.setValue v,0
			_eval = window.eval
			try
				d = _eval "(" + v + ")"
				console.log d
				@points.splice 0, @points.length
				# pontos
				for pt in d.points
					do (pt) =>
						ppp = new Point pt.x,pt.y
						@points.push ppp
						if pt.id
							ppp.id = pt.id
				# links
				i = 0
				for pt in d.points
					do (pt) =>
						for j in pt.links
							do (j) =>
								@points[i].links.push @points[j]
						i += 1

				data = v.substring(0,v.indexOf(",\n\"points\":["))
				data += "\n}"
				@editorStructControl.editor.setValue data,0
				@cenario.addImagens d.imagens
			catch e
				alert "Não foi possível carregar os dados: \n" + e.message + "\n\nRestaurando defaults."
				@defaultData()
		else
			a.innerHTML = "[Este navegador não suporta este recurso]"


	render: (cx) ->
		pas = 0 # pas faz passar uma segunda vez o loop de desenho
				# para gerar uma sombra na linha
		cx.strokeStyle = "#000"
		cx.lineWidth = 3
		cx.font = "8px Courier"
		while pas<2
			#cx.beginPath()
			for point in @points
				do (point) =>
					cx.beginPath()
					cx.arc point.x, point.y, Point.size, 0, Math.PI * 2
					for j in point.links
						do (j) =>
							cx.moveTo point.x, point.y
							cx.lineTo j.x, j.y
					cx.stroke()
					cx.closePath()

			#cx.stroke()
			#cx.closePath()

			cx.fillStyle = "#fff"
			for point in @points
				do (point) =>
					#point.id = 'll'
					if point.id != null
						cx.fillText point.id, point.x, point.y - 4
			cx.fillStyle = "none"

			if @isConnect
				cx.strokeStyle = "#ff0"
				cx.beginPath()
				cx.moveTo @over.x, @over.y
				cx.lineTo @conx, @cony
				cx.stroke()
				cx.closePath()
			
			cx.strokeStyle = "#fff"
			cx.lineWidth = 1
			pas += 1

		###
		# sombra
		cx.shadownColor = "#000"
		cx.shadowBlur = 2
		cx.shadowOffsetX = 
		cx.shadowOffsetY = 1
		###

class EditorControl extends BaseDOMManager
	constructor: (name, @data, theme) ->
		document.getElementById(name).innerHTML = @data

		if theme == undefined
			theme = 'monokai'	

		@editor = ace.edit name
		@editor.setTheme 'ace/theme/'+theme
		@editor.getSession().setMode 'ace/mode/json' #'ace/mode/javascript'


class Main extends BaseDOMManager

	constructor: () ->
		@addEvent window, 'load', @start

	start: (e) =>
		@cenario = new ViewCenario 'mainCanvas', {
			imagens: window.demoImagens
		}
		
		@cx = 0
		@cy = 0
		@addEvent @cenario.canvas, 'mousemove', @mousemove
		@addEvent @cenario.canvas, 'mouseover', @mouseover
		@addEvent @cenario.canvas, 'mouseout', @mouseout
		@addEvent window, 'keyup', @keyup
		@addEvent window, 'keydown', @keydown

		@editorWindow = new EditorView 'mainCanvas', @cenario
		@cenario.attackRenderModule @editorWindow
		@cenario.attackRenderModule this

		images = "{\n\"imagens\": [\n"
		i=0
		while i<window.demoImagens.length
			ii = window.demoImagens[i]
			images += "\t["+ "\""+ String(ii[0])
			images += "\"," + String(ii[1])
			images += "," + String(ii[2])
			images += "],\n"
			i += 1
		images = images.substring 0, images.length-2
		images += "\n]\n}"
		console.log images
		@editorWindow.editorStructControl.editor.setValue images, 0

		@cenario.render()

	keydown: (e) =>
		if e.keyCode>=37 and e.keyCode<=40
			@keyCodeDown = e.keyCode
			e.stopPropagation()
			e.preventDefault()
			false
		else
			@keyCodeDown = 0

	keyup: (e) =>
		@keyCodeDown = 0
		#console.log e
		
		###
		if ok
			@cenario.focus @cx,@cy
			
		###


	render: (cx) =>
		ok = false
		x = @px
		y = @py
		
		if  @mouseOver
			if x<10
				@cx -= 2
				ok = true
				@cx = 0 if @cx<0
			if x>(@cenario.canvas.width - 10)
				@cx += 2
				ok = true
				max = @cenario.size.width - @cenario.canvas.width
				@cx = max if @cx>max
			if y<10
				@cy -= 2
				ok = true
				@cy = 0 if @cy<0
			if y>(@cenario.canvas.height - 10)
			 	@cy += 2
			 	ok = true
			 	max = @cenario.size.height - @cenario.canvas.height
			 	@cy = max if @cy>max

			if @keyCodeDown>0
				ok = true
				switch @keyCodeDown
					when 39 #dir
						@cx += 8
						max = @cenario.size.width - @cenario.canvas.width
						@cx = max if @cx>max
					when 37 #esq
						@cx -= 8
						@cx = 0 if @cx<0
					when 38 #cima
						@cy -= 8
						@cy = 0 if @cy<0
					when 40 #baixo
						@cy += 8
						max = @cenario.size.height - @cenario.canvas.height
						@cy = max if @cy>max

			if ok
				@cenario.focus @cx,@cy

	mouseover: (e) =>
		@mouseOver = true

	mouseout: (e) =>
		@mouseOver = false

	mousemove: (e) =>
		o = @getOffset @cenario.canvas
		@px = e.x - o.x
		@py = e.y - o.y



window.main = main = new Main()

#window.cenario = cenario = new ViewCenario "mainCanvas"
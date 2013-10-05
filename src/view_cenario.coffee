
class Vector
	constructor: (@x,@y,@z,@w) ->
		@x = 0 if @x == undefined
		@y = 0 if @y == undefined
		@z = 0 if @z == undefined
		@w = 1 if @w == undefined

	add: ()->

class ViewCenario # extends BaseDOMManager

	class ViewRect
		constructor: (@x,@y, @width,@height) ->
			if @x instanceof HTMLCanvasElement
				@width = @x.width
				@height = @x.height
				@x=0
				@y=0
		colide: (rec) ->
			c = false
			if rec.x<(@x+@width)
				if (rec.x+rec.width)>=@x
					if rec.y<(@y+@height)
						if (rec.y+rec.height)>=@y
							c = true
			c

	class ViewImage
		constructor: (src, @x,@y, @parent) ->
			@image = new Image()
			@width = 0
			@height = 0
			@visible = false
			@isLoaded = false
			@image.src = src
			@image.onload = (e) =>
				@width = @image.width
				@height = @image.height
				@parent.computeSize()


	constructor: (name, data) ->
		@canvas = document.getElementById name
		@rec = new ViewRect @canvas
		@background = "#000"
		@dirty = true
		@renderModules = []
		@size =
			width:800
			height:800

		@addImagens data.imagens

	addImagens: (list) ->
		@imagens = []
		for i in list
			do (i)=>
				console.log i
				img = new ViewImage i[0], i[1], i[2], this
				@imagens.push img

	attackRenderModule: (rm) ->
		@renderModules.push rm

	computeSize: () ->
		w = 0
		h = 0
		for i in @imagens
			do (i) =>
				x = i.x + i.image.width
				y = i.y + i.image.height
				w = x if x>w
				h = y if y>h
		@size.width = w
		@size.height = h

	focus: (x,y) ->
		x = 0 if x<0
		y = 0 if y<0
		maxW = @size.width - @rec.width
		maxH = @size.height - @rec.height
		x = maxW if x>maxW
		y = maxH if y>maxH
		@rec.x = x
		@rec.y = y

	calcViews: (cx) ->
		for v in @imagens
			do (v) =>
				#console.log v
				if @rec.colide v
					v.visible = true
					cx.drawImage v.image, v.x,v.y 
				else
					v.visible = false

	render: () =>
		if not @dirty
			return

		cx = @canvas.getContext '2d'
		cx.setTransform 1,0,0,1,0,0
		cx.fillStyle = @background
		cx.fillRect 0,0,@canvas.width,@canvas.height
		cx.setTransform 1,0,0,1,-@rec.x, -@rec.y

		@calcViews cx
		#cx.drawImage @imagens[0].image, 0,0 
		#@rec.colide @imagens[0]

		for module in @renderModules
			do (module) =>
				module.render cx
		window.setTimeout @render, 40

###
	constructor: (name) ->
		@canvas = document.getElementById name

		@heightMap = new Image()
		@heightMap.onload = @mapLoaded
		@loadeds = 0

		@heightMap.src = 'textures/cen1.png'

		@addEvent window, 'keydown', @keydown
		@x = Math.round @canvas.width / 2
		@y = Math.round @canvas.height / 2


	mapLoaded: (e) =>
		console.log e
		@loadeds += 1
		if @loadeds == 1
			@render()

	keydown: (e) =>
		#console.log e.keyCode
		switch e.keyCode
			when 37 #esq
				@x -= 2
			when 38 #up
				@y -= 2
			when 39 #dir
				@x += 2
			when 40 #down
				@y += 2
		e.preventDefault()
		e.stopPropagation()
		false

	render: () =>
		cx = @canvas.getContext '2d'
		cx.drawImage @heightMap,0,0

		cx.beginPath()
		cx.strokeStyle = '#bb0'
		cx.lineWidth = 1
		cx.arc @x,@y, 3, 0, 2*Math.PI
		cx.stroke()


		

		window.setTimeout @render, 50
###


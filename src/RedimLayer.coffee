
###
#
#  Cria barras de redimencionamento
#  Quando redimencion passa um objeto
#  com os offsets da nova dimensão
#
###

class LayerRedim

	@BARRA_H = "url(data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAADAAAAAEAgMAAAC1h1SvAAAACVBMVEWxsbHPz8/t7e1xptKfAAAACXBIWXMAAAsTAAALEwEAmpwYAAAAB3RJTUUH3QkNDTk7KlnoMAAAAB1pVFh0Q29tbWVudAAAAAAAQ3JlYXRlZCB3aXRoIEdJTVBkLmUHAAAAHElEQVQI12OYGgoHIQxTQyPCRFsTw0QTMTkIZQCz3BCHwPjL5QAAAABJRU5ErkJggg==)"
	@BARRA_V = "url(data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAQAAAAwAgMAAABLdDNWAAAACVBMVEWxsbHPz8/t7e1xptKfAAAACXBIWXMAAAsTAAALEwEAmpwYAAAAB3RJTUUH3QkNDToNzs4uagAAAB1pVFh0Q29tbWVudAAAAAAAQ3JlYXRlZCB3aXRoIEdJTVBkLmUHAAAAF0lEQVQI12NYxRCKATMZHIli4WbDIAMAHbMP8YDVPsoAAAAASUVORK5CYII=)"

	constructor: (divName, @orientacao, @position, @callBack) ->
		@target = $ "#" + divName
		if @orientacao == undefined
			@orientacao = "V"
		if @position == undefined
			if @orientacao=='V'
				@position = 'top'
			else
				@position = 'left'

		@barra = $ document.createElement 'div'
		@barra.css
			'position':'absolute'
			'z-index':'1002'
		if @orientacao=='V'
			@barra.css
				'background': '#ddf ' + LayerRedim.BARRA_V + " no-repeat center center"
				'cursor': 'w-resize'
		else
			@barra.css
				'background': '#ddf ' + LayerRedim.BARRA_H + " no-repeat center center"
				'cursor': 'n-resize'

		@barra.mousedown @mouseDown

		@rect = $ document.createElement 'div'
		@rect.css
			'position':'absolute'
			'background':'rgba(240,240,255,0.2)'
			'z-index':'1001'
			#'pointer-events':'none'
			'display':'none'
		@rect.mouseup @mouseUp

		@setupPosition()		

		$(window.document.body).append @rect
		$(window.document.body).append @barra

	setupPosition: () ->
		if @orientacao=='V'
			@barra.width 4
			@barra.height @target.height()
		else
			@barra.height 4
			@barra.width @target.width()

		o = @target.offset()

		switch @position
			when 'top'
				@barra.css
					'top':o.top - 3
					'left':o.left
					'width':@target.width()
			when 'bottom'
				@barra.css
					'top': @target.offset().top + @target.height() - 1
					'left':o.left
					'width':@target.width()
			when 'left'
				@barra.css
					'left':@target.offset().left - 3
					'top':o.top
					'height':@target.height()
			when 'right'
				@barra.css
					'left':@target.offset().left + @target.width() - 1
					'top':o.top
					'height':@target.height()

	showRec: (x,y) ->
		o = @target.offset()
		r = [o.left, o.top, o.left + @target.width(), o.top + @target.height()]
		if @orientacao=='V'
			if @position=='left'
				r[0] = x
			else
				r[2] = x
		else
			if @position=='top'
				r[1] = y
			else
				r[3] = y


		###
		if @orientacao=='V'
			if x<r[0]
				r[0] = x
				r[2] = x + @target.width()
			else
				r[2] = x
		else
			if y<r[1]
				r[1] = y
				r[3] = y + @target.height()
			else
				r[3] = y
		###
		@rect.css
			'left':r[0]
			'top':r[1]
			'width':r[2]-r[0]
			'height':r[3]-r[1]


	mouseDown: (e) =>
		$(window).bind("mouseup",@mouseUp).bind("mousemove",@mouseMove)
		o = @barra.offset()
		@ox = e.pageX - o.left
		@oy = e.pageY - o.top
		@rect.css 'display':'block'
		@showRec e.pageX, e.pageY
		false

	mouseUp: (e) =>
		o =
			left: @rect.offset().left
			top: @rect.offset().top
			right: @rect.offset().left + @rect.width()
			bottom: @rect.offset().top + @rect.height()
			width: @rect.width()
			height: @rect.height()
			target: @target

		$(window).unbind("mouseup",@mouseUp).unbind("mousemove",@mouseMove)
		@rect.css 'display':'none'

		if @callBack != undefined
			@callBack o

		false

	mouseMove: (e) =>
		if @orientacao=='V'
			@barra.css 'left', e.pageX - @ox
		else
			@barra.css 'top', e.pageY - @oy
		@showRec e.pageX, e.pageY
		false





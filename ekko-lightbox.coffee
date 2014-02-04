###
Lightbox for Bootstrap 3 by @ashleydw
https://github.com/ashleydw/lightbox

License: https://github.com/ashleydw/lightbox/blob/master/LICENSE
###
"use strict";

EkkoLightbox = ( element, options ) ->

	@options = $.extend({
		remote : null
		onShow : ->
		onShown : ->
		onHide : ->
		onHidden : ->
		id : false
	}, options || {})

	@$element = $(element)
	content = ''

	@modal_id = if @options.modal_id then @options.modal_id else 'ekkoLightbox-' + Math.floor((Math.random() * 1000) + 1)
	header = '<div class="modal-header"><button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button></div>'
	$(document.body).append '<div id="' + @modal_id + '" class="ekko-lightbox modal fade" tabindex="-1"><div class="modal-dialog"><div class="modal-content">' + header + '<div class="modal-body"><div class="ekko-lightbox-container"><div></div></div></div></div></div></div>'

	@modal = $ '#' + @modal_id
	@modal_dialog = @modal.find('.modal-dialog').first()
	@modal_content = @modal.find('.modal-content').first()
	@modal_body = @modal.find('.modal-body').first()

	@lightbox_container = @modal_body.find('.ekko-lightbox-container').first()
	@lightbox_body = @lightbox_container.find('> div:first-child').first()

	@border = {
		top: parseFloat(@modal_dialog.css('border-top-width')) + parseFloat(@modal_content.css('border-top-width')) + parseFloat(@modal_body.css('border-top-width'))
		right: parseFloat(@modal_dialog.css('border-right-width')) + parseFloat(@modal_content.css('border-right-width')) + parseFloat(@modal_body.css('border-right-width'))
		bottom: parseFloat(@modal_dialog.css('border-bottom-width')) + parseFloat(@modal_content.css('border-bottom-width')) + parseFloat(@modal_body.css('border-bottom-width'))
		left: parseFloat(@modal_dialog.css('border-left-width')) + parseFloat(@modal_content.css('border-left-width')) + parseFloat(@modal_body.css('border-left-width'))
	}

	@padding = {
		top: parseFloat(@modal_dialog.css('padding-top')) + parseFloat(@modal_content.css('padding-top')) + parseFloat(@modal_body.css('padding-top'))
		right: parseFloat(@modal_dialog.css('padding-right')) + parseFloat(@modal_content.css('padding-right')) + parseFloat(@modal_body.css('padding-right'))
		bottom: parseFloat(@modal_dialog.css('padding-bottom')) + parseFloat(@modal_content.css('padding-bottom')) + parseFloat(@modal_body.css('padding-bottom'))
		left: parseFloat(@modal_dialog.css('padding-left')) + parseFloat(@modal_content.css('padding-left')) + parseFloat(@modal_body.css('padding-left'))
	}

	@modal
	.on('show.bs.modal', @options.onShow.bind(@))
	.on 'shown.bs.modal', =>
		@modal_shown()
		@options.onShown.call(@)
	.on('hide.bs.modal', @options.onHide.bind(@))
	.on 'hidden.bs.modal', =>
		@modal.remove()
		@options.onHidden.call(@)
	.modal 'show', options

	@modal

EkkoLightbox.prototype = {
	modal_shown: ->
		# when the modal first loads
		if !@options.remote
			@error 'No remote target given'
		else
			@preloadImage(@options.remote, true)

	strip_stops: (str) ->
		str.replace(/\./g, '')

	strip_spaces: (str) ->
		str.replace(/\s/g, '')

	showLoading : ->
		@lightbox_body.html '<div class="modal-loading">Loading..</div>'
		@

	error : ( message ) ->
		@lightbox_body.html message
		@

	preloadImage : ( src, onLoadShowImage) ->

		img = new Image()
		if !onLoadShowImage? || onLoadShowImage == true
			img.onload = =>
				image = $('<img />')
				image.attr('src', img.src)
				image.addClass('img-responsive')
				@lightbox_body.html image
				@resize img.width
			img.onerror = =>
				@error 'Failed to load image: ' + src

		img.src = src
		img

	resize : ( width ) ->
		#resize the dialog based on the width given, and adjust the directional arrow padding
		width_total = width + @border.left + @padding.left + @padding.right + @border.right
		@modal_dialog.css('width', 'auto') .css('max-width', width_total);

		@lightbox_container.find('a').css 'padding-top', ->
			$(@).parent().height() / 2
		@

	checkDimensions: (width) ->
		#check that the width given can be displayed, if not return the maximum size that can be

		width_total = width + @border.left + @padding.left + @padding.right + @border.right
		body_width = document.body.clientWidth

		if width_total > body_width
			width = @modal_body.width()

		width

	close : ->
		@modal.modal('hide');
}


$.fn.ekkoLightbox = ( options ) ->
	@each ->

		$this = $(this)
		options = $.extend({
			remote : $this.attr('data-remote') || $this.attr('href')
		}, options, $this.data())
		new EkkoLightbox(@, options)
		@

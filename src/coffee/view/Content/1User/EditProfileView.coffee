class EditProfileView extends AppView

	#el: null

	events:
		'submit form#edit-profile':'updateMe'

	initialize: ->
		console.log "EditProfileView intialized"
		@el = $('#user_view #edit-profile.module')

	show: ->

		@el = $('#user_view #edit-profile.module')
		$(@el).show()

	hide: ->

		@el = $('#user_view #edit-profile.module')
		$(@el).hide()

	updateMe: (e) ->

		e.preventDefault()

		console.log e

		# Get user by username.
		user = new PublicUser({'id' : 'me'})
		#user.url = '/users/me'

		new_username = $($(e.currentTarget).find('.new-username')).val()
		user.set 'username', new_username

		user.save( { 'user' : user.attrributes },

			success: (model, response, options) =>
				#console.log 'successfully updated', response
				#alert 'your new username is' + new_username
				updated_user = response
				localStorage.setItem('user', JSON.stringify(updated_user))
				@el.prepend '<h3 style="color:green">Successfully updated.</h3>'
				
			error: (model, xhr, options) =>
				console.log "failed to find the user '"+model.username+"'."
				console.log model, xhr, options

		)
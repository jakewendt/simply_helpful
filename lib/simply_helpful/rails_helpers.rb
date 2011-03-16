module SimplyHelpful::RailsHelpers

	#	Just add the classes 'submit' and 'button'
	#	for styling and function
	def submit_link_to(*args,&block)
		html_options = if block_given?
			args[1] ||= {}
		else
			args[2] ||= {}
		end
		( html_options[:class] ||= '' ) << ' submit button'
		link_to( *args, &block )
	end


	def form_link_to( title, url, options={}, &block )
#			"action='#{url}' " <<
		extra_tags = extra_tags_for_form(options)
		s =  "\n" <<
			"<form " <<
			"class='#{options.delete(:class)||'form_link_to'}' " <<
			"action='#{url_for(url)}' " <<
			"method='#{options.delete('method')}'>\n" <<
			extra_tags << "\n"
		s << (( block_given? )? capture(&block) : '')
		s << submit_tag(title, :name => nil ) << "\n" <<
			"</form>\n"
		if block_called_from_erb?(block)
			concat(s)
		else
			s
		end
	end

	def destroy_link_to( title, url, options={}, &block )
		s = form_link_to( title, url, options.merge(
			'method' => 'delete',
			:class => 'destroy_link_to'
		),&block )
	end

	def aws_image_tag(image,options={})
		#	in console @controller is nil
		protocol = @controller.try(:request).try(:protocol) || 'http://'
		host = 's3.amazonaws.com/'
		bucket = ( defined?(RAILS_APP_NAME) && RAILS_APP_NAME ) || 'ccls'
		src = "#{protocol}#{host}#{bucket}/images/#{image}"
		alt = options.delete(:alt) || options.delete('alt') || image
		tag('img',options.merge({:src => src, :alt => alt}))
	end

	#	This style somehow for some reason actually submits the request TWICE?
	#	In many cases, this is no big deal, but when using it to send
	#	emails or something, the controller/action is called twice
	#	resulting in 2 emails (if that's what your action does)
	#	I'd really like to understand why.
	def button_link_to( title, url, options={} )
		classes = ['link']
		classes << options[:class]
		s =  "<a href='#{url_for(url)}' style='text-decoration:none;'>"
		s << "<button type='button'>"
		s << title
		s << "</button></a>\n"
	end

	#	This creates a button that looks like a submit button
	#	but is just a javascript controlled link.
	#	I don't like it.
	def old_button_link_to( title, url, options={} )
#		id = "id='#{options[:id]}'" unless options[:id].blank?
#		klass = if options[:class].blank?
#			"class='link'"
#		else
#			"class='#{options[:class]}'"
#		end
#		s =  "<button #{id} #{klass} type='button'>"
		classes = ['link']
		classes << options[:class]
		s =  "<button class='#{classes.flatten.join(' ')}' type='button'>"
		s << "<span class='href' style='display:none;'>"
		s << url_for(url)
		s << "</span>"
		s << title
		s << "</button>"
		s
	end

	def flasher
		s = ''
		flash.each do |key, msg|
			s << content_tag( :p, msg, :id => key, :class => 'flash' )
			s << "\n"
		end
		s << "<noscript><p id='noscript' class='flash'>\n"
		s << "Javascript is required for this site to be fully functional.\n"
		s << "</p></noscript>\n"
	end

	#	Created to stop multiple entries of same stylesheet
	def stylesheets(*args)
		@stylesheets ||= []
		args.each do |stylesheet|
			unless @stylesheets.include?(stylesheet.to_s)
				@stylesheets.push(stylesheet.to_s)
				content_for(:head,stylesheet_link_tag(stylesheet.to_s))
			end
		end
	end

	def javascripts(*args)
		@javascripts ||= []
		args.each do |javascript|
			unless @javascripts.include?(javascript.to_s)
				@javascripts.push(javascript.to_s)
				content_for(:head,javascript_include_tag(javascript).to_s)
			end
		end
	end

end
ActionView::Base.send(:include, SimplyHelpful::RailsHelpers)

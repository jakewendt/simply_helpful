module SimplyHelpful::FormHelper

	def mdy(date)
		( date.nil? ) ? '&nbsp;' : date.strftime("%m/%d/%Y")
	end

	def time_mdy(time)
		( time.nil? ) ? '&nbsp;' : time.strftime("%I:%M %p %m/%d/%Y")
	end

	def y_n_dk(value)
		case value
			when 1   then 'Yes'
			when 2   then 'No'
			when 999 then "Don't Know"
			else '&nbsp;'
		end
	end
	alias_method :yndk, :y_n_dk

	def field_wrapper(method,options={},&block)
		classes = [method,options[:class]].compact.join(' ')
		s =  "<div class='#{classes} field_wrapper'>\n"
		s << yield 
		s << "\n</div><!-- class='#{classes}' -->"
	end

	#	This is NOT a form field
	def _wrapped_spans(object_name,method,options={})
		s =  "<span class='label'>#{options[:label_text]||method}</span>\n"
		value = if options[:value]
			options[:value]
		else
			object = instance_variable_get("@#{object_name}")
			value = object.send(method)
			value = (value.to_s.blank?)?'&nbsp;':value
		end
		s << "<span class='value'>#{value}</span>"
	end

	def _wrapped_y_n_dk_spans(object_name,method,options={})
		object = instance_variable_get("@#{object_name}")
		_wrapped_spans(object_name,method,options.update(
			:value => y_n_dk(object.send(method)) ) )
	end
	alias_method :_wrapped_yndk_spans, :_wrapped_y_n_dk_spans

	def _wrapped_date_spans(object_name,method,options={})
		object = instance_variable_get("@#{object_name}")
		_wrapped_spans(object_name,method,options.update(
			:value => mdy(object.send(method)) ) )
	end

	def sex_select(object_name, method, 
			options={}, html_options={})
		select(object_name, method,
			[['male','M'],['female','F']],
			options, html_options)
	end
	alias_method :gender_select, :sex_select

	def date_text_field(object_name,method,options={})
		format = options.delete(:format) || '%m/%d/%Y'
		tmp_value = if options[:value].blank? #and !options[:object].nil?
			object = options[:object]
			tmp = object.send("#{method}") ||
			      object.send("#{method}_before_type_cast")
		else
			options[:value]
		end
		begin
			options[:value] = tmp_value.to_date.try(:strftime,format)
		rescue NoMethodError, ArgumentError
			options[:value] = tmp_value
		end
		options.update(:class => [options[:class],'datepicker'].compact.join(' '))
		text_field( object_name, method, options )
	end

	#	This is NOT a form field
	def _wrapped_yes_or_no_spans(object_name,method,options={})
		object = instance_variable_get("@#{object_name}")
		s =  "<span class='label'>#{options[:label_text]||method}</span>\n"
		value = (object.send("#{method}?"))?'Yes':'No'
		s << "<span class='value'>#{value}</span>"
	end

	def y_n_dk_select(object_name, method, 
			options={}, html_options={})
		select(object_name, method,
			[['Yes',1],['No',2],["Don't Know",999]],
			{:include_blank => true}.merge(options), html_options)
	end
	alias_method :yndk_select, :y_n_dk_select

	def hour_select(object_name, method, 
			options={}, html_options={})
		select(object_name, method,
			(1..12),
			{:include_blank => 'Hour'}.merge(options), html_options)
	end

	def minute_select(object_name, method, 
			options={}, html_options={})
		minutes = (0..59).to_a.collect{|m|[sprintf("%02d",m),m]}
		select(object_name, method,
			minutes,
			{:include_blank => 'Minute'}.merge(options), html_options)
	end

	def meridiem_select(object_name, method, 
			options={}, html_options={})
		select(object_name, method,
			['AM','PM'], 
			{:include_blank => 'Meridiem'}.merge(options), html_options)
	end

	def self.included(base)
		base.class_eval do
			alias_method_chain( :method_missing, :wrapping 
				) unless base.respond_to?(:method_missing_without_wrapping)
		end
	end

	def method_missing_with_wrapping(symb,*args, &block)
		method_name = symb.to_s
		if method_name =~ /^wrapped_(.+)$/
			unwrapped_method_name = $1
#
#	It'd be nice to be able to genericize all of the
#	wrapped_* methods since they are all basically
#	the same.
#		Strip of the "wrapped_"
#		Label
#		Call "unwrapped" method
#

			object_name = args[0]
			method      = args[1]

			content = field_wrapper(method,:class => unwrapped_method_name) do
				s = if respond_to?(unwrapped_method_name)
					options    = args.detect{|i| i.is_a?(Hash) }
					label_text = options.delete(:label_text) unless options.nil?
					if unwrapped_method_name == 'check_box'
						send("#{unwrapped_method_name}",*args,&block) <<
						label( object_name, method, label_text )
					else
						label( object_name, method, label_text ) <<
						send("#{unwrapped_method_name}",*args,&block)
					end
				else
					send("_#{method_name}",*args,&block)
				end

				s << (( block_given? )? capture(&block) : '')
#				send("_#{method_name}",*args) << 
#					(( block_given? )? capture(&block) : '')
			end
			if block_called_from_erb?(block)
				concat(content)
			else
				content
			end
		else
			method_missing_without_wrapping(symb,*args, &block)
		end
	end

end
ActionView::Base.send(:include, SimplyHelpful::FormHelper)



ActionView::Helpers::FormBuilder.class_eval do

	def submit_link_to(value=nil,options={})
		#	submit_link_to will remove :value, which is intended for submit
		#	so it MUST be executed first.  Unfortunately, my javascript
		#	expects it to be AFTER the a tag.
#		s = submit(value,options.reverse_merge(
#				:id => "#{object_name}_submit_#{value.try(:downcase).try(:gsub,/\s+/,'_')}"
#			) ) << @template.submit_link_to(value,nil,options)
		s1 = submit(value,options.reverse_merge(
				:id => "#{object_name}_submit_#{value.try(:downcase).try(
					:gsub,/\s+/,'_').try(
					:gsub,/(&amp;|'|\/)/,'').try(
					:gsub,/_+/,'_')}"
			) ) 
		s2 = @template.submit_link_to(value,nil,options)
		s2 << s1
	end 

	def hour_select(method,options={},html_options={})
		@template.hour_select(
			@object_name, method, 
				objectify_options(options),
				html_options)
	end

	def minute_select(method,options={},html_options={})
		@template.minute_select(
			@object_name, method, 
				objectify_options(options),
				html_options)
	end

	def meridiem_select(method,options={},html_options={})
		@template.meridiem_select(
			@object_name, method, 
				objectify_options(options),
				html_options)
	end

	def sex_select(method,options={},html_options={})
		@template.sex_select(
			@object_name, method, 
				objectify_options(options),
				html_options)
	end
	alias_method :gender_select, :sex_select

	def date_text_field(method, options = {})
		@template.date_text_field(
			@object_name, method, objectify_options(options))
	end

	def y_n_dk_select(method,options={},html_options={})
		@template.y_n_dk_select(
			@object_name, method, 
				objectify_options(options),
				html_options)
	end
	alias_method :yndk_select, :y_n_dk_select

	def method_missing_with_wrapping(symb,*args, &block)
		method_name = symb.to_s
		if method_name =~ /^wrapped_(.+)$/
			i = args.find_index{|i| i.is_a?(Hash) }
			if i.nil?
				args.push(objectify_options({}))
			else
				args[i] = objectify_options(args[i]) 	
			end
			@template.send(method_name,@object_name,*args,&block)
		else
			method_missing_without_wrapping(symb,*args, &block)
		end
	end

	alias_method_chain( :method_missing, :wrapping
		) unless respond_to?(:method_missing_without_wrapping)

end

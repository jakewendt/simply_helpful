module RailsHelpers::FormHelper

	def field_wrapper(method,&block)
		s =  "<div class='#{method} field_wrapper'>\n"
		s << yield 
		s << "\n</div><!-- class='#{method}' -->"
	end

	def _wrapped_check_box(object_name,method,options={})
		s =  label( object_name, method, 
			options.delete(:label_text) || "#{method.to_s.titleize}?" )
		s << check_box( object_name, method, options )
	end

	def _wrapped_collection_select(object_name,method,
			collection,value_method,text_method,
			options={},html_options={})
		s =  label( object_name, method, options.delete(:label_text) )
		s << collection_select( object_name, method, 
			collection,value_method,text_method,options,html_options )
	end

	def _wrapped_grouped_collection_select(object_name,method,
			collection, group_method, group_label_method,
			option_key_method, option_value_method,
			options={},html_options={})
		s =  label( object_name, method, options.delete(:label_text) )
		s << grouped_collection_select( object_name, method, 
			collection, group_method, group_label_method,
			option_key_method, option_value_method,
			options, html_options )
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

	def sex_select(object_name, method, 
			options={}, html_options={})
		select(object_name, method,
			[['male','M'],['female','F']],
			options, html_options)
	end
	alias_method :gender_select, :sex_select

	def _wrapped_sex_select(object_name, method, 
			options={}, html_options={})
		s =  label( object_name, method, options.delete(:label_text) )
		s << sex_select( object_name, method, options, html_options )
	end
	alias_method :_wrapped_gender_select, :_wrapped_sex_select

	def _wrapped_select(object_name, method, choices, 
			options={}, html_options={})
		s =  label( object_name, method, options.delete(:label_text) )
		s << select( object_name, method, choices, options, html_options )
	end

	def _wrapped_text_area(object_name,method,options={})
		s =  label( object_name, method, options.delete(:label_text) )
		s << text_area( object_name, method, options )
	end

	def date_text_field(object_name,method,options={})
		format = options.delete(:format) || '%m/%d/%Y'
		tmp_value = if options[:value].blank?
			object = options[:object]
			tmp = object.send("#{method}") ||
			      object.send("#{method}_before_type_cast")
		else
			options[:value]
		end
		begin
			options[:value] = tmp_value.to_date.try(:strftime,format)
		rescue NoMethodError
			options[:value] = tmp_value
		end
		text_field( object_name, method, options )
	end

	def _wrapped_date_text_field(object_name,method,options={})
		s =  label( object_name, method, options.delete(:label_text) )
		s << date_text_field( object_name, method, options )
	end

	def _wrapped_text_field(object_name,method,options={})
		s =  label( object_name, method, options.delete(:label_text) )
		s << text_field( object_name, method, options )
	end

	#	This is NOT a form field
	def _wrapped_yes_or_no_spans(object_name,method,options={})
		object = instance_variable_get("@#{object_name}")
		s =  "<span class='label'>#{options[:label_text]||method}</span>\n"
		value = (object.send("#{method}?"))?'yes':'no'
		s << "<span class='value'>#{value}</span>"
	end

	def y_n_dk_select(object_name, method, 
			options={}, html_options={})
		select(object_name, method,
			[['Yes',1],['No',2],["Don't Know",999]],
			options, html_options)
	end

	def _wrapped_y_n_dk_select(object_name, method, 
			options={}, html_options={})
		s =  label( object_name, method, options.delete(:label_text) )
		s << y_n_dk_select( object_name, method, options, html_options )
	end


	def self.included(base)
		base.class_eval do
			alias_method_chain :method_missing, :wrapping
		end
	end

	def method_missing_with_wrapping(symb,*args, &block)
		method_name = symb.to_s
		if method_name =~ /^wrapped_(.+)$/
			content = field_wrapper(args[1]) do
				send("_#{method_name}",*args) << 
					(( block_given? )? capture(&block) : '')
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
ActionView::Base.send(:include, RailsHelpers::FormHelper)


ActionView::Helpers::FormBuilder.class_eval do

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

	alias_method_chain :method_missing, :wrapping

end

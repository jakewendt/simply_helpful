#require File.dirname(__FILE__) + '/../../test_helper'
require 'test_helper'

class SimplyHelpful::RailsHelpersTest < ActionView::TestCase

	test "form_link_to with block" do
		response = HTML::Document.new(
			form_link_to('mytitle','/myurl') do
				hidden_field_tag('apple','orange')
			end).root
#<form class='form_link_to' action='myurl' method='post'>
#<input id="apple" name="apple" type="hidden" value="orange" />
#<input type="submit" value="mytitle" />
#</form>
		assert_select response, 'form.form_link_to[action=/myurl]', 1 do
			assert_select 'input', 2
		end
	end

	test "form_link_to without block" do
		response = HTML::Document.new(form_link_to('mytitle','/myurl')).root
		assert_select response, 'form.form_link_to[action=/myurl]', 1 do
			assert_select 'input', 1
		end
#<form class="form_link_to" action="myurl" method="post">
#<input type="submit" value="mytitle" />
#</form>
	end

	test "destroy_link_to with block" do
		response = HTML::Document.new(
			destroy_link_to('mytitle','/myurl') do
				hidden_field_tag('apple','orange')
			end).root
#<form class="destroy_link_to" action="myurl" method="post">
#<div style="margin:0;padding:0;display:inline"><input name="_method" type="hidden" value="delete" /></div>
#<input id="apple" name="apple" type="hidden" value="orange" /><input type="submit" value="mytitle" />
#</form>
		assert_select response, 'form.destroy_link_to[action=/myurl]', 1 do
			assert_select 'input', 3
		end
	end

	test "destroy_link_to without block" do
		response = HTML::Document.new(destroy_link_to('mytitle','/myurl')).root
#<form class="destroy_link_to" action="myurl" method="post">
#<div style="margin:0;padding:0;display:inline"><input name="_method" type="hidden" value="delete" /></div>
#<input type="submit" value="mytitle" />
#</form>
		assert_select response, 'form.destroy_link_to[action=/myurl]', 1 do
			assert_select 'input', 2
		end
	end

	test "button_link_to without block" do
		response = HTML::Document.new(button_link_to('mytitle','/myurl')).root
		assert_select response, 'a[href=/myurl]', 1 do
			assert_select 'button', 1
		end
#<a href="myurl" style="text-decoration:none;"><button type="button">mytitle</button></a>
	end

	test "aws_image_tag" do
		response = HTML::Document.new(
			aws_image_tag('myimage')
		).root
#<img alt="myimage" src="http://s3.amazonaws.com/ccls/images/myimage" />
		assert_select response, 'img[src=http://s3.amazonaws.com/ccls/images/myimage]', 1
	end

	test "flasher" do
#		response = HTML::Document.new(
#			flasher
#		).root
#puts response
#pending
	end

	test "javascripts" do
		assert_nil @javascripts
		javascripts('myjavascript')
		assert @javascripts.include?('myjavascript')
		assert_equal 1, @javascripts.length
		javascripts('myjavascript')
		assert_equal 1, @javascripts.length
#<script src="/javascripts/myjavascript.js" type="text/javascript"></script>
		response = HTML::Document.new( @content_for_head).root
		assert_select response, 'script[src=/javascripts/myjavascript.js]'
	end

	test "stylesheets" do
		assert_nil @stylesheets
		stylesheets('mystylesheet')
		assert @stylesheets.include?('mystylesheet')
		assert_equal 1, @stylesheets.length
		stylesheets('mystylesheet')
		assert_equal 1, @stylesheets.length
#<link href="/stylesheets/mystylesheet.css" media="screen" rel="stylesheet" type="text/css" />
		response = HTML::Document.new( @content_for_head).root
		assert_select response, 'link[href=/stylesheets/mystylesheet.css]'
	end

end

__END__

	def flasher
		s = ''
		flash.each do |key, msg|
			s << content_tag( :p, msg, :id => key, :class => 'flash' )
			s << "\n"
		end
		s << "<noscript>\n"
		s << "<p id='noscript' class='flash'>"
		s << "Javascript is required for this site to be fully functional."
		s << "</p>\n"
		s << "</noscript>\n"
	end

#require File.dirname(__FILE__) + '/../../test_helper'
require 'test_helper'

class SimplyHelpful::User
	attr_accessor :yes_or_no, :yndk, :dob, :sex, :name, :dob_before_type_cast
	def initialize(*args,&block)
		yield self if block_given?
	end
	def yes_or_no?
		!!yes_or_no
	end
end

class SimplyHelpful::FormHelperTest < ActionView::TestCase

	test "field_wrapper" do
		response = HTML::Document.new(
			field_wrapper('mymethod') do
				'Yield'
			end).root
#<div class="mymethod field_wrapper">
#Yield
#</div><!-- class='mymethod' -->
		assert_select response, 'div.mymethod.field_wrapper'
	end

	test "wrapped_spans without options" do
		@user = SimplyHelpful::User.new
		response = HTML::Document.new(
			wrapped_spans(:user, :name)).root
#<div class="name field_wrapper">
#<span class="label">name</span>
#<span class="value">&nbsp;</span>
#</div><!-- class='name' -->
		assert_select response, 'div.name.field_wrapper', 1 do
			assert_select 'span.label', 1
			assert_select 'span.value', 1
		end
	end

	test "wrapped_yes_or_no_spans blank" do
		@user = SimplyHelpful::User.new
		response = HTML::Document.new(
			wrapped_yes_or_no_spans(:user, :yes_or_no)).root
#<div class="yes_or_no field_wrapper">
#<span class="label">yes_or_no</span>
#<span class="value">no</span>
#</div><!-- class='yes_or_no' -->
		assert_select response, 'div.yes_or_no.field_wrapper' do
			assert_select 'span.label','yes_or_no',1
			assert_select 'span.value','No',1
		end
	end

	test "wrapped_yes_or_no_spans true" do
		@user = SimplyHelpful::User.new{|u| u.yes_or_no = true }
		response = HTML::Document.new(
			wrapped_yes_or_no_spans(:user, :yes_or_no)).root
#<div class="yes_or_no field_wrapper">
#<span class="label">yes_or_no</span>
#<span class="value">yes</span>
#</div><!-- class='yes_or_no' -->
		assert_select response, 'div.yes_or_no.field_wrapper' do
			assert_select 'span.label','yes_or_no',1
			assert_select 'span.value','Yes',1
		end
	end

	test "wrapped_yes_or_no_spans false" do
		@user = SimplyHelpful::User.new(:yes_or_no => false)
		response = HTML::Document.new(
			wrapped_yes_or_no_spans(:user, :yes_or_no)).root
#<div class="yes_or_no field_wrapper">
#<span class="label">yes_or_no</span>
#<span class="value">no</span>
#</div><!-- class='yes_or_no' -->
		assert_select response, 'div.yes_or_no.field_wrapper' do
			assert_select 'span.label','yes_or_no',1
			assert_select 'span.value','No',1
		end
	end

	test "wrapped_sex_select" do
		@user = SimplyHelpful::User.new
		response = HTML::Document.new(
			wrapped_sex_select(:user, :sex)).root
#<div class="sex field_wrapper">
#<label for="user_sex">Sex</label><select id="user_sex" name="user[sex]"><option value="M">male</option>
#<option value="F">female</option></select>
#</div><!-- class='sex' -->
		assert_select response, 'div.sex.field_wrapper', 1 do
			assert_select 'label[for=user_sex]','Sex',1 
			assert_select "select#user_sex[name='user[sex]']" do
				assert_select 'option[value=M]', 'male'
				assert_select 'option[value=F]', 'female'
			end
		end
	end

	test "wrapped_gender_select" do
		@user = SimplyHelpful::User.new
		response = HTML::Document.new(
			wrapped_gender_select(:user, :sex)).root
#<div class="sex field_wrapper">
#<label for="user_sex">Sex</label><select id="user_sex" name="user[sex]"><option value="M">male</option>
#<option value="F">female</option></select>
#</div><!-- class='sex' -->
		assert_select response, 'div.sex.field_wrapper', 1 do
			assert_select 'label[for=user_sex]','Sex',1 
			assert_select "select#user_sex[name='user[sex]']" do
				assert_select 'option[value=M]', 'male'
				assert_select 'option[value=F]', 'female'
			end
		end
	end

	test "wrapped_date_text_field" do
		@user = SimplyHelpful::User.new
		response = HTML::Document.new(
			wrapped_date_text_field(:user,:dob, :object => @user)).root
#<div class="dob field_wrapper">
#<label for="user_dob">Dob</label><input id="user_dob" name="user[dob]" size="30" type="text" />
#</div><!-- class='dob' -->
		assert_select response, 'div.dob.field_wrapper', 1 do
			assert_select 'label[for=user_dob]','Dob', 1 
			assert_select "input#user_dob[name='user[dob]']"
		end
	end

	test "wrapped_date_text_field with invalid dob" do
		@user = SimplyHelpful::User.new
		@user.dob = "07181989"	
#	will raise ...
#ArgumentError: invalid date
#    /System/Library/Frameworks/Ruby.framework/Versions/1.8/usr/lib/ruby/1.8/date.rb:752:in `new'
#    lib/simply_helpful/form_helper.rb:67:in `date_text_field'
#    lib/simply_helpful/form_helper.rb:123:in `send'
#    lib/simply_helpful/form_helper.rb:123:in `method_missing'
#    lib/simply_helpful/form_helper.rb:19:in `field_wrapper'
#    lib/simply_helpful/form_helper.rb:114:in `method_missing'
#    /test/unit/helpful/form_helper_test.rb:134:in `test_wrapped_date_text_field_with_invalid_dob'
#
		response = HTML::Document.new(
			wrapped_date_text_field(:user,:dob, :object => @user)).root
#<div class="dob field_wrapper">
#<label for="user_dob">Dob</label><input id="user_dob" name="user[dob]" size="30" type="text" />
#</div><!-- class='dob' -->
		assert_select response, 'div.dob.field_wrapper', 1 do
			assert_select 'label[for=user_dob]','Dob', 1 
			assert_select "input#user_dob[name='user[dob]']"
		end
	end

	test "wrapped_y_n_dk_select" do
		@user = SimplyHelpful::User.new
		response = HTML::Document.new(
			wrapped_y_n_dk_select(:user, :yndk)).root
#<div class="yndk field_wrapper">
#<label for="user_yndk">Yndk</label><select id="user_yndk" name="user[yndk]"><option value="1">Yes</option>
#<option value="2">No</option>
#<option value="999">Don't Know</option></select>
#</div><!-- class='yndk' -->
		assert_select response, 'div.yndk.field_wrapper', 1 do
			assert_select 'label[for=user_yndk]','Yndk',1 
			assert_select "select#user_yndk[name='user[yndk]']" do
				assert_select 'option[value=1]', 'Yes'
				assert_select 'option[value=2]', 'No'
				assert_select 'option[value=999]', "Don't Know"
			end
		end
	end

	test "wrapped_yndk_select" do
		@user = SimplyHelpful::User.new
		response = HTML::Document.new(
			wrapped_yndk_select(:user, :yndk)).root
#<div class="yndk field_wrapper">
#<label for="user_yndk">Yndk</label><select id="user_yndk" name="user[yndk]"><option value="1">Yes</option>
#<option value="2">No</option>
#<option value="999">Don't Know</option></select>
#</div><!-- class='yndk' -->
		assert_select response, 'div.yndk.field_wrapper', 1 do
			assert_select 'label[for=user_yndk]','Yndk',1 
			assert_select "select#user_yndk[name='user[yndk]']" do
				assert_select 'option[value=1]', 'Yes'
				assert_select 'option[value=2]', 'No'
				assert_select 'option[value=999]', "Don't Know"
			end
		end
	end

end

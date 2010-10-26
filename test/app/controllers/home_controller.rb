class HomeController < ApplicationController

	skip_before_filter :login_required

	def show
		render :text => "You are home.",
			:layout => true
	end

end

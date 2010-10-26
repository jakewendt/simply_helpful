ActionController::Routing::Routes.draw do |map|

	map.resource :home, :only => :show
	map.root :controller => :home, :action => :show

end

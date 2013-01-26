FlunkApp::Application.routes.draw do
  resources :bananas, defaults: { format: :json }
end

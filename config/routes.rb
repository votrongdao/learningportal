LearningPortal::Application.routes.draw do

  resource :search
  root :to => 'searches#show'
end

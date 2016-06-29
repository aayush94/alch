Rails.application.routes.draw do

  root to: 'application#angular'

  get 'universities' => 'universities#index'

  ##########################################
  # SCENARIOS ENDPOINT

  get 'scenarios/:id/tree' => 'scenarios#tree'
  post 'scenarios/:id/copy' => 'scenarios#copy'

  resources :scenarios do
    resources :nodes do
      resources :choices
    end
  end

  ##########################################
  # SHOWING SESSIONS ENDPOINT

  get 'sessions/:session_id' => 'showing_sessions#show'
  post 'showings/:showing_id/session' => 'showing_sessions#create'
  post 'sessions/:session_id/decide' => 'showing_sessions#decide'
  post 'sessions/:session_id/restart' => 'showing_sessions#restart'

  ##########################################
    # COURSES & SHOWINGS ENDPOINT

  put 'courses/enroll' => 'courses#enroll'
  get 'courses/:id/report' => 'courses#report'
  get 'showings/:id/report' => 'showings#report'
  get 'showings/:id/student_report' => 'showings#student_report'

  resources :courses do
    resources :showings
  end

  ##########################################
    # USERS ENDPOINT

  devise_for :users, :controllers => { :registrations => 'registrations' }

  devise_scope :user do
  	put 'users/elevate_to_instructor' => 'registrations#elevate_to_instructor'
  end

  ##########################################
  # ASSETS ENDPOINT
  resources :assets

end

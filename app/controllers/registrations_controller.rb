class RegistrationsController < Devise::RegistrationsController
  before_filter :configure_sign_up_params, only: [:create]
   before_filter :configure_account_update_params, only: [:update]
  
  # GET /resource/sign_up
  # def new
  #   super
  # end

  # POST /resource
  # def create
  #   super
  # end

  # GET /resource/edit
  # def edit
  #   super
  # end

  # PUT /resource
  #def update
    #super
  #end

  def elevate_to_instructor
    authorize! :elevate_to_instructor, User
    
    email = params[:email]
    user = User.find_by_email(email)

    if !user
      render json: { failure: "User #{email} could not be found."}, status: 404 and return
    end

    if !can_be_elevated? user
      render json: { failure: "User #{email} is already at or above instructor level."}, status: 400 and return
    end

    if user.update_attribute(:role, User.roles[:instructor])
        render json: { success: "User #{email} is now an instructor."}, status: 200 and return
    end
  end

  protected

  # You can put the params you want to permit in the empty array.
  def configure_sign_up_params
    devise_parameter_sanitizer.for(:sign_up) << [:username, :university_id]
  end

  private

  def can_be_elevated?(user)
    User.roles[user.role] < User.roles[:instructor]
  end

  # DELETE /resource
  # def destroy
  #   super
  # end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  # def cancel
  #   super
  # end

  # You can put the params you want to permit in the empty array.
  # def configure_account_update_params
  #   devise_parameter_sanitizer.for(:account_update) << :attribute
  # end

  # The path used after sign up.
  # def after_sign_up_path_for(resource)
  #   super(resource)
  # end

  # The path used after sign up for inactive accounts.
  # def after_inactive_sign_up_path_for(resource)
  #   super(resource)
  # end
end

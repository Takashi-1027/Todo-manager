class Users::RegistrationsController < Devise::RegistrationsController
  before_action :ensure_normal_user, only: [:update, :destroy]

  def ensure_normal_user
    if resource.email == 'guest@example.com'
      redirect_to user_path(current_user), alert: 'ゲストユーザーの更新・削除はできません。'
    end
  end
end

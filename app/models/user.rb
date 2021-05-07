class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :tasks, dependent: :destroy
  has_many :routine_tasks, dependent: :destroy
  validates :name, presence: true

  attachment :profile_image

  def self.guest
    find_or_create_by!(email: 'guest@example.com') do |user|
      user.password = SecureRandom.urlsafe_base64
      user.name = "ゲストユーザー"
      user.introduction = "よろしくお願いいたします。"
      # user.confirmed_at = Time.now  # Confirmable を使用している場合は必要となる
      # 例えば name を入力必須としているならば， user.name = "ゲスト" なども必要
    end
  end
end

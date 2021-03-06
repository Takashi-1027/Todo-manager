class Task < ApplicationRecord
  belongs_to :user
  # has_many :comments, dependent: :destroy
  has_many :label_maps, dependent: :destroy
  has_many :labels, through: :label_maps
  has_many :notifications, dependent: :destroy
  validates :title, presence: true
  validates :priority, presence: true
  validates :status, presence: true
  validate :start_end_check

  # 優先ステータス
  enum priority: {最高: 0, 高: 1, 中: 2 , 低: 3}

  # タスクの進捗ステータス
  # enum status: {未着手: 0, 着手中: 1, 保留: 2 , 遅れ: 3 , 完了: 4}
  enum status: {未着手: 0, 保留: 1, 遅れ: 2 , 着手中: 3 , 完了: 4}

  # ドラッグ&ドロップに関係するソース
  include RankedModel
  ranks :row_order

  # ソート機能の定義
  # 昇順(asc) : 0,1,2,3
  # 降順(desc) : 3,2,1,0
  scope :order_by_key, -> (selection) {
    case selection
    when 'priority'
      order(priority: :asc)
    when 'status'
      order(status: :desc)
    when 'new'
      order(created_at: :desc)
    when 'old'
      order(created_at: :asc)
    end
  }

  # def self.sort(selection)
  #   case selection
  #   when nil
  #     return all
  #   when 'priority'
  #     return order(priority: :asc)
  #   when 'status'
  #     return order(status: :desc)
  #   when 'new'
  #     return order(created_at: :desc)
  #   when 'old'
  #     return order(created_at: :asc)
  #   end
  # end

  def save_label(sent_labels)
    current_labels = self.labels.pluck(:label_name) unless self.labels.nil?
    old_labels = current_labels - sent_labels
    new_labels = sent_labels - current_labels

    old_labels.each do |old|
      self.labels.delete = Label.find_by(label_name: old)
    end

    new_labels.each do |new|
      new_task_label = Label.find_or_create_by(label_name: new)
      # なかった場合、Label.new,　あった場合は、Label.find
      self.labels << new_task_label
    end
  end

  def start_end_check
    if start_date.present? && end_date.present?
      if self.start_date > self.end_date
        errors.add(:end_date, "cannot be registered as a date before the start date.") # 終了日は開始日より前の日付で登録できません。
      end
    end
  end

end

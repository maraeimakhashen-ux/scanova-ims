class ImsSetting < ApplicationRecord
  validates :key, presence: true, uniqueness: true
  validates :value, presence: true

  def self.get(key)
    find_by(key: key)&.value
  end

  def self.set(key, value)
    setting = find_or_initialize_by(key: key)
    setting.value = value
    setting.save!
    setting
  end

  def self.all_as_hash
    all.each_with_object({}) { |s, h| h[s.key] = s.value }
  end
end

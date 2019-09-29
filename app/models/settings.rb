# frozen_string_literal: true

class Settings
  def self.method_missing(method, *arguments, &block)
    method_name = method.to_s

    if method_name.end_with?("=")
      var_name = method_name.sub("=", "")
      value = arguments.first
      Setting.find_or_create_by(key: var_name).update!(value: value)
    else
      if (setting = Setting.find_by(key: method_name))
        setting.value
      else
        super
      end
    end
  end

  def self.default(method, value)
    unless Setting.exists?(key: method)
      self.send("#{method}=", value)
    end
  rescue ActiveRecord::StatementInvalid
    # noop
  end

  def self.respond_to_missing?(method_name, include_private = false)
    method_name.to_s.end_with?("=") || Setting.exists?(key: method_name) || super
  end
end

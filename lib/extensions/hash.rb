class Hash
  def symbolize_keys
    inject({}) do |options, (key, value)|
      value = value.symbolize_keys if defined?(value.symbolize_keys)
      options[(key.to_sym rescue key) || key] = value
      options
    end
  end
end

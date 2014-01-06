class Hash
  # https://github.com/rails/rails/blob/c48a0cac626b4e32d7abfa9f4f1fae16568157d9/activesupport/lib/active_support/core_ext/hash/keys.rb
  #
  # Destructively convert all keys, as long as they respond. This includes the keys from the root hash and from all nested hashes.
  #
  def deep_symbolize_keys!
    deep_transform_keys!{ |key| key.to_sym rescue key }
  end

  def deep_stringify_keys!
    deep_transform_keys!{ |key| key.to_s rescue key }
  end

  def deep_transform_keys! &block
    keys.each do |key|
      value = delete(key)
      self[yield(key)] = value.is_a?(Hash) ? value.deep_transform_keys!(&block) : value
    end
    self
  end
end

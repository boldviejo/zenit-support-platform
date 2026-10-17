# Anthropic structured outputs reject numeric, string-length and most array-size constraints with a 400.
# The official Anthropic SDKs strip them before sending; RubyLLM sends the schema as-is, so strip them here.
# TODO: Remove when RubyLLM drops unsupported constraints for Anthropic itself.
module RubyLlmAnthropicOutputSchema
  UNSUPPORTED_KEYWORDS = %w[minimum maximum exclusiveMinimum exclusiveMaximum multipleOf minLength maxLength maxItems].freeze
  SCHEMA_MAP_KEYWORDS = %w[properties $defs definitions].freeze

  def self.sanitize(node, schema_map: false)
    case node
    when Hash then sanitize_hash(node, schema_map)
    when Array then node.map { |item| sanitize(item) }
    else node
    end
  end

  # Keys inside properties/$defs are names, not keywords, so only their values are sanitized.
  def self.sanitize_hash(node, schema_map)
    node.each_with_object({}) do |(key, value), result|
      next if !schema_map && unsupported?(key.to_s, value)

      result[key] = sanitize(value, schema_map: !schema_map && SCHEMA_MAP_KEYWORDS.include?(key.to_s))
    end
  end

  def self.unsupported?(keyword, value)
    UNSUPPORTED_KEYWORDS.include?(keyword) || (keyword == 'minItems' && value.to_i > 1)
  end

  private

  def build_output_config(schema)
    config = super
    config[:format][:schema] = RubyLlmAnthropicOutputSchema.sanitize(config[:format][:schema])
    config
  end
end

RubyLLM::Providers::Anthropic.prepend(RubyLlmAnthropicOutputSchema)

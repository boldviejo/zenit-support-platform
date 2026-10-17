# frozen_string_literal: true

require 'agents'

# RubyLLM memoizes its model registry on first lookup, so point it at the app registry before any chat resolves a model.
RubyLLM.configure { |config| config.model_registry_file = Rails.root.join('config/llm_models.json').to_s }

Rails.application.config.after_initialize do
  api_key = InstallationConfig.find_by(name: 'CAPTAIN_OPEN_AI_API_KEY')&.value
  model = InstallationConfig.find_by(name: 'CAPTAIN_OPEN_AI_MODEL')&.value.presence || LlmConstants::DEFAULT_MODEL
  api_endpoint = InstallationConfig.find_by(name: 'CAPTAIN_OPEN_AI_ENDPOINT')&.value || LlmConstants::OPENAI_API_ENDPOINT
  anthropic_api_key = InstallationConfig.find_by(name: 'CAPTAIN_ANTHROPIC_API_KEY')&.value

  if api_key.present? || anthropic_api_key.present?
    Agents.configure do |config|
      config.openai_api_key = api_key if api_key.present?
      config.anthropic_api_key = anthropic_api_key if anthropic_api_key.present?
      if api_endpoint.present?
        api_base = "#{api_endpoint.chomp('/')}/v1"
        config.openai_api_base = api_base
      end
      config.default_model = model
      config.debug = false
    end
  end
rescue StandardError => e
  Rails.logger.error "Failed to configure AI Agents SDK: #{e.message}"
end

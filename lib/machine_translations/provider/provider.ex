defprotocol Accent.MachineTranslations.Provider do
  def enabled?(provider)
  def translate(provider, entries, source_language, target_language)
end

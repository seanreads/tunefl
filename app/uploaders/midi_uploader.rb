# +MidiUploader+ concerns an attached MIDI file. It uses CarrierWave to
# provide much of the functionality. It is designed to work with a CDN, such as
# Rackspace Cloud Files, with the option of using local storage for development.
#
# If the environment variable +FOG_PROVIDER+ is set, the CDN is used. Otherwise,
# file-based storage is used.
class MidiUploader < CarrierWave::Uploader::Base
  
  storage (ENV['FOG_CREDENTIALS'] ? :fog : :file)
  
  # Returns the path used for storage, which depends on which model mounts it.
  # Used by CarrierWave to set storage location.
  #
  # @return [String] Path used for storage.
  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end
  
  # Returns the whitelist of extensions allowed for an uploaded file.
  # Used by CarrierWave to set validate uploaded file extension.
  #
  # Extensions allowed are:
  # - +.midi+
  # - +.mid+
  #
  # @return [Array<String>] Extensions whitelist.
  def extension_white_list
    %w(midi mid)
  end
  
end

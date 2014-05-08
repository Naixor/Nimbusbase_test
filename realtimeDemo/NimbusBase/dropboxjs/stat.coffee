# The result of stat-ing a file or directory in a user's Dropbox.
class Dropbox.Stat
  # Creates a Stat instance from a raw "metadata" response.
  #
  # @param {?Object} metadata the result of parsing JSON API responses that are
  #   called "metadata" in the API documentation
  # @return {?Dropbox.Stat} a Stat instance wrapping the given API response;
  #   parameters that aren't parsed JSON objects are returned as they are
  @parse: (metadata) ->
    if metadata and typeof metadata is 'object'
      new Dropbox.Stat metadata
    else
      metadata

  # @return {String} the path of this file or folder, relative to the user's
  #   Dropbox or to the application's folder
  path: null

  # @return {String} the name of this file or folder
  name: null

  # @return {Boolean} if true, the file or folder's path is relative to the
  #   application's folder; otherwise, the path is relative to the user's
  #   Dropbox
  inAppFolder: null

  # @return {Boolean} if true, this Stat instance describes a folder
  isFolder: null

  # @return {Boolean} if true, this Stat instance describes a file
  isFile: null

  # @return {Boolean} if true, the file or folder described by this Stat
  #   instance was from the user's Dropbox, and was obtained by an API call
  #   that returns deleted items
  isRemoved: null

  # @return {String} name of an icon in Dropbox's icon library that most
  #   accurately represents this file or folder
  #
  # See the Dropbox API documentation to obtain the Dropbox icon library.
  # https://www.dropbox.com/developers/reference/api#metadata
  typeIcon: null

  # @return {String} an identifier for the contents of the described file or
  #   directories; this can used to be restored a file's contents to a
  #   previous version, or to save bandwidth by not retrieving the same
  #   folder contents twice
  versionTag: null

  # @return {String} a guess of the MIME type representing the file or folder's
  #   contents
  mimeType: null

  # @return {Number} the size of the file, in bytes; null for folders
  size: null

  # @return {String} the size of the file, in a human-readable format, such as
  #   "225.4KB"; the format of this string is influenced by the API client's
  #   locale
  humanSize: null

  # @return {Boolean} if false, the URL generated by thumbnailUrl does not
  #   point to a valid image, and should not be used
  hasThumbnail: null

  # @return {Date} the file or folder's last modification time
  modifiedAt: null

  # @return {?Date} the file or folder's last modification time, as reported by
  #   the Dropbox client that uploaded the file; this time should not be
  #   trusted, but can be used for UI (display, sorting); null if the server
  #   does not report any time
  clientModifiedAt: null

  # Creates a Stat instance from a raw "metadata" response.
  #
  # @private
  # This constructor is used by Dropbox.Stat.parse, and should not be called
  # directly.
  #
  # @param {Object} metadata the result of parsing JSON API responses that are
  #   called "metadata" in the API documentation
  constructor: (metadata) ->
    @path = metadata.path
    # Ensure there is a trailing /, to make path processing reliable.
    @path = '/' + @path if @path.substring(0, 1) isnt '/'
    # Strip any trailing /, to make path joining predictable.
    lastIndex = @path.length - 1
    if lastIndex >= 0 and @path.substring(lastIndex) is '/'
      @path = @path.substring 0, lastIndex

    nameSlash = @path.lastIndexOf '/'
    @name = @path.substring nameSlash + 1

    @isFolder = metadata.is_dir || false
    @isFile = !@isFolder
    @isRemoved = metadata.is_deleted || false
    @typeIcon = metadata.icon
    if metadata.modified?.length
      @modifiedAt = new Date Date.parse(metadata.modified)
    else
      @modifiedAt = null
    if metadata.client_mtime?.length
      @clientModifiedAt = new Date Date.parse(metadata.client_mtime)
    else
      @clientModifiedAt = null

    switch metadata.root
      when 'dropbox'
        @inAppFolder = false
      when 'app_folder'
        @inAppFolder = true
      else
        # New "root" value that we're not aware of.
        @inAppFolder = null

    @size = metadata.bytes or 0
    @humanSize = metadata.size or ''
    @hasThumbnail = metadata.thumb_exists or false

    if @isFolder
      @versionTag = metadata.hash
      @mimeType = metadata.mime_type || 'inode/directory'
    else
      @versionTag = metadata.rev
      @mimeType = metadata.mime_type || 'application/octet-stream'

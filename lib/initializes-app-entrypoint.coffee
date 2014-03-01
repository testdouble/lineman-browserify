findsRoot = require('find-root-package')
grunt = require('lineman').grunt
sh = require('execSync')

module.exports =
  initialize: (dir = process.cwd()) ->
    topDir = findsRoot.findTopPackageJson(dir)
    return unless isInstalledAsDependency(dir, topDir)
    new EntryPoint(topDir).ensureExists()


isInstalledAsDependency = (dir, topDir) ->
  topDir? && topDir != dir


class EntryPoint

  constructor: (@projectDir, name='entrypoint') ->
    process.chdir @projectDir
    @configuredPattern = sh.exec("lineman config --process files.browserify.entrypoint").stdout
    @default = "app/js/#{name}.coffee"

  ensureExists: ->
    if @exists(@configuredPattern)
      console.log "Entry point file '#{@configuredPattern}' already exists; skipping..."

    else
      console.log("Writing a default entry point file '#{@default}' into '#{@projectDir}'")
      grunt.file.write @default, @contents

  exists: (pattern) ->
    !!grunt.file.expand(pattern).length

  contents: """
            window._ = require("underscore")
            require("./hello")

            """

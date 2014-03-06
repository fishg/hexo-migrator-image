# Hexo
extend = hexo.extend
util = hexo.util
file = util.file
sourceDir = hexo.source_dir

# Modules
request = require 'request'
async = require 'async'
colors = require 'colors'

# Local
Source = require './MarkdownSource'

colorfulLog = (verb, count, msg) ->
        format = "#{verb.green}"
        format += if count? then "\t#{count}\t".cyan else ""
        format += msg
        console.log format

openSourceFolder = (next) ->
        colorfulLog "Open", 1, sourceDir
        file.dir sourceDir,(files) ->
                files = files.filter (f) -> f.match ".*?\.md"
                colorfulLog "Found", files.length, "posts"
                next? null, files

loadSourceFile = (files, next) ->
        # Parallelly load scripts
        tasks = []

        makeTask = (path) ->
            return (callback) ->
                src = new source path
                src.load callback

        files.forEach (f) ->

            fullPath = sourceDir + f

            tasks.push makeTask fullPath

        async.parallel tasks, (err, results) ->
            colorfulLog "Load", results.length, "source files"

            next? null, results

        
extend.migrator.register 'image', (args) ->
        console.log "whatever"
        openSourceFolder null
 













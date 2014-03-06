# Hexo
extend = hexo.extend
util = hexo.util
file = util.file
sourceDir = hexo.source_dir

# 
imageFolder = "images\\"

# Modules
request = require 'request'
async = require 'async'
colors = require 'colors'

# Local
Source = require './MarkdownSource'
Downloader = require './Downloader'

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
                        src = new Source path
                        src.load callback

        files.forEach (f) ->

                fullPath = sourceDir + f

                tasks.push makeTask fullPath

        async.parallel tasks, (err, results) ->
                colorfulLog "Load", results.length, "source files"
                sum = 0
                for src in results
                        sum += src.images.length

                colorfulLog "Found", sum, "images"
                next? null, results

downloadImages = (srcs, next) ->
        # Parallelly load scripts
        tasks = []

        # Initialize downloader
        downloader = new Downloader sourceDir + imageFolder
        
        srcs.forEach (src) ->
                src.images.forEach (img) ->
                        tasks.push (callback) ->
                                img.download downloader, callback

        colorfulLog "Download", tasks.length, "images"
        
        async.parallel tasks, (err, results) ->
                colorfulLog "Failed", (if err? then err.length else 0), "images"
                # Pass sources along, not images
                next? null, srcs

        
extend.migrator.register 'image', (args) ->
        console.log "whatever"
 
        async.waterfall [
                openSourceFolder,
                loadSourceFile,
                downloadImages
                ], (err, result) ->
                        console.log("Summary")
                        colorfulLog "Error", (if err? then err.length else 0), ""
                        colorfulLog "Success", (if result? then result.length else 0), ""

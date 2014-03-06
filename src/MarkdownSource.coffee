extend = hexo.extend
util = hexo.util
file = util.file
sourceDir = hexo.source_dir

Image = require './MarkdownImage'
async = require 'async'

MatchImageUrl = (url) ->
        re1='(.*?)'#	// Non-greedy match on filler
        re2='( )'  #	// Any Single Character 1
        re3='(")'  #	// Any Single Character 2
        re4='(.*?)'#	// Non-greedy match on filler
        re5='(")'  #	// Any Single Character 3

        p = new RegExp re1+re2+re3+re4+re5, ["i"]
        m = p.exec url
        if m?
                url = m[1]
                optional = m[4]
                return [url, optional]
        return [url, null];


MatchImageMarkDown = (src) ->
        re1='(!)'  #	// Any Single Character 1
        re2='(\\[)'#	// Any Single Character 2
        re3='(.*?)'#	// Non-greedy match on filler
        re4='(\\])'#	// Any Single Character 3
        re5='(\\()'#	// Any Single Character 4
        re6='(.*?)'#	// Non-greedy match on filler
        re7='(\\))'#	// Any Single Character 5

        ex = re1+re2+re3+re4+re5+re6+re7
        p = new RegExp ex, ["gim"]

        items = new Array()
        while (m = p.exec(src))?
                alt_ = m[3]
                rest = m[6]

                r = MatchImageUrl rest
                item = new Image alt_, r[0], r[1]
                items.push(item)

        return items


makeWorker = (img, folder) ->
    return (callback) ->
        img.download folder, callback


makeLoaderCallback = (source, callback) ->
    return (err, src) ->
        if err? then return callback(err)
        if not src? then return callback(new Error("Null source."))
        source.src = src
        source.images = MatchImageMarkDown(src)

        return callback(null, source)


module.exports = class Source
        constructor: (@path) ->
                @src = ""
                @images = []

        load: (callback) ->
                file.read(@path, makeLoaderCallback(@, callback))

###
function(path) {
     this.migrateImages = function(folder, callback) {
        workers = [];
        
        this.images.forEach(function(img) {
            workers.push(makeWorker(img, folder));
        });

        if (workers.length > 0){
            async.parallel(workers, function(err, result) {
                callback(err, result);
            });
        } 
        callback(null, null);
    };
    
 
};

###

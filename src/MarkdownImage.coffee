file = hexo.file

# downloader = require('./downloader')

module.exports = class Image
        constructor: (@alt, @url, @opt) ->
                @localPath = ""
        download: (downloader, callback) ->
                downloader.download @, () ->
                        # TODO:
                        callback?()
###
module.exports = function(alt, url, opt) {
    this.alt = alt;
    this.url = url;
    this.optionalText = opt;

    this.localPath = "";

    this.download = function(folder, callback) {
        console.log("Download: %s into %s", this.url, folder);

	var filePath = folder; 
	var d = new downloader(this.url, folder);

	d.download(function (err, result) {
            if (err) callback(err, null);
            else {
                this.localPath = result;
                callback(null, this);
            }
        });
    };
};

###

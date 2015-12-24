(function addXhrProgressEvent($) {
    var originalXhr = $.ajaxSettings.xhr;
    var isLengthNonComputable = false;
   
    $.ajaxSetup({
        progress: function() { },
        isProgressBar:false,
        timeout: 10000,
        xhr: function() {
            var xhr = originalXhr(), that = this;
            if(xhr instanceof window.XMLHttpRequest) {
                xhr.addEventListener("progress", function(evt) {
                	if (evt.lengthComputable) {  
                		//$("#nprogress .bar").css({width: 'translate3d(' + (100 - parseInt( (evt.loaded / evt.total * 100), 10)) + '%,0,0)'});
                		//var perc = parseInt( ( evt.loaded / evt.total* 100), 10)/100;
                		if(that.isProgressBar) NProgress.set(parseInt( ( evt.loaded / evt.total* 100), 10)/100);
                		//console.log("Loaded " + perc );
                	} else {
                		isLengthNonComputable = true;
                	}
                    that.progress(evt);
                },false);
                
                //console.log("addXhrProgressEvent ",xhr);
            }
            return xhr;
        },
        complete: function(evt) { 
        	if (isLengthNonComputable) {  
              	if(this.isProgressBar) NProgress.set(1);
                isLengthNonComputable=false;
             }
        },
        error: function (jqXHR, status, thrownError) {
        	var err;
        	if (status == "timeout" || thrownError=="timeout") {
        		err = " Сервер не доступен. <b>" + this.url + "</b>"; 
        	}
        	//console.log("error",thrownError,this.url);
			errorDialog( "Глюки! " + err);
        }
    });
})(jQuery);


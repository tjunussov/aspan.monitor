var HOSTNAME = (location.host == 'monitor.kazpost.kz' ? 'cloudq.kazpost.kz' : 'cloudq.kpost.kz');
var x2js = new X2JS();
var xslAllBranches = new XSLTProcessor();
var xslBranchState = new XSLTProcessor();
var xml,meta,settings, details, stats;
var UPDATE_INTERVAL_STATS = 10000;
var UPDATE_INTERVAL_DETAILS = 10000;
var _DEBUG = (localStorage.getItem('debug') === 'true')||false;
var _STOP = (localStorage.getItem('stop') === 'true')||false;
// Initialize
$(function() {
	
	// Load xslAllBranches
	$.get("_templates/allbranches_data.xsl",function(data){ 
		xslAllBranches.importStylesheet(data); 
		console.log("loadXSL all branches");
	},"xml");
	// Load xslBranchesStates
	$.get("_templates/branch_state.xsl",function(data){ 
		xslBranchState.importStylesheet(data);
		console.log("loadXSL branch states");
	},"xml");
	
	// Load Meta
	$.getJSON("http://"+HOSTNAME+"/api/branch/meta",function(json){ // http://test.aspan.io/api/meta.json?org_id=9
		meta = x2js.json2xml_str(json,'meta');
		console.log("loadMeta");
	});
	
	// Load Settings
	$.getJSON("http://"+HOSTNAME+"/api/branch/settings",function(json){  // http://test.aspan.io/api/branches.json?org_id=9&prefix=kazpost
		settings = x2js.json2xml_str(json,'settings');
		console.log("loadSettings");
		//if(localStorage.getItem('branch')){
			loadBranchDetails(localStorage.getItem('branch')||7);
		//}
	});
	
	ion.sound({
	    sounds: [
			{name: "bad_appered"},
			{name: "button_hover",volume: 0.02},
			{name: "button_out",volume: 0.02},
			{name: "button_hover_smooth"},
			{name: "data_appear"},
			{name: "loading_yashur"},
			{name: "data_loading1"},
			{name: "data_typewriter",volume: 0.04},
			{name: "typewriter1",volume: 0.04},
			{name: "typewriter2",volume: 0.04},
			{name: "typewriter3",volume: 0.04},
			{name: "reload1",volume: 0.5}
	    ],
	    volume: 0.1,
	    path: "/_sounds/",
	    preload: true
	});
		
	// Fullscreen after refresh detect
    if((window.fullScreen) || (window.innerWidth == screen.width && window.innerHeight == screen.height)) $('body').toggleClass('fullscreen');
		
	// Load every 15 seconds
	//interval(loadStats,UPDATE_INTERVAL_STATS);
	
	$("#container_branch_details").click(function(e){
		if($("#container_branch_details").css('display') == 'block'){
			$("#B"+branch).removeClass("selected");
			$("#container_branch_details").hide(); 
			play(snds.onBranchClose);
			branch = null;
			localStorage.setItem('branch',null);
			event.stopPropagation();
		}
	});
	
	//$("#container_branch_details").click(function(){event.stopPropagation();});
	
});

	// Load stats 10 seconds
// http://test.aspan.io/api/allbranches_data.json?org_id=9
function loadStats(){
	$.ajax({url:"http://"+HOSTNAME+"/api/branch",dataType:"json",isProgressBar:true,success:function(json){
		play(snds.onStatsLoad);
		stats = x2js.json2xml_str(json,'stats');
		var xmlStats = x2js.parseXmlString(stats);
		if(_DEBUG) console.log("loadStats",xmlStats);
		$("#container_branch").html(xslAllBranches.transformToFragment(xmlStats,document));
		
		$("#B"+branch).addClass("selected");
		
		$(".branch").on({ 
			mouseenter: function () { play(snds.onBranchOver); }, 
			mouseleave: function () {/* play(snds.onBranchOut);*/ },
			click: function () {
				play(snds.onBranchOpen);
				loadBranchDetails(this.getAttribute("branch"));
			}
		}).each(function(index) { // ANIMATION APPEAR
			if($(this).hasClass("selected")) return;
			if(isBranchClicked) return;
			var del = Math.floor(Math.random()*10)*100;
			$(this).fadeOut(200).delay(index*50+del).queue(function(next){
				window.setTimeout(function(){play(snds.onBranchAppear);},10);
				next();
			}).fadeIn(200);
		});
		
		isBranchClicked = false;
		
	  }
	});
}


//
var branch;
var isBranchClicked = false;
function loadBranchDetails(branch){
	$("#B"+this.branch).removeClass("selected");
	$("#B"+branch).addClass("selected");
	this.branch = branch;
	isBranchClicked = true;
	localStorage.setItem('branch',branch);
	$("#container_branch_details").show();
	interval(loadBranchDetailsData,loadStats,UPDATE_INTERVAL_DETAILS);
	//event.stopPropagation();
}

// http://test.aspan.io/api/branch_state.json?org_id=1&branch_id=7
function loadBranchDetailsData(){
	if($("#container_branch_details").css('display') == 'block' && branch){
		$.getJSON("http://"+HOSTNAME+"/api/branch/"+branch,function(json){
			//play(snds.onBranchLoad);
			details = x2js.json2xml_merge(json,settings);
			if(_DEBUG) console.log("loadBranchDetails",details);
			$("#container_branch_details").html(xslBranchState.transformToFragment(details,document));
			
			// KNOB Randomizer
			$(".knob").each(function(i){
				$(this).data('targetValue',($(this).data('targetvalue'))?$(this).data('targetvalue'):Math.floor(Math.random() * 100))
				.knob({'draw' : function () { $(this.i).val(this.cv + '%')}});
        	});
        	
        	$(".knob").animate({value:100},{
        		duration:1000,
				easing:'easeOutQuint', //easeOutElastic
				progress:function(){
					$(this).val(Math.round(this.value/100*$(this).data('targetValue'))).trigger('change')
				}
			});
			
		});
	}
}

var intervals = new Array();
function interval(func1,func2,time){
	func1();
	func2();
	if(intervals[time]) window.clearInterval(intervals[time]);
	intervals[time] = window.setInterval(function(){if(!_STOP){func1();func2();}},time);
}

var snds = {
	onBranchAppear: ["data_typewriter","typewriter1","typewriter2"],
	onStatsLoad: "data_typewriter",
	onBranchLoad: "data_typewriter",
	onBranchOver: "button_hover",
	onBranchOpen: "reload1",
	onBranchClose: "button_out",
	onMax: "button_hover_smooth"
};
function play(snd){
	if(snd.constructor === Array) {
		//console.log("array",snd.length);
		ion.sound.play(snd[Math.floor(Math.random() * snd.length)]);
	} else {
		ion.sound.play(snd);
	}
}

/*********************************/

$(document).on('keydown', function(event) {
    $(document).off('keydown');
    $(window).on('resize', function() {
        $('body').toggleClass('fullscreen');
        $(document).on('keydown'); // Turn keydown back on after functions
    });
});

function toggleFullscreen() {
	if(document.webkitIsFullScreen){
    	document.webkitExitFullscreen();
    } else {
    	document.documentElement.webkitRequestFullscreen();
    }
}

/***********************************/
var _STATUS = false;
function checkIfModified(){ 
  $.ajax({
    url : window.location.pathname,
    dataType : "text",
    ifModified : true,
    success : function(data, textStatus) {
      if (textStatus != "notmodified" && _STATUS) {
        console.log("File changed, need to refresh "+textStatus);
        window.setTimeout(function(){location.reload();},1000);
      }
      _STATUS = true;
    }
  });
}
window.setInterval(checkIfModified, 10000);

/***********************************/

function debug(){
	_DEBUG =!_DEBUG;
	localStorage.setItem('debug',_DEBUG);
	return _DEBUG;
}

function stop(){
	_STOP =!_STOP;
	localStorage.setItem('stop',_STOP);
	return _STOP;
}

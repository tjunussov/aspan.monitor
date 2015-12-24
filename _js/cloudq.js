var x2jsMeta = new X2JS();
var x2js2Setting = new X2JS();
var x2js2Stats = new X2JS();
var x2js2Branch = new X2JS();
var xslAllBranches = new XSLTProcessor();
var xslBranchState = new XSLTProcessor();
var xml,meta,settings, details, stats;
var UPDATE_INTERVAL_STATS = 10000;
var UPDATE_INTERVAL_DETAILS = 10000;
var _DEBUG = (localStorage.getItem('debug') === 'true')||false;
var _STOP = (localStorage.getItem('stop') === 'true')||false;



// Initialize
$(function() {
	
	$('#container_branch').html('<load></load>');
	
	// Load xslAllBranches
	$.get("_templates/allbranches_data.xsl",function(data){ 
		xslAllBranches.importStylesheet(data); 
		console.log("loadXSL all branches");
	},"xml");
	// Load xslBranchesStates
	$.get("_templates/branch_state.xsl",function(data){ 
		xslBranchState.importStylesheet(data);
		console.log("loadXSL branch states");
		
		loadBranchDetails(localStorage.getItem('branch')||7,localStorage.getItem('prefix')||'kazpost-010000');
		
	},"xml");
	
	// Load Meta
	/*$.getJSON("/cloudq_api/branch/meta",function(json){ // http://test.aspan.io/api/meta.json?org_id=9
		meta = x2jsMeta.json2xml_str(json,'meta');
		delete x2jsMeta;
		console.log("loadMeta");
		
		loadBranchDetails(localStorage.getItem('branch')||7,localStorage.getItem('prefix')||'kazpost-010000');
		
	});*/
	
	// Load Settings
	/*$.getJSON("/cloudq_api/branch/settings",function(json){  // http://test.aspan.io/api/branches.json?org_id=9&prefix=kazpost
		try {
		settings = x2js2Setting.json2xml_str(json,'settings'); 
		} catch(e){
			settings = "<settings/>";
			console.error("Error Parsing XML",e);
		}
		//$('body').html('<textarea>'+settings+'</textarea>');
		//settings = x2js2Setting.parseXmlString(settings);
		//console.log(settings);
		//xslBranchState.setParameter(null,"settingsRAW",settings);
		delete x2js2Setting;
		console.log("loadSettings");
		//if(localStorage.getItem('branch')){
			//loadBranchDetails(localStorage.getItem('branch')||7);
		//}
	});*/
	
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
	    path: "_sounds/",
	    preload: true
	});
		
	// Fullscreen after refresh detect
    if((window.fullScreen) || (window.innerWidth == screen.width && window.innerHeight == screen.height)) $('body').toggleClass('fullscreen');
		
	// Load every 15 seconds
	//interval(loadStats,UPDATE_INTERVAL_STATS);
	
	$("#colvir_services").click(function(e){ event.stopPropagation(); });
	$("#container_branch_details").click(function(e){ event.stopPropagation(); });
	$(".oblivion").click(function(e){
		if($("#colvir_services").hasClass('open')){
			console.log('hide');
			$("#colvir_services").removeClass("open");	
		} else {
			if($("#container_branch_details").css('display') == 'block'){
				$("#B"+branch).removeClass("selected");
				$("#container_branch_details").hide();
				$('#colvir_services').removeClass("open");
				play(snds.onBranchClose);
				branch = null;
				
				localStorage.setItem('branch',null);
				event.stopPropagation();
			}
		}
	});	
	//$("#container_branch_details").click(function(){event.stopPropagation();});
	
	
});

	// Load stats 10 seconds
// http://test.aspan.io/api/allbranches_data.json?org_id=9
function loadStats(){
	$.ajax({url:"_data/branch/allbranches_data.json",dataType:"json",isProgressBar:true,success:function(json){
		play(snds.onStatsLoad);
		stats = x2js2Stats.json2xml_str(json,'stats');
		var xmlStats = x2js2Stats.parseXmlString(stats);
		if(_DEBUG) console.log("loadStats",xmlStats);
		$("#container_branch").html(xslAllBranches.transformToFragment(xmlStats,document));
		
		$("#B"+branch).addClass("selected");
		
		$(".branch").on({ 
			mouseenter: function () { play(snds.onBranchOver); }, 
			mouseleave: function () {/* play(snds.onBranchOut);*/ },
			click: function () {
				play(snds.onBranchOpen);
				loadBranchDetails(this.getAttribute("branch"),this.getAttribute("prefix"));
			}
		}).each(function(index) { // ANIMATION APPEAR
			if($(this).hasClass("selected")) return;
			if(isBranchClicked) return;
			var del = Math.floor(Math.random()*10)*100;
			/*$(this).fadeOut(200).delay(index*50+del).queue(function(next){
				window.setTimeout(function(){play(snds.onBranchAppear);},10);
				next();
			}).fadeIn(200);*/
			/*$(this).delay(index*50+del).queue(function(next){
				$(this).css('backgroundColor','rgba(0,0,0,0.1)');
				window.setTimeout(function(obj){
					play(snds.onBranchAppear);
					$(obj).css("backgroundColor","rgba(0,0,0,0.3)"); 
				},100,this);
				next();
			});*/
		});
		
		isBranchClicked = false;
		
	  }
	});
}


//
var branch;
var prefix;

var isBranchClicked = false;
function loadBranchDetails(branch,prefix){
	$("#B"+this.branch).removeClass("selected");
	$("#B"+branch).addClass("selected");
	this.branch = branch;
	this.prefix = prefix;
	isBranchClicked = true;
	localStorage.setItem('branch',branch);
	localStorage.setItem('prefix',prefix);
	$("#container_branch_details").show();
	interval(loadBranchDetailsData,loadStats,UPDATE_INTERVAL_DETAILS);
	event.stopPropagation();
}

// http://test.aspan.io/api/branch_state.json?org_id=1&branch_id=7
function loadBranchDetailsData(){
	if($("#container_branch_details").css('display') == 'block' && branch && branch != 'null'){
		$.getJSON("_data/branch/branch_state.json?"+branch,function(json){
			//play(snds.onBranchLoad);
			try {
				loadBranchDetailsSettings(function(settings){
				
					details = x2js2Branch.json2xml_merge(json,settings);
					
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
			} catch(error){
				errorDialog(error);
			}
			
		});
	}
}


var settings_cache = new Array();

function loadBranchDetailsSettings(callback){

	if(settings_cache[prefix]) {
		if(_DEBUG) console.log("not loadSettings due to cache",prefix);
		callback(settings_cache[prefix]);
		return;
	}
	
	// Load Settings
	$.getJSON("_data/branch/settings/kazpost-010000.json?"+prefix,function(json){
		try {
			settings_cache[prefix] = x2js2Setting.json2xml_str(json,'settings'); 
		} catch(e){
			settings_cache[prefix] = "<settings/>";
			console.error("Error Parsing XML",e);
		}
		delete x2js2Setting;
		console.log("loadSettings",prefix);
		callback(settings_cache[prefix]);
	});

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


function errorDialog(error){
	$("#errormsg").show().html( "<div>" + error + "</div>" ).delay(20000).fadeOut();
}

/***********************************/
var _STATUS = false;
function checkIfModified(){ 
  $.ajax({
    url : "/_touch/touch.html", // URL for touching file
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
//window.setInterval(checkIfModified, 60000);

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


function showColvirServices(oper){
	
	//var top = Number($(event.target).position().top) - 500;
	
	if ($('#username').text().indexOf('zhannaab arailymko ainuraka astmerein diana.karabaeva a.tursunova gulmirabab daniyarm timurj') ){
		
		$('#colvir_services').addClass("open").html('<div class="branch_details"><load></load></div>');
	
		$.ajax({
			url: "_data/getuserchecksbyid.html",
			type: "GET",
			data: {
				"userid": oper,
			},success : function(data, textStatus) {
				$('#colvir_services .branch_details').html(data);
				/*$('#colvir_services td a').click(function(){
					$(this).parent().append($(this).clone());
        			$(this).remove();
        			event.stopPropagation();
				});*/
			},
			timeout: 30000,
			error : function(data, textStatus) {
				$('#colvir_services .branch_details').html('Ошибка загрузки... ' + textStatus + data);	
			}
		});
	} else {
		alert('У вас нет доступа!');
	}
	
	
	
	event.stopPropagation();
	return false;
	
}
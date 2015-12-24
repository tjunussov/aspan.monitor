var x2js2Counter = new X2JS();
var xslCounter = new XSLTProcessor();
var xml,counter;
var UPDATE_INTERVAL_STATS = 10000;
var _DEBUG = (localStorage.getItem('debug') === 'true')||false;
var _STOP = (localStorage.getItem('stop') === 'true')||false;
// Initialize
$(function() {
	
	$('#container_branch').html('<load></load>');
	
	// Load xslBranchesStates
	$.get("_templates/counter.xsl",function(data){ 
		xslCounter.importStylesheet(data);
		console.log("loadXSL counter xsl");
		
		loadCounter();
		window.setInterval(function(){if(!_STOP) loadCounter();},60000);
		
	},"xml");
	
	ion.sound({
	    sounds: [
			{name: "button_hover_smooth"},
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
				
});


function loadCounter(){
	
	
	
	$.ajax({url:"_data/counter.json",dataType:"json",isProgressBar:true,success:function(json){
		
		play(snds.onStatsLoad);

		counter = x2js2Counter.json2xml_str(json,'root');
		if(_DEBUG) console.log("Counter Sting",counter);
		var xml = x2js2Counter.parseXmlString(counter);
		
		if(_DEBUG) console.log("Counter Data",xml);
		$("#xcounter").html(xslCounter.transformToFragment(xml,document));
		
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
	}});
}

var snds = {
	onStatsLoad: "data_typewriter",
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

function errorDialog(error){
	$("#errormsg").show().html( "<div>" + error + "</div>" ).delay(20000).fadeOut();
}

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

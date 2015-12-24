<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:ui="ui" xmlns:e="entity" xmlns:xhtml="xhtml" xmlns:page="page" xmlns="html" xmlns:exslt="http://exslt.org/common" exclude-result-prefixes="exslt page e ui html xhtml">

	<!-- <Includes> -->
	
    <xsl:import href="template.xsl"/>
    
    <xsl:param name="pageXml">
    	<page:page>
			<xhtml:link rel="stylesheet" type="text/css" href="/_css/highcharts.css"/>
		    <xhtml:script type="text/javascript" src="/_assets/highcharts/highcharts.js"></xhtml:script>
		    <xhtml:script type="text/javascript" src="/_js/jquery.apear.js"></xhtml:script>
		    <xhtml:script type="text/javascript" src="/_js/highcharts_config.js"></xhtml:script>
			<xhtml:script type="text/javascript" src="/_js/reports.js"></xhtml:script>
		</page:page>
    </xsl:param>
        
	<!-- <Root> -->
    
<xsl:template match="ui:subhead">
	<div class="subhead" style="display:inline-block; float:left;">
        <h1>
            <span class="icon48 nedv"></span><xsl:value-of select="."/>
            <sub><xsl:value-of select="@sub"/></sub>
        </h1>
    </div>
    <!--
	    <div class="panel-filter filters" style="display:inline-block; float:right;">	        
	        <div class="filter">Период : <a href="#" class="selected">Сегодня</a><a href="#">За неделю</a><a href="#">За месяц</a></div>
	        <hr />
	        <input style="width:30px;" type="button"/> <input type="text" value="07 Дек 2014"/> - <input type="text" value="07 Дек 2014"/>
	        <button class="mini"><span class="icon reload"></span></button>
	    </div>
	 -->
</xsl:template>

<div class="menu-utils" style="float:right;margin-right: 20px;text-align: right;">
            <!--div class="user">Пользователь, <b id="username"--><!--#echo var="USERNAME"--><!--/b></div-->
            Режим : 
            <div class="settings-panel"><a href="/presentation">Презентация</a> <!--  &bull; <a href="#">Выход</a--></div>
        </div>
    
<xsl:template match="ui:report">
	<xsl:call-template name="report-script"/>
	<div class="panel">
		<xsl:attribute name="style">
			<xsl:if test="@width">width:<xsl:value-of select="@width"/>; float:left;</xsl:if>
			<xsl:if test="@height">height:<xsl:value-of select="@height"/>;</xsl:if>
		</xsl:attribute>
		<xsl:if test="@title"><h3><span class="icon graph"></span><xsl:value-of select="@title"/></h3></xsl:if>
		<xsl:if test="@sub"><h4><xsl:value-of select="@sub"/>&#160;<span name="{@id}_date" class="date">на </span></h4></xsl:if>
		<xsl:apply-templates select="text()|img|h3|h2|h1|span|div|pre|sup|sub|b|i|br"/>
		<div class="appearing" id="report_{@id}" style="height:100%; min-height:400px; margin-bottom:-10px;">
			<div id="tbl_{@id}"></div>
			<xsl:apply-templates select="ui:graph"/>
			<div id="tbl_{@id}_dtl" style="display:none;"></div>
		</div>
		<xsl:apply-templates select="ui:data" mode="html"/>
	</div>
</xsl:template>
    
<xsl:template match="ui:data"></xsl:template>

<xsl:template match="ui:data" mode="html">
	<br/><b><span name="{@name}"><xsl:value-of select="@title"/></span></b>
</xsl:template>

<xsl:template name="report-script">
    	<script>
		
		// структура
		var report_<xsl:value-of select="@id"/>_object = {
			graph:function(){},
			init:function(){
				
	    		var $this = this;
	    		var report = '<xsl:value-of select="@id"/>';
		    	var url = '<xsl:value-of select="@url"/>';
		    	
		<xsl:choose>
			<xsl:when test="@url">
				// Впихиваем, иконку загрузки в таблицу куда, должны подгрузиться данные
		    	var tbl = $('#tbl_'+report);
		    		tbl.html('<load></load>');
		    
		    	// Запрашиваем данные отчета
		    	//if(!tbl.attr('loaded')){
					$.get(url, function(xml) {
						console.log('loaded report',report);
						// Загоняем данные в табличку
					    var $xml = $('#tbl_'+report).html(xml).hide().attr('loaded','yes'); // Прячем таблицу с данными, если график вызывается;
					    $this.graph(report,$xml);
					    $('.period').html("");
					    $xml.find('PRE[ID="date"]').each(function(i, value) {
					    	$('.period').html("на "+ $(value).text());
					    });
					    // Проставляем дату
					    spanValue(report+'_date',$xml.find('PRE').text());
					    
					    // Другие переменные
					  <xsl:for-each select="ui:data">
					    spanValue('<xsl:value-of select="@name"/>',$xml.find('[ID="<xsl:value-of select="@name"/>"]').text());
					  </xsl:for-each>
					});
				/*} else {
					$this.graph(report,tbl.html());
				}*/
		    </xsl:when>
			<xsl:otherwise>		    	
				// Если отчет без URL
		    	console.log('not url');
				this.graph(report);
				
			</xsl:otherwise>
		</xsl:choose>
		    },
			opts:null
		};
		
		// callback функции,
		function report_<xsl:value-of select="@id"/>(){
			report_<xsl:value-of select="@id"/>_object.init();
		}

	    </script>
    </xsl:template>
    
<xsl:template match="ui:graph">
    <div id="graph_{../@id}" style="display:none; height:100%;"></div>
    <script>
    
    report_<xsl:value-of select="../@id"/>_object.graph = function (report,$xml){
    	console.log('graph report ',report);
    	

    	// копируем общие настройки 
    	var $column;
    	var nodata = true;
    	var opts = jQuery.extend(true,{},options);
    		this.opts = opts;
    		
    		<xsl:if test="@legend"></xsl:if>
    	    
			// Настройки колонок
	<xsl:apply-templates select="ui:serie" mode="column"/>
	    
			// push categories
	<xsl:choose>
		<xsl:when test="ui:cathegories">
        	opts.xAxis[0].categories = [<xsl:value-of select="ui:cathegories"/>];
			opts.xAxis[0].labels.rotation = <xsl:value-of select="ui:cathegories/@label-rotation"/>||0;
			opts.xAxis[0].labels.style.fontSize = <xsl:value-of select="ui:cathegories/@font-size"/>||10;
        </xsl:when>
        <xsl:when test="@external">
        	$xml.find('.table_2 TR').not(':first').each(function(i, tr) {
	    		opts.xAxis[<xsl:value-of select="position()-1"/>].categories.push($(tr).children('td:nth-child(1)').text());
	    	});
        </xsl:when>
        <xsl:when test="@cat-column">
        	$xml.find('TR').not(':first').each(function(i, tr) {
	    		opts.xAxis[0].categories.push($(tr).children('td:nth-child(<xsl:value-of select="@cat-column"/>)').text());
	    	});
        </xsl:when>
        <xsl:otherwise>
        	$xml.find('TR').not(':first').each(function(i, tr) {
	    		opts.xAxis[<xsl:value-of select="position()-1"/>].categories.push($(tr).children('td:nth-child(1)').text());
	    	});
        </xsl:otherwise>
    </xsl:choose>
	     
		// Настройки серий
	<xsl:apply-templates select="ui:serie"/>
		    
		if(nodata) $('#graph_'+report).html('<nodata>No data</nodata>').show();
		else $('#graph_'+report).show().highcharts(opts);
	    
	} // end function
	
    </script>
</xsl:template>

<xsl:template match="ui:serie[@type='bar']" mode="column">
	opts.xAxis[0].labels.y = 2;
    <xsl:choose>
		<xsl:when test="@title">
        	$column = '<xsl:value-of select="@title"/>';
        </xsl:when>
        <xsl:when test="@data-column">
        	$column = $xml.find('tr:first th:nth-child(<xsl:value-of select="@data-column"/>)').text();
        </xsl:when>
        <xsl:otherwise>
        	$column = $xml.find('tr:first th:nth-child(<xsl:value-of select="position()+1"/>)').text();
        </xsl:otherwise>
    </xsl:choose>
    		// Копируем настройки с 1го элемента
    		opts.yAxis.push(jQuery.extend(true,{},opts.yAxis[0]));
    		
	    	// Загоняем формат колонок
	    	opts.yAxis[<xsl:value-of select="position()-1"/>].labels.format='<xsl:value-of select="@format"/>';
	    	opts.yAxis[<xsl:value-of select="position()-1"/>].labels.y = 30;
	    	opts.series.push({
	        	name: $column,
		        type: '<xsl:value-of select="@type"/>',
		        tooltip: {valueSuffix: ' <xsl:value-of select="@valueSuffix"/>'},
		        data: []
		    });
</xsl:template>

<xsl:template match="ui:serie[@type='column' or @type='pie' or @type='line' or @type='area' or @type='areaspline']" mode="column">
	<xsl:choose>
		<xsl:when test="@title">
	    	$column = '<xsl:value-of select="@title"/>';
	    </xsl:when>
	    <xsl:when test="@data-column">
	    	$column = $xml.find('tr:first th:nth-child(<xsl:value-of select="@data-column"/>)').text();
	    </xsl:when>
	    <xsl:otherwise>
	    	$column = $xml.find('tr:first th:nth-child(<xsl:value-of select="position()+1"/>)').text();
	    </xsl:otherwise>
	</xsl:choose>

	<xsl:choose>
		<xsl:when test="@multicolumn">
	    	// Копируем настройки с 1го элемента
			opts.yAxis.push(jQuery.extend(true,{},opts.yAxis[0]));

	    	// Загоняем формат колонок
	    	opts.yAxis[<xsl:value-of select="position()-1"/>].labels.format='<xsl:value-of select="@format"/>';
	    	//opts.yAxis[<xsl:value-of select="position()-1"/>].title.text=$column;
	    	opts.series.push({
	        	name: $column,
		        type: '<xsl:value-of select="@type"/>',
				<xsl:if test="@color"> color: '<xsl:call-template name="color"/>',</xsl:if>
		        yAxis: <xsl:value-of select="position()-1"/>,
		        tooltip: {valueSuffix: ' <xsl:value-of select="@valueSuffix"/>'},
		        data: []
		    });
	    </xsl:when>
	    <xsl:otherwise>
			// Копируем настройки с 1го элемента
			opts.yAxis.push(jQuery.extend(true,{},opts.yAxis[0]));

	    	// Загоняем формат колонок
	    	opts.yAxis[<xsl:value-of select="position()-1"/>].labels.format='<xsl:value-of select="@format"/>';
	    	//opts.yAxis[<xsl:value-of select="position()-1"/>].title.text=$column;
	    	opts.series.push({
	        	name: $column,
		        type: '<xsl:value-of select="@type"/>',
				<xsl:if test="@color"> color: '<xsl:call-template name="color"/>',</xsl:if>
		        yAxis: <!-- <xsl:value-of select="position()-1"/> -->0,
		        tooltip: {valueSuffix: ' <xsl:value-of select="@valueSuffix"/>'},
		        data: []
		    });
	    </xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="ui:serie[@type='column' or @type='line' or @type='area' or @type='areaspline']">
	<xsl:choose>
		<xsl:when test=".!= ''">
        	opts.series[<xsl:value-of select="position()-1"/>].data = [<xsl:value-of select="."/>];
        	nodata = false;
        </xsl:when>
        <xsl:when test="@external">
        	<xsl:variable name="column">
        		<xsl:choose><xsl:when test="@data-column"><xsl:value-of select="@data-column"/></xsl:when><xsl:otherwise><xsl:value-of select="position()+1"/></xsl:otherwise></xsl:choose>
    		</xsl:variable>
	        $xml.find('.table_2 TR').not(':first').each(function(i, tr) {
	        	opts.series[<xsl:value-of select="position()-1"/>].data.push(Number($(tr).children('td:nth-child(<xsl:value-of select="$column"/>)').text()));
	        	nodata = false;
	        });
        </xsl:when>
        <xsl:otherwise>
        	<xsl:variable name="column">
        		<xsl:choose><xsl:when test="@data-column"><xsl:value-of select="@data-column"/></xsl:when><xsl:otherwise><xsl:value-of select="position()+1"/></xsl:otherwise></xsl:choose>
    		</xsl:variable>
        $xml.find('TR').not(':first').each(function(i, tr) {
        	opts.series[<xsl:value-of select="position()-1"/>].data.push(Number($(tr).children('td:nth-child(<xsl:value-of select="$column"/>)').text()));
        	nodata = false;
        });
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template match="ui:serie[@type='bar']">
	<xsl:choose>
		<xsl:when test=".!= ''">
        	opts.series[<xsl:value-of select="position()-1"/>].data = [<xsl:value-of select="."/>];
        	nodata = false;
        </xsl:when>
        <xsl:otherwise>
        	<xsl:variable name="column">
        		<xsl:choose><xsl:when test="@data-column"><xsl:value-of select="@data-column"/></xsl:when><xsl:otherwise><xsl:value-of select="position()+1"/></xsl:otherwise></xsl:choose>
    		</xsl:variable>
    	
    	$xml.find('TR').not(':first').each(function(i, tr) {
        	opts.series[<xsl:value-of select="position()-1"/>].data.push(Number($(tr).children('td:nth-child(<xsl:value-of select="$column"/>)').text()));
        	nodata = false;
        });
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template match="ui:serie[@type='pie']">
	<xsl:choose>
		<xsl:when test=".!= ''">
        	opts.series[<xsl:value-of select="position()-1"/>].data = [<xsl:value-of select="."/>];
        	nodata = false;
        </xsl:when>
        <xsl:otherwise>
        	<xsl:variable name="column">
        		<xsl:choose><xsl:when test="@data-column"><xsl:value-of select="@data-column"/></xsl:when><xsl:otherwise><xsl:value-of select="position()+1"/></xsl:otherwise></xsl:choose>
    		</xsl:variable>
    	// patch for pie charts
        $xml.find('TR').not(':first').each(function(i, tr) {
        	opts.series[<xsl:value-of select="position()-1"/>].data.push({y:Number($(tr).children('td:nth-child(<xsl:value-of select="$column"/>)').text()),name:opts.xAxis[0].categories[i]});
        	nodata = false;
        });
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>


<xsl:template name="color">
    <xsl:choose>
    	<xsl:when test="not(@color)">rgba(255,180,0,0.8)</xsl:when>
		<xsl:when test="@color = 'kazpost_yellow'">rgba(255,180,0,0.8)</xsl:when>
		<xsl:when test="@color = 'kazpost_lightyellow'">rgba(255,180,0,.5)</xsl:when>
		<xsl:when test="@color = 'kazpost_blue'">rgba(1,86,164,0.8)</xsl:when>
		<xsl:when test="@color = 'kazpost_grey'">rgba(150,150,150,.5)</xsl:when>
		<xsl:when test="@color = 'kazpost_brown'">rgba(240,120,50,.8)</xsl:when>
		<xsl:when test="@color = 'kazpost_lightblue'">rgba(75, 198, 255, 0.5)</xsl:when>
		<xsl:when test="@color = 'kazpost_red'">rgba(255,0,0, 0.5)</xsl:when>
        <xsl:otherwise><xsl:value-of select="@color"/></xsl:otherwise>
    </xsl:choose>
</xsl:template>

</xsl:stylesheet>
<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:date="http://exslt.org/dates-and-times" xmlns:exslt="http://exslt.org/common" xmlns:gps="gps" exclude-result-prefixes="exslt gps date">
	
	<!--xsl:output method="xml" omit-xml-declaration="yes"/-->
	<xsl:strip-space elements="*" />
    
    <xsl:decimal-format NaN="-"/>
    
    <xsl:variable name="LIMIT_MAXSERVE" select="600000"/>
    <xsl:variable name="LIMIT_MAXWAIT" select="600000"/>
    <xsl:variable name="LIMIT_WAITCNT" select="600000"/>
    
    <xsl:param name="GPSXML">
      <gps:branches>
      	<city name="Астана" x="980" y="320">
      		<branch id="6"  code="Kazpochta-010017"/>
	        <branch id="7"  code="Kazpochta-010000"/>
        </city>
        <city name="Алматы" x="1420" y="895">
        	<branch id="21" code="Kazpochta-040008"/>
        </city>
        <city name="Караганда" x="1220" y="440">
        	<branch id="31" code="Kazpochta-100017"/>
        </city>
        <city name="Шымкент" x="960" y="830">
        	<branch id="43" code="Kazpochta-16000-Chumkent"/>
        </city>
        <city name="Тараз" x="1120" y="895">
        	<branch id="35" code="Kazpochta-080019"/>
        </city>
        <city name="Кызылорда" x="625" y="700">
        	<branch id="34" code="Kazpochta-120014"/>
        </city>
        <city name="Актау" x="330" y="830">
        	<branch id="28" code="Kazpochta-130000"/>
        	<branch id="46" code="Kazpochta-130000-Aktau"/>
        </city>
        <city name="Атырау" x="330" y="585">
        </city>
        <city name="Уральск" x="250" y="410">
        	<branch id="37" code="Kazpochta-090004"/>
        </city>
        <city name="Актобе" x="600" y="450">
        	<branch id="39" code="Kazpochta-Aktobe-030019"/>
        </city>
        <city name="Костанай" x="700" y="250">
        </city>
        <city name="Петропавловск" x="870" y="100">
        </city>
        <city name="Павлодар" x="1380" y="260">
        	<branch id="48" code="Kazpochta-140011-pavlodar"/>
        </city>
        <city name="Усть-Каменогорск" x="1620" y="440">
        </city>
        <city name="Others" x="1570" y="20">
        	<branch id="42" code="Kazpochta-090004-Test"/>
        	<branch id="30" code="Kazpochta-140011" x="1380" 	y="260"/>
	        <branch id="17" code="Kazpochta-060009" x="220" 	y="645"/>
	        <branch id="45" code="Kazpochta-101600" x="1220" 	y="240"/>
	        <branch id="13" code="Kazpochta-010000" x="990" 	y="370"/>
	        <branch id="14" code="Kazpochta-080019"	x="1350" 	y="895"/>
        </city>
      </gps:branches>
    </xsl:param>
    
    <xsl:variable name="GPS" select="exslt:node-set($GPSXML)/gps:branches[1]"/>
    
    <!--xsl:variable name="team" select="document('/data/cloudq/branches.xml')/gps:branches"/--> 

	<xsl:template match="/stats">
	
        <xsl:apply-templates select="data"/>
           
		<div class="stats" onclick="toggleFullscreen();">
		
			<h2>ВСЕГО ПО РК</h2>
			<l>НА <xsl:call-template name="formatDate"><xsl:with-param name="value" select="ts"/></xsl:call-template></l><br/>
			<hr/>
            <l>ПОСЕТИТЕЛО</l>
            <v><xsl:value-of select="format-number(sum(data/total_cnt_visitors[number(.)=number(.)]),'0 ЧЛ')"/></v><br/>
            <l>ОБСЛУЖИЛОСЬ</l>
            <v><xsl:value-of select="format-number(sum(data/serving_stat/total_cnt_is_served[number(.)=number(.)]),'0 УС')"/></v><br/>
            <l>ПОКИНУЛО</l>
            <v><xsl:value-of select="format-number(sum(data/total_cnt_visitors[number(.)=number(.)])-sum(data/serving_stat/total_cnt_is_served[number(.)=number(.)]),'0 ЧЛ')"/></v><br/>
            <hr/>
            <l>ОТДЕЛЕНИЙ</l>
            <v><xsl:value-of select="count(data)"/></v><br/>
            <l>ОПЕРАТОРОВ</l>
            <v><xsl:value-of select="sum(data/online_operators_now[number(.)=number(.)])"/><w><xsl:value-of select="sum(data/total_operators_count[number(.)=number(.)])"/></w></v><br/>
            <hr/>
            <l>ОЖИДАЮТ</l>
            <v><xsl:value-of select="format-number(sum(data/waiting_stat/total_cnt_is_waiting_now[number(.)=number(.)]),'0 ЧЛ')"/></v><br/>
            <l>ОБСЛУЖИВАЮТ</l>
            <v><xsl:value-of select="format-number(sum(data/serving_stat/total_cnt_is_serving_now[number(.)=number(.)]),'0 ЧЛ')"/></v><br/>
            <hr/>
            <l>AVG ОЦЕНКА</l>
            <v>5<w>10</w></v>
            
		</div>
	</xsl:template>

	<xsl:template match="/stats/data">
		<xsl:variable name="branch_id" select="branch_id" />
		<xsl:variable name="city" select="$GPS/city[branch/@id = $branch_id]"/>
		
		<city>
			<xsl:attribute name="style">left:<xsl:value-of select="$city/@x"/>px;top:<xsl:value-of select="$city/@y"/>px;position:absolute;</xsl:attribute>
    
			<div title="{branch_id}-{code}" id="B{branch_id}" branch="{branch_id}" class="branch">
				<xsl:if test="online_operators_now=''"><xsl:attribute name="style">opacity:0.2;</xsl:attribute></xsl:if>
	            
				<h2><xsl:value-of select="branch_title"/></h2>
	            
	            <l>ПОСЕТИЛО</l>
	            <v><xsl:value-of select="format-number(number(total_cnt_visitors),'0 ЧЛ')"/></v><br/>
	            <l>ОБСЛУЖИЛОСЬ</l>
	            <v><xsl:value-of select="format-number(number(serving_stat/total_cnt_is_served),'0 УС')"/></v><br/>
	            <!--l>ПО БРОНИ</l>
	            <v><xsl:value-of select="format-number(number(total_cnt_via_booking),'0 ЧЛ')"/></v><br/-->
	            <l>ОПЕРАТОРОВ</l>
	            <v><xsl:value-of select="format-number(number(online_operators_now),'0')"/> <w><xsl:value-of select="total_operators_count"/></w></v><br/>
	           
	            <hr/>
	            <l>ОЖИДАЮТ</l>
	            <v><xsl:value-of select="format-number(number(waiting_stat/total_cnt_is_waiting_now),'0 ЧЛ')"/></v><br/>
	            
	            <xsl:if test="waiting_stat/total_cnt_exceed_waiting!=''">
		            <l>ПРЕВЫСИЛО</l>
		            <v><xsl:value-of select="format-number(number(waiting_stat/total_cnt_exceed_waiting),'0 ЧЛ')"/></v><br/>
	            </xsl:if>
	            
	            <xsl:if test="waiting_stat/avg_time_waited!=''">
	            <l>AVG ВРЕМЯ</l>
	            <v><xsl:value-of select="format-number(number(waiting_stat/avg_time_waited) div 60 div 1000,'0 МИН')"/></v><br/>
	            </xsl:if>
	            
	            <xsl:if test="waiting_stat/max_time_waiting!=''">
		            <l>МАX ВРЕМЯ</l>
		            <v>
		            	<xsl:if test="number(waiting_stat/max_time_waiting) &gt;= 900000"><xsl:attribute name="class">max blink</xsl:attribute></xsl:if>
		            	<xsl:value-of select="format-number(number(waiting_stat/max_time_waiting) div 60 div 1000,'0 МИН')"/>
		            </v><br/>
	            </xsl:if>
	            
	            <xsl:if test="waiting_stat/lane_max_time_is_waiting">
	            	<v><s><xsl:value-of select="waiting_stat/lane_max_time_is_waiting/title"/></s></v><br/>
	            </xsl:if>
	            
	            <hr/>
	            <l>ОБСЛУЖИВАЮТ</l>
	            <v>
	            	<xsl:value-of select="format-number(number(serving_stat/total_cnt_is_serving_now),'0 ЧЛ')"/><xsl:if test="serving_stat/total_cnt_is_pending_now!=''"><w><xsl:value-of select="format-number(number(serving_stat/total_cnt_is_pending_now),'0')"/></w></xsl:if>
	            </v><br/>
	            
	            
	                        
	            <xsl:if test="serving_stat/total_cnt_exceed_serving!=''">
		            <l>ПРЕВЫСИЛО</l>
		            <v><xsl:value-of select="format-number(number(serving_stat/total_cnt_exceed_serving),'0 ЧЛ')"/></v><br/>
	            </xsl:if>
	            
	            <xsl:if test="serving_stat/avg_time_served!=''">
	            <l>AVG ВРЕМЯ</l>
	            <v><xsl:value-of select="format-number(number(serving_stat/avg_time_served) div 60 div 1000,'0 МИН')"/></v><br/>
	            </xsl:if>
	            
	            <xsl:if test="serving_stat/max_time_serving!=''">
		            <l>МАX ВРЕМЯ</l>
		            <v>
		            	<xsl:if test="number(serving_stat/max_time_serving) &gt;= 600000"><xsl:attribute name="class">max blink</xsl:attribute></xsl:if>
		            	<xsl:value-of select="format-number(number(serving_stat/max_time_serving) div 60 div 1000,'0 МИН')"/>
		             </v><br/>
	            </xsl:if>
	            <xsl:if test="serving_stat/lane_max_time_is_serving">
		            <v><s><xsl:value-of select="serving_stat/lane_max_time_is_serving/title"/></s></v><br/>
		        </xsl:if>
			</div>
		</city>
	</xsl:template>
    
    
    <xsl:template name="check_limit">
        <xsl:param name="value"/>
        <xsl:if test="number($value) &gt; $LIMIT_WAITCNT"><xsl:attribute name="class">max blink</xsl:attribute></xsl:if>
    </xsl:template>
    
    <xsl:template name="formatDate">
        <xsl:param name="value" />
        <xsl:variable name="date" select="substring-before($value, 'T')" />
        <xsl:variable name="year" select="substring-before($date, '-')" />
        <xsl:variable name="month" select="substring-before(substring-after($date, '-'), '-')" />
        <xsl:variable name="day" select="substring-after(substring-after($date, '-'), '-')" />
        
        <xsl:variable name="time" select="substring-before(substring-after($value, 'T'), '.')" />
        
        <xsl:value-of select="concat($month, '-', $day, '-', $year, ' ' , $time)" />
        
      </xsl:template>

</xsl:stylesheet>
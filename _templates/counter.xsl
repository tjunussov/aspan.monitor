<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:exslt="http://exslt.org/common" xmlns:gps="gps" exclude-result-prefixes="exslt gps">
		
	<!--xsl:output method="xml" omit-xml-declaration="yes"/-->
	<xsl:strip-space elements="*" />
    
    <xsl:decimal-format NaN="-"/>
    
    <xsl:variable name="curr_hour" select="/root/curr_hour"/>
    
	<xsl:template match="/root">
	
		<div class="stats">
			<h2>ВСЕГО ПО ТРЕКИНГУ</h2>
			<l>НА <xsl:value-of select="date"/></l><br/>
			<hr/>
            <l>Общее кол</l>
            <v><xsl:value-of select="sum(*/total/*)"/></v><br/>
            <l>Главная</l>
            <v><xsl:value-of select="sum(*/index)"/></v><br/>
            <l>Событий</l>
            <v><xsl:value-of select="sum(*/events)"/></v><br/>
	        <l>Не найдено</l>
	        <v><xsl:value-of select="sum(*/not_found)"/></v><br/>
	        <l>Не верный</l>
	        <v><xsl:value-of select="sum(*/wrong_format[number(.)=number(.)])"/></v><br/>
	        <l>Запрещенный</l>
	        <v><xsl:value-of select="sum(*/forbidden[number(.)=number(.)])"/></v><br/>
	        <l>Ошибки</l>
	        <v><xsl:value-of select="sum(*/error_others[number(.)=number(.)])"/></v>
            <hr/>
	        <l>Кэш</l>
	        <v><xsl:value-of select="sum(*/from_cache[number(.)=number(.)])"/></v><br/>
	        <l>Квота</l>
	        <v><xsl:value-of select="sum(*/quota_exceed[number(.)=number(.)])"/></v>
	        <hr/>
	        <l>MAX r/s</l>
            <v><xsl:value-of select="sum(*/max[number(.)=number(.)])"/></v><br/>
            <l>AVG r/s</l>
            <v><xsl:value-of select="sum(*/avg[number(.)=number(.)])"/></v><br/>
	        
		</div>
		
		<div>
			<xsl:apply-templates select="main_api_hits|api_hits"/>
		</div>
	</xsl:template>
	
	
	<xsl:template match="main_api_hits|api_hits">
	<div class="branch_details">
	
		<xsl:variable name="total" select="sum(total/*)"/>
	
		<!--div class="knobs">
			<input class="knob" data-width="40" data-angleOffset="-90" data-fgColor="#FC0" data-linecapZZ="round" data-thickness=".2" data-readOnly="true" data-bgColor="#444444" value="0" data-targetValue="{$total}" />
			<input class="knob" data-width="40" data-angleOffset="-90" data-fgColor="#FC0" data-linecapZZ="round" data-thickness=".2" data-readOnly="true" data-bgColor="#444444" value="0" data-targetValue="{max}" />
			<input class="knob" data-width="40" data-angleOffset="-90" data-fgColor="#FC0" data-linecapZZ="round" data-thickness=".2" data-readOnly="true" data-bgColor="#444444" value="0" data-targetValue="{avg}" />
			<input class="knob" data-width="40" data-angleOffset="-90" data-fgColor="#FC0" data-linecapZZ="round" data-thickness=".2" data-readOnly="true" data-bgColor="#444444" value="0" data-targetValue="{not_found}" />
			<input class="knob" data-width="40" data-angleOffset="-90" data-fgColor="#FC0" data-linecapZZ="round" data-thickness=".2" data-readOnly="true" data-bgColor="#444444" value="0" data-targetValue="{number(not_found)*100 div $total}" />
		</div-->
		
		<h2>
			<xsl:choose>
				<xsl:when test="name()='main_api_hits'">ТРЕКИНГ САЙТ </xsl:when>
				<xsl:when test="name()='api_hits'">ТРЕКИНГ API </xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="."/>
				</xsl:otherwise>
			</xsl:choose> - <xsl:value-of select="../date"/>
		</h2>
		
		<ul style="height: 100px; margin-top:10px;">
			<li>
				<l>Общее кол</l>
		        <v><xsl:value-of select="$total"/></v><!--cursor/-->
		        <br/>
		        <l>Событий</l>
            	<v><xsl:value-of select="events"/></v>
		        <br/>
		        <l>Сейчас</l>
		        <v><xsl:value-of select="now"/></v>
		        <br/>
		        <l>Кэш</l>
		        <v><xsl:value-of select="from_cache"/></v>
		        <br/>
		        <l>Не найдено</l>
		        <v><xsl:value-of select="not_found"/></v>
		        <br/>
		        <l>Не формат</l>
		        <v><xsl:value-of select="wrong_format"/></v>
		        <br/>
		        <l>Запрещенный</l>
		        <v><xsl:value-of select="forbidden"/></v>
		        <br/>
		        <l>Ошибки</l>
		        <v><xsl:value-of select="error_others"/></v>
		     </li>
		    <li>
		    	<l>MAX r/s</l>
		        <v><xsl:value-of select="max"/><w>10</w></v>
		        <br/>
		        <l>AVG r/s</l>
		        <v><xsl:value-of select="avg"/></v>
		        <br/>
		        <l>MAX Время</l>
		        <v><xsl:value-of select="max_request_time"/></v>
		        <br/>
		        <l>AVG время</l>
		        <v><xsl:value-of select="avg_request_time"/></v>
		        <br/>
		        <l>Квота</l>
		        <v><xsl:value-of select="quota_exceed"/></v>
	        </li>
        </ul>
		
		<table class="tickets_table">
			<tr>
				<th colspan="6"><h2 style="text-align:left;">Последние 10 запросов</h2></th>
			</tr>
			<tr>
                <th style="width:100px;">IP Адрес</th>
                <!--th>С</th-->
                <th style="width:175px;">Дата</th>
                <th style="text-align:center;width:30px;">Найден</th>
                <th style="width:200px;">URL</th>
                <th style="text-align:center;width:30px;">Время</th>
                <th style="width:20px;">Кэш</th>
                <th style="width:400px;">Реферал</th>
                
            </tr>
			<xsl:for-each select="last_10_logs">
			<tr>
				<xsl:for-each select="*">
				<td>
					<xsl:choose>
						<xsl:when test="position() = 3">
							<xsl:choose>
								<xsl:when test=".=429">КВОТА</xsl:when>
								<xsl:when test=".=404">НЕТ</xsl:when>
								<xsl:when test=".=200">OK</xsl:when>
								<xsl:when test=".=406">ФОРМАТ</xsl:when>
								<xsl:when test=".=403">ЗАПРЕТ</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="."/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="."/>
						</xsl:otherwise>
					</xsl:choose>
				</td>
				</xsl:for-each>
			</tr>
			</xsl:for-each>
		</table>
		
		<h2>Общее кол-во запросов в час</h2>
		<table style="width:100%;">
		
		<tr>

			
			
			<xsl:for-each select="total/*">
			<th>
				<xsl:value-of select="substring(name(),4)"/>:00
			</th>
			</xsl:for-each>
		</tr>
		<tr style="height:100px;vertical-align: top;">
		
			<xsl:variable name="max">
				<xsl:for-each select="total/*">
					<xsl:sort select="." data-type="number" order="descending"/>
					<xsl:if test="position() = 1"><xsl:value-of select="."/></xsl:if>
				</xsl:for-each>
			</xsl:variable>
	
			<xsl:for-each select="total/*">
			<td>
				<xsl:if test="name()=$curr_hour"><xsl:attribute name="class">curr_hour</xsl:attribute></xsl:if>
				<xsl:value-of select="."/>
				<bar>
					<xsl:attribute name="style">height:<xsl:value-of select="ceiling(number(.)*100 div $max)"/>px</xsl:attribute>
					<xsl:if test="name()=$curr_hour"><xsl:attribute name="class">blink</xsl:attribute></xsl:if>
				</bar>
			</td>
			</xsl:for-each>
		 </tr>
		</table>
		
	</div>
	
	
	</xsl:template>
	
	<xsl:template name="split">
		<xsl:param name="pText" select="."/>
		<xsl:if test="string-length($pText)">
			<!--xsl:if test="not($pText=.)">
				<br />
			</xsl:if-->
			<td>
				<xsl:value-of select="substring-before(concat($pText,','),',')"/>
			</td>
			<xsl:call-template name="split">
				<xsl:with-param name="pText" select="substring-after($pText, ',')"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>
	
	

</xsl:stylesheet>
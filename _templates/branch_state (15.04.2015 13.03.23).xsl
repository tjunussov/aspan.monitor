<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:exslt="http://exslt.org/common" xmlns:gps="gps" exclude-result-prefixes="exslt gps">
	
	<xsl:param name="settingsRAW"/>
	
	<!--xsl:output method="xml" omit-xml-declaration="yes"/-->
	<xsl:strip-space elements="*" />
    
    <xsl:decimal-format NaN="-"/>
    
    <xsl:variable name="LIMIT_MAXSERVE" select="600000"/>
    <xsl:variable name="LIMIT_MAXWAIT" select="600000"/>
    <xsl:variable name="LIMIT_WAITCNT" select="600000"/>
    <xsl:variable name="LIMIT_POSTPONED" select="20"/> <!-- Лимит(Выделение Красным) на отложенные билетики -->
    <xsl:variable name="SHOW_LAST_DONE" select="20"/> <!--Показывать выполенные только за последние N минут -->
    
    
    <xsl:variable name="stats" select="/root/stats"/>
    <xsl:variable name="BRANCH_ID" select="/root/data/branch_id"/>
    <xsl:variable name="settings" select="/root/settings/data[id=$BRANCH_ID]"/>
    <xsl:variable name="CURR_TIME" select="/root/ts"/>
    
    <xsl:variable name="data" select="/root/data"/>
     <xsl:variable name="detailsXML">
        <root>
         <xsl:for-each select="$data">
         <xsl:for-each select="waiting|called|serving|done|frozen|postponed">
         <xsl:sort select="title"/>
<xsl:if test="*">
         <ticket id="{id}">
            <no>
            	<xsl:if test="is_booked='true'"><xsl:attribute name="is_booked"/></xsl:if>
                <xsl:if test="is_transfered='true'"><xsl:attribute name="is_transfered"/></xsl:if>
                <xsl:value-of select="title"/>
            </no>
            <status><xsl:attribute name="code"><xsl:value-of select="status"/></xsl:attribute>
            	<xsl:choose>
                    <xsl:when test="status='waiting'">Ж</xsl:when>
                    <xsl:when test="status='serving'">О</xsl:when>
                    <xsl:when test="status='~serving'">О</xsl:when>
                    <xsl:when test="status='~pending'">В</xsl:when>
                    <xsl:when test="status='pending'">В</xsl:when>
                    <xsl:when test="status='served'">К</xsl:when>
                    <xsl:when test="status='redirect'">П</xsl:when>
                    <xsl:when test="status='nocome-o'">Н</xsl:when>
                    <xsl:otherwise><xsl:value-of select="status"/></xsl:otherwise>
                </xsl:choose>
            </status>
            <win><xsl:value-of select="operator/unit_title"/></win>
            <oper><xsl:value-of select="operator/username"/></oper>
            <mark><xsl:value-of select="mark"/></mark>
            <ot><xsl:call-template name="toNum"><xsl:with-param name="value" select="t_ot"/></xsl:call-template></ot>
            <wt>
                <xsl:choose>
                    <xsl:when test="t_lct!=''">
                        <xsl:call-template name="diffTime">
                            <xsl:with-param name="value" select="t_lct"/>
                            <xsl:with-param name="minus" select="t_ot"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:when test="t_ct!=''">
                        <xsl:call-template name="diffTime">
                            <xsl:with-param name="value" select="t_ct"/>
                            <xsl:with-param name="minus" select="t_ot"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="diffTime">
                            <xsl:with-param name="value" select="$CURR_TIME"/>
                            <xsl:with-param name="minus" select="t_ot"/>
                        </xsl:call-template>
                    </xsl:otherwise>
                </xsl:choose>
            </wt>
            <pt><xsl:attribute name="time">
                    <xsl:call-template name="formatTime"><xsl:with-param name="value" select="t_ct"/></xsl:call-template>
                </xsl:attribute>
                <xsl:attribute name="value">
	                <xsl:call-template name="toNum"><xsl:with-param name="value" select="t_ct"/></xsl:call-template>
                </xsl:attribute>
                <xsl:choose>
                	<xsl:when test="t_st='' and t_ft!=''">
                        <xsl:call-template name="diffTime">
                            <xsl:with-param name="value" select="t_ft"/>
                            <xsl:with-param name="minus" select="t_ct"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:when test="t_st!=''">
                        <xsl:call-template name="diffTime">
                            <xsl:with-param name="value" select="t_st"/>
                            <xsl:with-param name="minus" select="t_ct"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="diffTime">
                            <xsl:with-param name="value" select="$CURR_TIME"/>
                            <xsl:with-param name="minus" select="t_ct"/>
                        </xsl:call-template>
                    </xsl:otherwise>
                </xsl:choose>
            </pt>
            <st>
            	<xsl:attribute name="ft_delta">
            		<xsl:call-template name="diffTime">
                        <xsl:with-param name="value" select="$CURR_TIME"/>
                        <xsl:with-param name="minus" select="t_ft"/>
                    </xsl:call-template>
                </xsl:attribute>
            	<xsl:attribute name="time">
                    <xsl:call-template name="toNum"><xsl:with-param name="value" select="t_ft"/></xsl:call-template>
                </xsl:attribute>
                
            	<xsl:choose>
                    <xsl:when test="t_ft!=''">
                        <xsl:call-template name="diffTime">
                            <xsl:with-param name="value" select="t_ft"/>
                            <xsl:with-param name="minus" select="t_st"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="diffTime">
                            <xsl:with-param name="value" select="$CURR_TIME"/>
                            <xsl:with-param name="minus" select="t_st"/>
                        </xsl:call-template>
                    </xsl:otherwise>
                </xsl:choose>
            </st>
            <lane>
            	<xsl:call-template name="laneName">
                    <xsl:with-param name="value" select="lane_id"/>
                </xsl:call-template>
            </lane>
         </ticket>
</xsl:if>
        </xsl:for-each>
        </xsl:for-each>
       </root>
    </xsl:variable>
    
    <xsl:variable name="details" select="exslt:node-set($detailsXML)/root[1]"/>
    
	<!--xsl:key name="tickets" match="path" use="."/-->
    
	<xsl:template match="/root">
	<!--xsl:variable name="branch" select="$stats/data[branch_id=$BRANCH_ID]"/-->
	<xsl:variable name="onine_operators" select="count(data/online_operators/username)"/>
	<xsl:variable name="clients_cnt" select="count(data/waiting)"/>
	<xsl:variable name="units" select="count($settings/unit_list[type='operator'])"/>
	
	<xsl:variable name="waiting2onine_operators" select="floor($onine_operators*100 div $clients_cnt)"/>
	<xsl:variable name="online2offline_operators" select="floor($onine_operators*100 div $units)"/>
		
		
		
		<!--xsl:value-of select="count($settingsRAW)"/-->
	
		<div class="branch_details">
			
			<h2>ОТДЕЛЕНИЕ - <xsl:value-of select="data/branch_title"/></h2>
			<ul>
				<li>
		            <l>ВРЕМЯ</l>
		            <v><xsl:call-template name="formatDate"><xsl:with-param name="value" select="ts"/></xsl:call-template></v><xsl:if test="not($details/ticket)"><cursor/></xsl:if><br/>
		            <l>ПОСЕТИЛО</l>
		            <v><xsl:value-of select="format-number(number(data/visitors_cnt),'0 ЧЛ')"/></v>
	            </li>
	            <li>
		            <l>ЗАГРУЗКА ОКОН</l>
		            <v><xsl:value-of select="$waiting2onine_operators"/>%  <xsl:value-of select="$onine_operators"/>OPER/ <xsl:value-of select="$clients_cnt"/>CLNT</v><br/>
		            <l>ЗАГРУЗКА ОПЕР</l>
		            <v><xsl:value-of select="$online2offline_operators"/>% <xsl:value-of select="$onine_operators"/> ИЗ <xsl:value-of select="$units"/></v>
	            </li>
            </ul>
            <br/>
            
			<xsl:apply-templates select="data"/>
			
			<div class="knobs">
				<input class="knob" data-width="40" data-angleOffset="-90" data-fgColor="#FC0" data-linecapZZ="round" data-thickness=".2" data-readOnly="true" data-bgColor="#444444" value="0" data-targetValue="{$waiting2onine_operators}" />
				<input class="knob" data-width="40" data-angleOffset="-90" data-fgColor="#FC0" data-linecapZZ="round" data-thickness=".2" data-readOnly="true" data-bgColor="#444444" value="0" data-targetValue="{$online2offline_operators}"/>
			</div>
			<div class="graph"></div>
			
			<div class="diagram">
			
			<xsl:if test="$details/ticket[status/@code='postponed']">
			<xsl:for-each select="$details/ticket[status/@code='postponed']">
				<dp title="{no}">
					<xsl:if test="number(st/@ft_delta) &gt; $LIMIT_POSTPONED"><xsl:attribute name="class">max</xsl:attribute></xsl:if>
				</dp>
			</xsl:for-each>
			<br/>
			</xsl:if>
			
			<xsl:for-each select="$details/ticket[status/@code='waiting']">
			<xsl:sort select="ot" order="descending"/>
				<wp title="{no}">
					<xsl:if test="number(wt) &gt;= 15"><xsl:attribute name="class">max</xsl:attribute></xsl:if>
				</wp>
			</xsl:for-each>
			
			<hr/>
			
			<div class="ops">
			<xsl:variable name="uts" select="data/online_operators/unit_title"/>
			<xsl:variable name="ps" select="$details/ticket[status/@code='pending']"/>
			<xsl:variable name="ss" select="$details/ticket[status/@code='serving']"/>
			
			<xsl:for-each select="$settings/unit_list[type='operator']">
				<xsl:sort select="title"/>
				<xsl:variable name="win" select="title"/>
				<h>
					<xsl:for-each select="$ps[win=$win]">
						<pp title="{no}">
							<xsl:if test="number(pt) &gt;= 2"><xsl:attribute name="class">max</xsl:attribute></xsl:if>
						</pp>
					</xsl:for-each>
						<br/>
					<xsl:for-each select="$ss[win=$win]">
						<sp title="{no}">
							<xsl:if test="number(st) &gt;= 10"><xsl:attribute name="class">max</xsl:attribute></xsl:if>
						</sp>
					</xsl:for-each>
						<br/>
						<op title="{$win}">
							<xsl:if test="not($uts[.=$win])"><xsl:attribute name="class">offline</xsl:attribute></xsl:if>
						</op>
				</h>
			</xsl:for-each>
			</div>
			</div>
		</div>
	</xsl:template>
    
	
  
	<xsl:template match="/root/data">
		    
            <table class="stats_table" style="margin-top:14px;">
            <tr>
                <th rowspan="2"><h2 style="text-align:left;">УСЛУГИ ОЖИДАНИЯ и ОБСЛУЖИВАНИЯ</h2></th>
                <th rowspan="2" style="width:15px;">ОПЕР</th>
                <th colspan="4" style="text-align:center; border:1px solid #444;">ОЖИДАНИЕ <xsl:value-of select="count(waiting/id)"/></th>
                <th style="text-align:center; border:1px solid #444;">ИДЕТ</th>
                <th colspan="4" style="text-align:center; border:1px solid #444;">ОБСЛУЖИВАНИЕ <xsl:value-of select="count(serving/id)"/></th>
                <!--th rowspan="2" style="text-align:center; border:1px solid #444;">КОЛ<br/>ВО</th-->
            </tr>
            <tr>
                <th>0-10</th>
                <th>10-15</th>
                <th>15-30</th>
                <th>30&lt;</th>
                <th><xsl:value-of select="count(called/id)"/></th>
                <th>0-10</th>
                <th>10-15</th>
                <th>15-30</th>
                <th>30&lt;</th>
            </tr>
            <xsl:for-each select="$settings/lane_list">
            <xsl:sort select="title"/>
            <xsl:variable name="laneId" select="id"/>
            <xsl:variable name="laneName" select="title"/>
            <xsl:variable name="lane" select="$details/ticket[lane=$laneName]"/>
            
            <tr><td>[
            <xsl:for-each select="$settings/cat_list">
            	<xsl:value-of select="title"/>-<xsl:value-of select="count(nodes)"/>
            </xsl:for-each>
            ]
            </td></tr>
            
            <xsl:variable name="ou" select="$settings/unit_list[id=$data/online_operators/unit_id][lanes=$laneId]"/>
            <tr>
                <td><xsl:value-of select="title"/></td>
                <td style="width:15px;">▲ <xsl:value-of select="count($ou)"/></td>
                <td><xsl:call-template name="noZero"><xsl:with-param name="value" select="count($lane[number(wt) &lt;= 10 and status/@code='waiting'])"/></xsl:call-template></td>
                <td><xsl:call-template name="noZero"><xsl:with-param name="value" select="count($lane[10 &lt; number(wt) and number(wt) &lt;= 15 and status/@code='waiting'])"/></xsl:call-template></td>
                <td><xsl:call-template name="noZero"><xsl:with-param name="value" select="count($lane[15 &lt; number(wt) and number(wt) &lt;= 30 and status/@code='waiting'])"/></xsl:call-template></td>
                <td><xsl:call-template name="noZero"><xsl:with-param name="value" select="count($lane[30 &lt; number(wt) and status/@code='waiting'])"/></xsl:call-template></td>
                <td><xsl:call-template name="noZero"><xsl:with-param name="value" select="count($lane[status/@code='pending'])"/></xsl:call-template></td>
                <td><xsl:call-template name="noZero"><xsl:with-param name="value" select="count($lane[number(st) &lt;= 10 and status/@code='serving'])"/></xsl:call-template></td>
                <td><xsl:call-template name="noZero"><xsl:with-param name="value" select="count($lane[10 &lt; number(st) and number(st) &lt;= 15 and status/@code='serving'])"/></xsl:call-template></td>
                <td><xsl:call-template name="noZero"><xsl:with-param name="value" select="count($lane[15 &lt; number(st) and number(st) &lt;= 30 and status/@code='serving'])"/></xsl:call-template></td>
                <td><xsl:call-template name="noZero"><xsl:with-param name="value" select="count($lane[30 &lt; number(st) and status/@code='serving'])"/></xsl:call-template></td>
                <!--td><xsl:call-template name="noZero"><xsl:with-param name="value" select="count($lane)"/></xsl:call-template></td-->
            </tr>
            </xsl:for-each>
            </table>
            
            <br/>
            
            <h2>ТАЛОНЫ и ОПЕРАТОРЫ</h2>
            <table class="tickets_table">
            <tr>
                <th style="width:200px;">ТАЛОН / ОКНО / ОПЕРАТОР</th>
                <!--th>С</th-->
                <th style="text-align:right;width:30px;">ВИЗИТ</th>
                <th style="text-align:right;width:40px;">ЖДЕТ</th>
                <th style="text-align:right;width:40px;">ИДЕТ</th>
                <th style="text-align:right;width:40px;">ПРИЕМ</th>
                <th style="width:300px;">УСЛУГА</th>
                
            </tr>
            <xsl:if test="count($details/ticket[status/@code='waiting']) = 0">
            <tr>
            	<td><span style="color:#777;">ОЖИДАЮЩИХ НЕТ</span></td>
            	<td></td><td></td><td></td><td></td><td></td>
            </tr>
            </xsl:if>
            
            <!--xsl:if test="count($details/ticket[status/@code='waiting']) &gt; 10">
            <xsl:for-each select="$details/ticket[status/@code='waiting'][position() &gt; last()-10]">
            <xsl:sort select="ot" order="descending"/>
            <xsl:sort select="no" order="descending"/>
             <tr title="{@id}">
                <td><t><xsl:value-of select="no"/></t>
                	<xsl:if test="no/@is_booked"><span style="color:#FFF;">B</span></xsl:if>
	                <xsl:choose>
		                <xsl:when test="no/@is_transfered">
			                <xsl:choose>
			                	<xsl:when test="status='Ж'">←&#160;&#160;&#160;<span style="color:#777;">ТРАНСФЕР ОЖИДАЕТ...</span></xsl:when>
			                	<xsl:otherwise>←</xsl:otherwise>
			                </xsl:choose>
		                </xsl:when>
		                <xsl:otherwise>
		                	<xsl:choose>
			                	<xsl:when test="status='Ж'">&#160;&#160;&#160; <span style="color:#777;">ОЖИДАЕТ...</span></xsl:when>
			                	<xsl:otherwise>→</xsl:otherwise>
			                </xsl:choose>
		                </xsl:otherwise>
	                </xsl:choose></td>
                <td><xsl:call-template name="formatTimeNum"><xsl:with-param name="value" select="ot"/></xsl:call-template></td>
                <td title="{wt/@time}" style="text-align:right;">
                	<xsl:attribute name="class"> cur <xsl:if test="number(wt) &gt;= 15 and not(status/@frozen)">max blink</xsl:if></xsl:attribute>
                	<c><xsl:value-of select="format-number(number(wt),'0 МИН')"/></c></td>
                <td></td>
                <td></td>
                <td><xsl:value-of select="lane"/></td>
             </tr>
            </xsl:for-each>
            <tr class="more">
            	<td>... <xsl:value-of select="count($details/ticket[status/@code='waiting'])"/> ЧЛ ожидают</td>
            	<td>...</td><td>...</td><td>...</td><td>...</td><td>...</td>
            </tr> [position() &lt; 10]
            </xsl:if-->
            
            <xsl:for-each select="$details/ticket[status/@code='waiting']">
            <xsl:sort select="ot" order="descending"/>
            <xsl:sort select="no" order="descending"/>
             <tr title="{@id}">
                <td><t><xsl:value-of select="no"/></t>
                	<xsl:if test="no/@is_booked"><span style="color:#FFF;">B</span></xsl:if>
	                <xsl:choose>
		                <xsl:when test="no/@is_transfered">
			                <xsl:choose>
			                	<xsl:when test="status='Ж'">←&#160;&#160;&#160;<span style="color:#777;">ТРАНСФЕР ОЖИДАЕТ...</span></xsl:when>
			                	<xsl:otherwise>←</xsl:otherwise>
			                </xsl:choose>
		                </xsl:when>
		                <xsl:otherwise>
		                	<xsl:choose>
			                	<xsl:when test="status='Ж'">&#160;&#160;&#160; <span style="color:#777;">ОЖИДАЕТ...</span></xsl:when>
			                	<xsl:otherwise>→</xsl:otherwise>
			                </xsl:choose>
		                </xsl:otherwise>
	                </xsl:choose></td>
                <!--td><xsl:value-of select="status"/></td-->
                <td><xsl:call-template name="formatTimeNum"><xsl:with-param name="value" select="ot"/></xsl:call-template></td>
                <td title="{wt/@time}" style="text-align:right;">
                	<xsl:attribute name="class"> cur <xsl:if test="number(wt) &gt;= 15 and not(status/@frozen)">max blink</xsl:if></xsl:attribute>
                	<c><xsl:value-of select="format-number(number(wt),'0 МИН')"/></c></td>
                <td></td>
                <td></td>
                <td><xsl:value-of select="lane"/></td>
             </tr>
            </xsl:for-each>
            <tr>
            	<td style="height:5px;"></td><td></td><td></td><td></td><td></td><td></td><td></td>
            </tr>
            
            <xsl:for-each select="$settings/unit_list[type='operator']">
	            <xsl:sort select="title"/>
	            <xsl:variable name="win" select="title"/>
		        <xsl:variable name="tickets" select="$details/ticket[win=$win]"/>
		        <xsl:variable name="online_operator" select="/root/data/online_operators[unit_title=$win]"/>
	        
	        	<tr>
	        		<td><t></t><span style="visibility:hidden;">→</span><w><xsl:value-of select="title"/></w> <xsl:value-of select="$online_operator/username"/></td>
	        		<td></td>
	        		<td></td>
	        		<td></td>
	        		<td></td>
	        		<td></td>
	        	</tr>
	        
		        <!-- SERVING + PEDNING -->
		        <xsl:for-each select="$tickets[status/@code='pending' or status/@code='serving']">
		        <xsl:sort select="pt/@time" order="descending"/>
		        <!--tr>
			        <xsl:choose>
	                	<xsl:when test="position()=1">
	                		<td>FIRST <xsl:value-of select="win"/>-<xsl:value-of select="no"/>-<xsl:value-of select="status/@code"/>-<xsl:value-of select="pt/@time"/></td>
	                	</xsl:when>
	                	<xsl:otherwise>
	                		<td><xsl:value-of select="win"/>-<xsl:value-of select="no"/>-<xsl:value-of select="status/@code"/>-<xsl:value-of select="pt/@time"/></td>
	                	</xsl:otherwise>
	                </xsl:choose>
		        </tr-->
		        <tr title="{status/@code}-{@id}">	
		            <td>
		            	<t><xsl:value-of select="no"/><xsl:if test="no/@is_booked"><span style="color:#FFF;">B</span></xsl:if></t>
		            	<xsl:choose>
		                	<xsl:when test="no">
			                	<xsl:choose>
					                <xsl:when test="no/@is_transfered">
						                <xsl:choose>
						                	<xsl:when test="status='В'"><span class="blink">←</span></xsl:when>
						                	<xsl:otherwise>←</xsl:otherwise>
						                </xsl:choose>
					                </xsl:when>
					                <xsl:otherwise>
					                	<xsl:choose>
						                	<xsl:when test="status='В'"><span class="blink">→</span></xsl:when>
						                	<xsl:otherwise>→</xsl:otherwise>
						                </xsl:choose>
					                </xsl:otherwise>
				                </xsl:choose>
		                	</xsl:when>
		                	<xsl:otherwise><span style="visibility:hidden;">→</span></xsl:otherwise>
		                </xsl:choose>
		                <span style="color:#777;"> ├ 
		                <xsl:choose><xsl:when test="status/@code='pending'"> ИДЕТ...</xsl:when><xsl:otherwise> ПРИНИМАЕТ...</xsl:otherwise></xsl:choose>
		                </span>
		            	<!--w><xsl:value-of select="win"/></w> <xsl:value-of select="oper"/-->
		            </td>
		           	<td><xsl:call-template name="formatTimeNum"><xsl:with-param name="value" select="ot"/></xsl:call-template></td>
	                <td style="text-align:right;">
	                	<!--xsl:choose>
		                	<xsl:when test="."-->
		                		<xsl:attribute name="class"><xsl:if test="number(wt) &gt;= 15">max </xsl:if></xsl:attribute>
	                			<xsl:value-of select="format-number(number(wt),'0 МИН')"/>
		                	<!--/xsl:when>
		                	<xsl:otherwise>
		                		<xsl:attribute name="class"> cur</xsl:attribute>
		                		<xsl:variable name="ft_delta_idle_time" select="number($tickets[(status/@code='served' or status/@code='nocome-o' or status/@code='redirect')]/st/@ft_delta)"/>
		                		<c>
		                		<xsl:choose>
		                			<xsl:when test="$ft_delta_idle_time"><xsl:value-of select="format-number($ft_delta_idle_time,'0 МИН')"/></xsl:when>
		                			<xsl:otherwise--><!--Ждет с открытия сессии. если небыло талонов-->
			                			<!--xsl:call-template name="diffTime">
				                            <xsl:with-param name="value" select="$CURR_TIME"/>
				                            <xsl:with-param name="minus" select="ts"/>
				                        </xsl:call-template> МИН
			                        </xsl:otherwise>
		                		</xsl:choose>
			            		</c>
		            		</xsl:otherwise>
		                </xsl:choose-->
	                </td>
	                <td style="text-align:right;">
	                	<xsl:attribute name="class"><xsl:if test="number(pt) &gt; 2">max </xsl:if><xsl:if test="status/@code='pending'">  cur </xsl:if></xsl:attribute>
	                	<c><xsl:value-of select="format-number(number(pt),'0 МИН')"/></c></td>
	                <td style="text-align:right;">
	                	<xsl:attribute name="class"><xsl:if test="number(st) &gt;= 10">max </xsl:if><xsl:if test="status/@code='serving'"> cur</xsl:if></xsl:attribute>
	                	<c><xsl:value-of select="format-number(number(st),'0 МИН')"/></c>
		            </td>
	                <td><xsl:value-of select="lane"/></td>
		        </tr>
		        </xsl:for-each>
		        
		        <!-- POSTPONED -->
		        <xsl:for-each select="$tickets[status/@code='postponed']">
	             <tr title="Отложен - {@id}" class="postponed">
	                <td><t><xsl:value-of select="no"/></t>
	                	<xsl:if test="no/@is_booked"><span style="color:#FFF;">B</span></xsl:if>&#160;&#160;<span style="color:#777;">├ ОТЛОЖЕН на </span>
		                <span> 
		                	<xsl:attribute name="class">blink <xsl:if test="number(st/@ft_delta) &gt; 20">max</xsl:if></xsl:attribute>
		                	 <xsl:value-of select="format-number(number(st/@ft_delta),'0 МИН')"/>
		                </span>
		            </td>
	                <!--td><xsl:value-of select="status"/></td-->
	                <td><xsl:call-template name="formatTimeNum"><xsl:with-param name="value" select="ot"/></xsl:call-template></td>
	                <td style="text-align:right;">
	                	<xsl:if test="number(wt) &gt;= 15"><xsl:attribute name="class">max</xsl:attribute></xsl:if>
	                	<xsl:value-of select="format-number(number(wt),'0 МИН')"/>
	                	</td>
	                <td style="text-align:right;">
	                	<xsl:if test="number(pt) &gt; 2"><xsl:attribute name="class">max</xsl:attribute></xsl:if>
	                	<xsl:value-of select="format-number(number(pt),'0 МИН')"/></td>
	                <td style="text-align:right;">
	                	<xsl:if test="number(st) &gt;= 10"><xsl:attribute name="class">max</xsl:attribute></xsl:if>
		                <xsl:value-of select="format-number(number(st),'0 МИН')"/></td>
	                <td><xsl:value-of select="lane"/></td>
	             </tr>
	            </xsl:for-each>
		       
		        <!-- DONE -->
		        <xsl:for-each select="$tickets[(status/@code='served' or status/@code='nocome-o' or status/@code='redirect') and st/@ft_delta &lt; $SHOW_LAST_DONE]">
		        <xsl:sort select="st/@time" order="descending"/>
		        
		        <xsl:variable name="st"><xsl:choose><xsl:when test="number(st)"><xsl:value-of select="number(st)" /></xsl:when><xsl:otherwise>0</xsl:otherwise></xsl:choose></xsl:variable>
		        <xsl:variable name="sd" select="wt + pt + $st"/>
		        
		        <tr class="served">
		            <td>
		            	<t><xsl:value-of select="no"/></t><xsl:if test="no/@is_booked"><span style="color:#FFF;">B</span></xsl:if>&#160;&#160;└  <span style="color:#777;">ОБСЛУЖЕН за </span>
		            	<span style="color:#777;"> 
		                	<xsl:attribute name="class"><xsl:if test="$sd &gt; 20">max</xsl:if></xsl:attribute>
		                	<xsl:value-of select="format-number($sd,'0 МИН')"/>
		                </span>
		                <xsl:if test="mark!=''"><span style="color:#FFF;"> → <xsl:value-of select="mark" /></span></xsl:if>
		            </td>
		           	<td><xsl:call-template name="formatTimeNum"><xsl:with-param name="value" select="ot"/></xsl:call-template></td>
	                <td style="text-align:right;">
	                	<xsl:if test="number(wt) &gt;= 15"><xsl:attribute name="class">max</xsl:attribute></xsl:if>
	                	<xsl:value-of select="format-number(number(wt),'0 МИН')"/></td>
	                <td style="text-align:right;">
	                	<xsl:attribute name="class"><xsl:if test="number(pt) &gt; 2">max</xsl:if></xsl:attribute>
	                	<xsl:value-of select="format-number(number(pt),'0 МИН')"/></td>
	                <td style="text-align:right;">
	                	<xsl:if test="number(st) &gt;= 10"><xsl:attribute name="class">max</xsl:attribute></xsl:if>
	                	<xsl:choose>
		                	<xsl:when test="status/@code='nocome-o'">НЕЯВКА</xsl:when>
		                	<xsl:otherwise><xsl:value-of select="format-number(number(st),'0 МИН')"/></xsl:otherwise>
		                </xsl:choose>
		            </td>
	                <td><xsl:value-of select="lane"/></td>
		        </tr>
		        </xsl:for-each>
		        
		        
            </xsl:for-each>
            </table>
            
	</xsl:template>
    
    <xsl:template name="ticket">
    <tr>
        <td><xsl:value-of select="title"/></td>
        <td><xsl:value-of select="status"/></td>
        <td><xsl:value-of select="operator/unit_title"/></td>
        <td><xsl:value-of select="operator/username"/></td>
        <td><xsl:call-template name="formatTime"><xsl:with-param name="value" select="t_st"/></xsl:call-template></td>
     </tr>
    </xsl:template>
    
    
    <xsl:template name="limit">
        <xsl:param name="value"/>
        <xsl:param name="limit"/>
        <xsl:if test="number($value) &gt;= $limit"><xsl:attribute name="class">max</xsl:attribute></xsl:if>
    </xsl:template>
    
    <xsl:template name="laneName">
        <xsl:param name="value" />
        <xsl:choose>
	         <xsl:when test="$settings/lane_list[id=$value]/title=''">
	       		EMPTY LANE NAME
	       	</xsl:when>
	       	<xsl:when test="$settings/lane_list[id=$value]/title">
	       		<xsl:value-of select="$settings/lane_list[id=$value]/title"/>
	       	</xsl:when>
 			<xsl:otherwise>
	       		LANE NOT FOUND WITH ID <xsl:value-of select="$value"/>
	       	</xsl:otherwise>
       	</xsl:choose>
    </xsl:template>
    
    <xsl:template name="diffTimeNum">
        <xsl:param name="value" />
        <xsl:param name="minus" />
        <xsl:value-of select="format-number((number($value)-number($minus)) div 60,'0 МИН')" />
    </xsl:template>
    
    <xsl:template name="diffTime">
        <xsl:param name="value" />
        <xsl:param name="minus" />
        <xsl:variable name="date" select="substring-before(substring-after($value, 'T'), '.')" />
        <xsl:variable name="hour" select="substring-before($date,':')" />
        <xsl:variable name="min" select="substring-before(substring-after($date,':'),':')" />
        <xsl:variable name="valuetime" select="number($hour)*60+number($min)" />
        
        <xsl:variable name="date1" select="substring-before(substring-after($minus, 'T'), '.')" />
        <xsl:variable name="hour1" select="substring-before($date1,':')" />
        <xsl:variable name="min1" select="substring-before(substring-after($date1,':'),':')" />
        <xsl:variable name="minustime" select="number($hour1)*60+number($min1)" />
        
	    <!--xsl:value-of select="concat($hour,':',$min,' ',$hour1,':',$min1)" />
        <xsl:value-of select="concat(' ',number($hour)+number($min),'+',number($hour1)+number($min1))" /-->
        <!--xsl:value-of select="concat($value,'-',$hour1)" /-->
        <xsl:value-of select="number($valuetime)-number($minustime)" />
    </xsl:template>
    
    <xsl:template name="noZero">
        <xsl:param name="value" />
        <xsl:choose>
            <xsl:when test="$value!='0'"><xsl:value-of select="$value" /></xsl:when>
            <xsl:otherwise></xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template name="toNum">
        <xsl:param name="value" />
        <xsl:variable name="date" select="substring-before(substring-after($value, 'T'), '.')" />
        <xsl:variable name="hour" select="substring-before($date,':')" />
        <xsl:variable name="min" select="substring-before(substring-after($date,':'),':')" />
        <xsl:variable name="sec" select="substring($value,18,2)" />
        <xsl:if test="$value!=''">
	        <xsl:value-of select="number($hour)*60*60+number($min)*60+number($sec)" />
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="formatTimeNum">
        <xsl:param name="value" />
        <xsl:variable name="hour" select="format-number(floor(number($value) div 3600),'00')" />
        <xsl:variable name="min" select="format-number(number($value) mod 3600 div 60,'00')" />
        <xsl:if test="$value!=''">
	        <xsl:value-of select="concat($hour,':',$min)" />
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="formatTime">
        <xsl:param name="value" />
        <xsl:variable name="date" select="substring-before(substring-after($value, 'T'), '.')" />
        <xsl:variable name="hour" select="substring-before($date,':')" />
        <xsl:variable name="min" select="substring-before(substring-after($date,':'),':')" />
        <xsl:if test="$value!=''">
	        <xsl:value-of select="concat($hour,':',$min)" />
        </xsl:if>
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
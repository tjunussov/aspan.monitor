<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:exslt="http://exslt.org/common" xmlns:gps="gps" exclude-result-prefixes="exslt gps">
	
	<!--xsl:output method="xml" omit-xml-declaration="yes"/-->
	<xsl:strip-space elements="*" />
    
    <xsl:decimal-format NaN="-"/>
    
    <xsl:variable name="LIMIT_MAXSERVE" select="600000"/>
    <xsl:variable name="LIMIT_MAXWAIT" select="600000"/>
    <xsl:variable name="LIMIT_WAITCNT" select="600000"/>
    
    <xsl:param name="GPSXML">
      <gps:branches>
        <branch id="21" code="Kazpochta-040008" x="1500" 	y="750"/>
        <branch id="28" code="Kazpochta-130000"	x="230" 	y="885"/>
        <branch id="7"  code="Kazpochta-010000" x="990" 	y="370"/>
        <branch id="6"  code="Kazpochta-010017"	x="990" 	y="280"/>
        <branch id="30" code="Kazpochta-140011" x="1300" 	y="180"/>
        <branch id="39" code="Kazpochta-030019"	x="520" 	y="415"/>
        <branch id="34" code="Kazpochta-120014"	x="725" 	y="760"/>
        <branch id="31" code="Kazpochta-100017"	x="1220" 	y="400"/>
        <branch id="35" code="Kazpochta-080019"	x="1120" 	y="895"/>
        <branch id="17" code="Kazpochta-060009" x="220" 	y="645"/>
      </gps:branches>
    </xsl:param>
    
    <xsl:variable name="GPS" select="exslt:node-set($GPSXML)/gps:branches[1]"/>
    
    <!--xsl:variable name="team" select="document('/data/cloudq/branches.xml')/gps:branches"/--> 


	<xsl:template match="/root">
        <xsl:apply-templates/>
        <xsl:if test="count(.)=0">
            Нет записей
        </xsl:if>
	</xsl:template>

	<xsl:template match="/root/data">
		<xsl:variable name="branchId" select="branchId" />
    
		<div title="{branchId}-{code}" class="branch">
            <xsl:for-each select="$GPS/branch[@id = $branchId and @x != '']">
                <xsl:attribute name="style">left:<xsl:value-of select="@x"/>px;top:<xsl:value-of select="@y"/>px;position:absolute;</xsl:attribute>
            </xsl:for-each>
        
			<h2><xsl:value-of select="branchTitle"/></h2>
            
            <l>ТАЛОН </l>
            <v><xsl:value-of select="maxWait/item/title"/></v><br/>
            
            <l>ТАЛОН-УСЛУГА </l>
            <v><xsl:value-of select="maxWait/item/lane/title"/></v><br/>
            
			<l>MAX ОЖИДАЮЩИЕ </l>
            <v><xsl:if test="number(waitingCnt/value) &gt; $LIMIT_WAITCNT"><xsl:attribute name="class">max</xsl:attribute></xsl:if>
            <xsl:value-of select="format-number(number(waitingCnt/value) div 60 div 1000,'0 ЧЛ')"/> </v><br/>
            
			<l>МАX ЖДУТ </l>
            <v><xsl:if test="number(maxWaiting/value) &gt; $LIMIT_MAXWAIT"><xsl:attribute name="class">max</xsl:attribute></xsl:if>
            <xsl:value-of select="format-number(number(maxWaiting/value) div 60 div 1000,'0 МИН')"/></v><br/>
            
            <l>МАX ОБСЛУЖИВАЮТСЯ </l> 
            <v><xsl:if test="number(maxServe/value) &gt; $LIMIT_MAXSERVE"><xsl:attribute name="class">max</xsl:attribute></xsl:if>
            <xsl:value-of select="format-number(number(maxServe/value) div 60 div 1000,'0 МИН')"/></v><br/>
		</div>
	</xsl:template>
    
    <xsl:template match="/root/meta/hierarchy/*">
		<div title="{branchId}-{code}" class="branch" style="opacity:0.1">
			<h2><xsl:value-of select="title"/></h2>
		</div>
	</xsl:template>
    
    <xsl:template match="/root/status">
    </xsl:template>

</xsl:stylesheet>
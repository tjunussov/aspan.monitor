<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:ui="ui" xmlns:e="entity" xmlns:page="page" xmlns="html" xmlns:exslt="http://exslt.org/common" exclude-result-prefixes="exslt page">


<xsl:template match="ui:grid[ui:item]">
	<div class="section {@class}">
    	<xsl:apply-templates/>
    </div>
</xsl:template>

<xsl:template match="ui:grid[ui:item/@limg]">
	<div class="section {@class}"> 
		<xsl:apply-templates/>
    </div>
</xsl:template>

<xsl:template match="ui:grid[ui:main]">

    <div>
    	<xsl:attribute name="class">mediumcolumn <xsl:value-of select="ui:main/@class"/> <xsl:if test="child::node()[1][self::ui:main]"> left</xsl:if></xsl:attribute>
        <xsl:apply-templates select="ui:main"/>
    </div> 
    
    <div>
    	<xsl:attribute name="class">smallcolumn <xsl:value-of select="ui:back/@class"/> <xsl:if test="child::node()[1][self::ui:back]"> left</xsl:if></xsl:attribute>
        <xsl:apply-templates select="ui:back"/>
    </div>

</xsl:template>

<xsl:template match="ui:item">
    <div class="item {@class}" style="display:table;">
        <xsl:if test="@limg">
        	<xsl:choose>
                <xsl:when test="@href">
                    <a href="{@href}">
                    	<img src="{@limg}" style="display:table-cell;border: 1px solid #EEE; vertical-align:top; margin-right:30px;" />
                    </a>
                </xsl:when>
                <xsl:otherwise>
                    <img src="{@limg}" style="display:table-cell;border: 1px solid #EEE; vertical-align:top; margin-right:30px;" />
                </xsl:otherwise>
            </xsl:choose>
        	
        </xsl:if>
        <div class="smallcolumn_section">
            <xsl:if test="@himg"><img src="_styles/assets/{@himg}" style="margin-bottom:15px;" /></xsl:if> 
            <h2>
                <xsl:choose>
                    <xsl:when test="@titleClass">
                    	<xsl:attribute name="class"><xsl:value-of select="@titleClass"/></xsl:attribute>
                        <span><xsl:value-of select="@title"/></span>
                    </xsl:when>
                    <xsl:otherwise>
                    	<xsl:value-of select="@title"/>
                    </xsl:otherwise>
                </xsl:choose>
            </h2> 
            <xsl:choose>
                <xsl:when test="p"><xsl:apply-templates mode="html"/></xsl:when>
                <xsl:otherwise><p><xsl:apply-templates mode="html"/></p></xsl:otherwise>
            </xsl:choose>
            <xsl:if test="@href"><p><a href="{@href}" target="_blank" class="featured_link"><xsl:value-of select="@link"/></a></p></xsl:if>
        </div>
    </div>
</xsl:template>



</xsl:stylesheet>
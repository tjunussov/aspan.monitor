<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:ui="ui" xmlns:e="entity" xmlns:xhtml="xhtml" xmlns:page="page" xmlns="html" xmlns:exslt="http://exslt.org/common" exclude-result-prefixes="exslt page e ui html xhtml">

	<!-- <Includes> -->
	
    <xsl:import href="template.xsl"/>
    
    <xsl:param name="pageXml">
    	<page:page>
		</page:page>
    </xsl:param>
        
	<!-- <Root> -->
    
    <xsl:template name="footer">      
		<div class="footer">
			<div class="poweredby"></div>
		</div>
	</xsl:template>

</xsl:stylesheet>
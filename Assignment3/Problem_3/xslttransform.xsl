<?xml version="1.0"?>

<xsl:stylesheet version="2.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:template match="/">
	<xsl:for-each select="Zthes/term">
	<term> 
	<xsl:attribute name="id">
	<xsl:value-of select="normalize-space(termId)"/>
	</xsl:attribute>
	<xsl:attribute name="name">
	<xsl:value-of select="normalize-space(termName)"/>
	</xsl:attribute>
	<xsl:attribute name="type">
	<xsl:value-of select="normalize-space(termType)"/>
	</xsl:attribute>
	</term>
	<xsl:for-each select="relation">
	<relation>
	<xsl:attribute name="type">
	<xsl:value-of select="normalize-space(relationType)"/>
	</xsl:attribute>
	<xsl:attribute name="term">
	<xsl:value-of select="normalize-space(termId)"/>
	</xsl:attribute>
	</relation>
	</xsl:for-each>
	</xsl:for-each>
</xsl:template>
</xsl:stylesheet>

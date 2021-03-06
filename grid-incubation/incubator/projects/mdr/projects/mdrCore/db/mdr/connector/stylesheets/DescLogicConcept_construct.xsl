<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"  xmlns:xlink="http://www.w3.org/1999/xlink">
    
    <xsl:output indent="yes" omit-xml-declaration="yes"/>
    <xsl:strip-space elements="*"/>
    
    <xsl:template match="/">
        <xsl:apply-templates select="//queryResponse"/>
        <!--
        <xsl:apply-templates
            select="doc(concat(/parameters/url, '?query=DescLogicConcept&amp;DescLogicConcept[name=',/parameters/term,']&amp;startIndex=',/parameters/startIndex,'&amp;resultCounter=',/parameters/resultCounter))/xlink:httpQuery/queryResponse"/>
            -->
    </xsl:template>

    <xsl:template match="*|@*|comment()">
        <xsl:copy>
            <xsl:apply-templates select="@*|*|text()|comment()"/>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>
 
<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0" xmlns:mdr="http://ws.cancergrid.org/exist/wsdl">
    <xsl:output omit-xml-declaration="yes" indent="yes"/>
    <xsl:template match="/">
            <xsl:copy-of select="mdr:return/*" />
    </xsl:template>
</xsl:stylesheet>
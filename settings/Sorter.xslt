<?xml version="1.0" encoding="utf-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:output omit-xml-declaration="no" indent="yes"/>
  <xsl:template match="project">
    <project>
      <xsl:apply-templates select="property">
        <xsl:sort select="@name" data-type="text" order="ascending"/>
      </xsl:apply-templates>
    </project>
  </xsl:template>
  <xsl:template match="property">
    <xsl:copy-of select="." />
  </xsl:template>
</xsl:stylesheet>
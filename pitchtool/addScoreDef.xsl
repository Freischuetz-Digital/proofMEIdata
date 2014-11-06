<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:mei="http://www.music-encoding.org/ns/mei" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" exclude-result-prefixes="xs xd" version="2.0">
  <!--
- Freischütz-Digital
- pmd.pitchControl
- Copyright Johannes Kepper 2013.
- kepper(at)edirom.de
- 
- http://www.github.com/edirom/ediromSourceManager
- 
- ## Description & License
- 
- This stylesheet pulls a scoreDef from a given file and adds it to an XML snippet as provided by the ProofMyData tool
- 
- This program is free software: you can redistribute it and/or modify
- it under the terms of the GNU General Public License as published by
- the Free Software Foundation, either version 3 of the License, or
- (at your option) any later version.
- 
- This program is distributed in the hope that it will be useful,
- but WITHOUT ANY WARRANTY; without even the implied warranty of
- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
- GNU General Public License for more details.
- 
- You should have received a copy of the GNU General Public License
- along with this program. If not, see <http://www.gnu.org/licenses/>.
-->
  <xd:doc scope="stylesheet">
    <xd:desc>
      <xd:p><xd:b>Created on:</xd:b> Jun 24, 2013</xd:p>
      <xd:p><xd:b>Author:</xd:b> johannes</xd:p>
      <xd:p> This stylesheet pulls a scoreDef from a given file and adds it to an XML snippet as provided by the ProofMyData tool. </xd:p>
    </xd:desc>
  </xd:doc>
  <xsl:output method="xml" indent="yes"/>
  <xsl:param name="pageFilePath" as="xs:string"/>
  <xsl:param name="staffN" as="xs:string"/>
  <xsl:variable name="pageFile" select="doc($pageFilePath)"/>
  <xsl:template match="/">
    <xsl:apply-templates/>
  </xsl:template>
  <xsl:template match="mei:score">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates select="$pageFile//mei:scoreDef[ancestor::mei:annot[@type='providedScoreDef']][1]"/>
      <xsl:apply-templates select="node()"/>
    </xsl:copy>
  </xsl:template>
  <xsl:template match="mei:staffGrp">
    <xsl:if test=".//mei:staffDef[@n = $staffN]">
      <xsl:copy>
        <xsl:apply-templates select="node() | @*"/>
      </xsl:copy>
    </xsl:if>
  </xsl:template>
  <xsl:template match="mei:staffDef[@n != $staffN]"/>
  <xsl:template match="node() | @*">
    <xsl:copy>
      <xsl:apply-templates select="node() | @*"/>
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>

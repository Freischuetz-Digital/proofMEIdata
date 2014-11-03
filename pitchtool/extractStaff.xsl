<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:mei="http://www.music-encoding.org/ns/mei" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" exclude-result-prefixes="xs xd xlink mei" version="2.0">
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
- This stylesheet extracts a single staff from a page-based MEI-file for conversion to abc.
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
      <xd:p><xd:b>Created on:</xd:b> Jun 21, 2013</xd:p>
      <xd:p><xd:b>Author:</xd:b> johannes</xd:p>
      <xd:p> This stylesheet extracts a single staff from a page-based MEI-file for conversion to abc. The $staffN parameter defines which staff should be extracted. The $mode parameter defines if the target is abc or something else. If $mode = 'abc', a predefined scoreDef available in the header will be embedded in the document. If $mode = 'ace' (or other), it will be returned without this addition. </xd:p>
    </xd:desc>
  </xd:doc>
  <xsl:output method="xml" indent="yes" encoding="UTF-8"/>
  <xsl:param name="staffN" as="xs:string"/>
  <xsl:param name="mode" as="xs:string"/>
  <xsl:variable name="providedScoreDef" select="exists(//mei:annot[@type = 'providedScoreDef'])" as="xs:boolean"/>
  <xsl:template match="/">
    <xsl:variable name="firstPass">
      <xsl:apply-templates select="//mei:score"/>
    </xsl:variable>
    <xsl:apply-templates select="$firstPass" mode="cleanup"/>
  </xsl:template>
  <xsl:template match="mei:score">
    <score>
      <xsl:apply-templates select="@*"/>
      <xsl:if test="$providedScoreDef and $mode = 'abc'">
        <xsl:apply-templates select="//mei:annot[@type = 'providedScoreDef']//mei:scoreDef"/>
      </xsl:if>
      <xsl:apply-templates select="node()"/>
    </score>
  </xsl:template>
  <xsl:template match="mei:staff[@n != $staffN]"/>
  <!--    <xsl:template match="mei:measure/mei:*[local-name() != 'staff' and @staff and $staffN != tokenize(@staff,' ')]"/>-->
  <xsl:template match="mei:measure/mei:*[local-name() != 'staff']"/>
  <xsl:template match="mei:staffGrp">
    <xsl:if test=".//mei:staffDef[@n = $staffN]">
      <xsl:copy>
        <xsl:apply-templates select="node() | @*"/>
      </xsl:copy>
    </xsl:if>
  </xsl:template>
  <xsl:template match="mei:staffDef[@n != $staffN]"/>
  <xsl:template match="@facs"/>
  <xsl:template match="node() | @*">
    <xsl:copy>
      <xsl:apply-templates select="node() | @*"/>
    </xsl:copy>
  </xsl:template>

  <!-- mode cleanup -->
  <xsl:template match="mei:score/text()" mode="cleanup" priority="2"/>
  <xsl:template match="mei:section/text()" mode="cleanup" priority="2"/>
  <xsl:template match="mei:measure/text()" mode="cleanup" priority="2"/>
  <xsl:template match="mei:staffGrp/text()" mode="cleanup" priority="2"/>
  <xsl:template match="*" mode="cleanup" priority="1">
    <xsl:element name="{local-name(.)}" namespace="http://www.music-encoding.org/ns/mei">
      <xsl:apply-templates select="node() | @*" mode="#current"/>
    </xsl:element>
  </xsl:template>
  <xsl:template match="text() | processing-instruction() | comment()" mode="cleanup" priority="1">
    <xsl:copy>
      <xsl:apply-templates select="node() | @*" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  <xsl:template match="@*" mode="cleanup" priority="1">
    <xsl:copy/>
  </xsl:template>
</xsl:stylesheet>

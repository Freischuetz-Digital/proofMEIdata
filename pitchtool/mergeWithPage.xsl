<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:mei="http://www.music-encoding.org/ns/mei" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" exclude-result-prefixes="xs xd" version="2.0">
  <xd:doc scope="stylesheet">
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
- This stylesheet merges one extracted and updated staff-based MEI file with a complete
- encoding of the page for saving.
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
        <xd:desc>
      <xd:p><xd:b>Created on:</xd:b> Jun 24, 2013</xd:p>
      <xd:p><xd:b>Author:</xd:b> johannes</xd:p>
      <xd:p> This stylesheet merges one extracted and updated staff-based MEI file with a complete encoding of the page for saving. </xd:p>
    </xd:desc>
  </xd:doc>
  <xsl:output method="xml" indent="yes"/>
  <xsl:param name="pageFilePath" as="xs:string">A_page127.xml</xsl:param>
  <xsl:param name="staffN" as="xs:string">1</xsl:param>
  <xsl:param name="resp" select="''" as="xs:string"/>
  <xsl:variable name="pageFile" select="doc($pageFilePath)"/>
  <xsl:variable name="changedFile" select="//mei:score"/>
  <xsl:variable name="measureCountFailed" select="not(count($changedFile//mei:measure) = count($pageFile//mei:measure) and $changedFile//mei:measure/@xml:id = $pageFile//mei:measure/@xml:id)"/>
  <xsl:variable name="sectionCountFailed" select="not(count($changedFile//mei:section) = count($pageFile//mei:section))"/>
  <xsl:template match="mei:appInfo">
    <xsl:copy>
      <xsl:apply-templates select="node() | @*"/>
      <xsl:if test="not(mei:application[@xml:id = 'pmd'])">
        <xsl:element name="application" namespace="http://www.music-encoding.org/ns/mei">
          <xsl:attribute name="xml:id" select="'pmd'"/>
          <xsl:element name="name" namespace="http://www.music-encoding.org/ns/mei">proofMEIdata</xsl:element>
          <xsl:element name="ptr" namespace="http://www.music-encoding.org/ns/mei">
            <xsl:attribute name="target" select="'http://www.freischuetz-digital.de/pmd'"/>
          </xsl:element>
        </xsl:element>
      </xsl:if>
    </xsl:copy>
  </xsl:template>
  <xsl:template match="mei:revisionDesc">
    <xsl:copy>
      <xsl:apply-templates select="node() | @*"/>
      <xsl:element name="change" namespace="http://www.music-encoding.org/ns/mei">
        <xsl:attribute name="n" select="max(//mei:change/number(@n)) + 1"/>
        <xsl:element name="respStmt" namespace="http://www.music-encoding.org/ns/mei">
          <xsl:element name="persName" namespace="http://www.music-encoding.org/ns/mei">
            <xsl:value-of select="$resp"/>
          </xsl:element>
        </xsl:element>
        <xsl:element name="changeDesc" namespace="http://www.music-encoding.org/ns/mei">
          <xsl:element name="p" namespace="http://www.music-encoding.org/ns/mei"> Checked staff <xsl:value-of select="$staffN"/> with the <xsl:element name="ref" namespace="http://www.music-encoding.org/ns/mei"><xsl:attribute name="target">#pmd</xsl:attribute><xsl:text>proofMEIdata</xsl:text></xsl:element> webservice. </xsl:element>
        </xsl:element>
        <xsl:element name="date" namespace="http://www.music-encoding.org/ns/mei">
          <xsl:attribute name="isodate" select="substring(string(current-dateTime()),1,19)"/>
        </xsl:element>
      </xsl:element>
    </xsl:copy>
  </xsl:template>
  <xsl:template match="/">
    <xsl:apply-templates select="$pageFile//mei:mei"/>
  </xsl:template>
  <xsl:template match="mei:notesStmt">
    <xsl:copy>
      <xsl:choose>
        <xsl:when test="not($measureCountFailed)">
          <xsl:apply-templates select="node() | @*"/>
        </xsl:when>
        <xsl:when test="$measureCountFailed and not($pageFile//mei:annot[@type='measureCountFailed'])">
          <xsl:apply-templates select="node() | @*"/>
          <xsl:element name="annot" namespace="http://www.music-encoding.org/ns/mei"><xsl:attribute name="type" select="'measureCountFailed'"/> The number of measures has been changed by the user. The original measures have been preserved, since a change like this should not be addressed with this tool. The change happened when correcting staff <xsl:value-of select="$staffN"/>. </xsl:element>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="(node() except mei:annot[@type='measureCountFailed']) | @*"/>
          <xsl:element name="annot" namespace="http://www.music-encoding.org/ns/mei">
            <xsl:attribute name="type" select="'measureCountFailed'"/>
            <xsl:variable name="staves" select="tokenize(substring-before(substring-after(mei:annot[@type='measureCountFailed']/text(),'staff '),'.'),', ')" as="xs:string*"/>
            <xsl:variable name="newStaves" select="distinct-values(($staves,$staffN))"/>
            <xsl:value-of select="concat(substring-before(mei:annot[@type='measureCountFailed']/text(),'staff'),' staff ',string-join($newStaves,', '),'.')"/>
          </xsl:element>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:copy>
  </xsl:template>
  <xsl:template match="mei:score">
    <xsl:copy>
      <xsl:apply-templates select="$changedFile/node()"/>
    </xsl:copy>
  </xsl:template>
  <xsl:template match="mei:measure">
    <xsl:variable name="mID" select="@xml:id"/>
    <xsl:variable name="completeMeasure" select="$pageFile//mei:measure[@xml:id = $mID]"/>
    <xsl:choose>
      <xsl:when test="not($measureCountFailed) or exists($completeMeasure)">
        <xsl:copy>
          <xsl:apply-templates select="$completeMeasure/@facs"/>
          <xsl:apply-templates select="@*"/>
          <xsl:choose>
            <xsl:when test="mei:staff/@n = $staffN">
              <xsl:apply-templates select="$completeMeasure/mei:staff[@n != $staffN] | ./mei:staff">
                <xsl:sort select="@n" data-type="number"/>
              </xsl:apply-templates>
              <!--<xsl:apply-templates select="$completeMeasure/mei:*[local-name() != 'staff' and not(@staff = tokenize($staffN,' '))] | ./mei:*[local-name() != 'staff']">-->
              <xsl:apply-templates select="$completeMeasure/mei:*[local-name() != 'staff']">
                <xsl:sort select="@staff" data-type="number"/>
              </xsl:apply-templates>
            </xsl:when>
            <xsl:otherwise>
              <xsl:message>Changing the @n attribute on &lt;mei:staff&gt; results in unprocessable data. Your changes have not been implemented in the page file. However, a processing instruction has been addedx, and your changes have been preserved in there. </xsl:message>
              <xsl:processing-instruction name="freidi_pmd"><xsl:value-of select="concat(codepoints-to-string(13),'date(',substring(string(current-date()),1,10),')',codepoints-to-string(13))"/><xsl:value-of select="concat('resp(',$resp,')',codepoints-to-string(13))"/><xsl:copy-of select="node()"/></xsl:processing-instruction>
              <xsl:copy-of select="$pageFile//mei:measure[@xml:id = $mID]/node()"/>
            </xsl:otherwise>
          </xsl:choose>
          <xsl:copy-of select="processing-instruction()"/>
        </xsl:copy>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy-of select="$completeMeasure"/>
        <xsl:processing-instruction name="freidi_pmd"><xsl:value-of select="concat(codepoints-to-string(13),'date(',substring(string(current-date()),1,10),')',codepoints-to-string(13))"/><xsl:value-of select="concat('resp(',$resp,')',codepoints-to-string(13))"/><xsl:copy-of select="."/></xsl:processing-instruction>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template match="mei:staff[@n = $staffN]">
    <xsl:variable name="sID" select="@xml:id"/>
    <xsl:variable name="completeStaff" select="$pageFile//mei:staff[@xml:id = $sID]"/>
    <xsl:choose>
      <xsl:when test="exists($completeStaff)">
        <xsl:copy>
          <xsl:apply-templates select="$completeStaff/@facs"/>
          <xsl:apply-templates select="@*"/>
          <xsl:apply-templates select="element() | processing-instruction() | text() | comment()"/>
        </xsl:copy>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy>
          <xsl:apply-templates select="node() | @*"/>
          <xsl:processing-instruction name="freidi_pmd"><xsl:value-of select="concat(codepoints-to-string(13),'date(',substring(string(current-date()),1,10),')',codepoints-to-string(13))"/><xsl:value-of select="concat('resp(',$resp,')',codepoints-to-string(13))"/><xsl:text>The original staff couldn't be found.</xsl:text></xsl:processing-instruction>
        </xsl:copy>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template match="mei:scoreDef">
    <xsl:variable name="isFirst" select="count(preceding-sibling::mei:*) = 0 and parent::mei:score" as="xs:boolean"/>
    <xsl:variable name="betweenSections" select="exists(preceding-sibling::mei:section)" as="xs:boolean"/>
    <xsl:variable name="precSections" select="if($betweenSections) then(count(preceding-sibling::mei:section)) else(-1)" as="xs:integer"/>
    <xsl:variable name="betweenMeasures" select="exists(following-sibling::mei:measure)" as="xs:boolean"/>
    <xsl:variable name="followingMeasureID" select="if($betweenMeasures) then(following-sibling::mei:measure[1]/@xml:id) else('')" as="xs:string"/>
    <xsl:choose>
      <xsl:when test="ancestor::mei:annot[@type = 'providedScoreDef']">
        <xsl:copy>
          <xsl:apply-templates select="node() | @*"/>
        </xsl:copy>
      </xsl:when>
      <xsl:when test="$isFirst">
        <xsl:variable name="pageElem" select="($pageFile//mei:score/mei:scoreDef)[1]"/>
        <xsl:copy>
          <xsl:apply-templates select="$pageElem/@*"/>
          <xsl:apply-templates select="@*"/>
          <xsl:apply-templates select="$pageElem/(mei:* | processing-instruction() | comment())">
            <xsl:with-param name="changedScoreDef" select="." tunnel="yes"/>
          </xsl:apply-templates>
        </xsl:copy>
      </xsl:when>
      <xsl:when test="$betweenSections">
        <xsl:variable name="pageElem" select="($pageFile//mei:score/mei:section[$precSections + 1]/following-sibling::mei:*[1])"/>
        <xsl:choose>
          <xsl:when test="exists($pageElem) and local-name($pageElem) = 'scoreDef'">
            <xsl:copy>
              <xsl:apply-templates select="$pageElem/@*"/>
              <xsl:apply-templates select="@*"/>
              <xsl:apply-templates select="$pageElem/(mei:* | processing-instruction() | comment())">
                <xsl:with-param name="changedScoreDef" select="." tunnel="yes"/>
              </xsl:apply-templates>
            </xsl:copy>
          </xsl:when>
          <xsl:otherwise>
            <xsl:copy>
              <xsl:apply-templates select="node() | @*"/>
            </xsl:copy>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="$betweenMeasures">
        <xsl:variable name="pageElem" select="($pageFile//mei:measure[@xml:id = $followingMeasureID]/preceding-sibling::mei:scoreDef[1])"/>
        <xsl:choose>
          <xsl:when test="exists($pageElem) and local-name($pageElem) = 'scoreDef'">
            <xsl:copy>
              <xsl:apply-templates select="$pageElem/@*"/>
              <xsl:apply-templates select="@*"/>
              <xsl:apply-templates select="$pageElem/(mei:* | processing-instruction() | comment())">
                <xsl:with-param name="changedScoreDef" select="." tunnel="yes"/>
              </xsl:apply-templates>
            </xsl:copy>
          </xsl:when>
          <xsl:otherwise>
            <xsl:copy>
              <xsl:apply-templates select="node() | @*"/>
            </xsl:copy>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
    </xsl:choose>
  </xsl:template>
  <xsl:template match="mei:staffDef[ancestor::mei:scoreDef and not(ancestor::mei:annot[@type='providedScoreDef'])]">
    <xsl:param name="changedScoreDef" tunnel="yes"/>
    <xsl:variable name="n" select="@n"/>
    <xsl:copy>
      <xsl:choose>
        <xsl:when test="$changedScoreDef//mei:staffDef[@n = $n]">
          <xsl:variable name="changedElem" select="$changedScoreDef//mei:staffDef[@n eq $n]"/>
          <xsl:apply-templates select="$changedElem/(node() | @*)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="node() | @*"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:copy>
  </xsl:template>
  <xsl:template match="node() | @*">
    <xsl:copy>
      <xsl:apply-templates select="node() | @*"/>
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>

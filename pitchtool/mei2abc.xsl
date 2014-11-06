<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="local" xmlns:mei="http://www.music-encoding.org/ns/mei" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" exclude-result-prefixes="xs xd" version="2.0">
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
- This stylesheet converts MEI into abc. It is based on 
- https://github.com/Edirom/mei2abc/blob/multiple-voices/xsl/mei2abc.xsl
- which is licensed under the following terms.
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
      <xd:p><xd:b>Created on:</xd:b> Jun 12, 2013</xd:p>
      <xd:p><xd:b>Author:</xd:b> Johannes Kepper</xd:p>
      <xd:p/>
      <xd:p> This stylesheet converts MEI into abc. </xd:p>
    </xd:desc>
  </xd:doc>
  <xsl:output encoding="UTF-8" method="text"/>
  <xd:doc scope="component">
    <xd:desc>
      <xd:p>If set to true(), xml:ids from notes, chords and rests are included as comments in the abc string.</xd:p>
    </xd:desc>
  </xd:doc>
  <xsl:param name="includeIDs" select="true()" as="xs:boolean"/>
  <xsl:param name="showTstamps" select="false()" as="xs:boolean"/>
  <xsl:variable name="file" select="."/>

  <!--<xsl:variable name="slurStarts" as="xs:string*">
        <xsl:for-each select="//mei:slur">
            <xsl:choose>
                <xsl:when test="@startid">
                    <xsl:variable name="startElem" select="$file/id(substring(@startid,2))" as="node()?"/>
                    <xsl:if test="exists($startElem) and local-name($startElem) = ('note','chord')">
                        <xsl:value-of select="substring(@startid,2)"/>
                    </xsl:if>
                </xsl:when>
                <xsl:when test="@tstamp and @staff">
                    <xsl:variable name="measure" select="parent::mei:measure" as="node()"/>
                    <xsl:variable name="tstamp" select="@tstamp" as="xs:string"/>
                    <xsl:variable name="staffN" select="@staff" as="xs:string"/>
                    <xsl:variable name="layers" select="$measure/mei:staff[@n = $staffN]/mei:layer" as="node()*"/>
                    <xsl:variable name="targets" as="xs:string()*">
                        <xsl:for-each select="$layers">
                            
                            <xsl:variable name="def" select="preceding::mei:*[@meter.unit and @meter.count and (local-name() = 'scoreDef' or @n = $staffN)][1]"/>
                            
                            <xsl:variable name="tstamp" select="local:getTstampByDef(.,$def)"/>
                            
                            <xsl:variable name="elems" select="descendant::mei:mRest[@dur] | descendant::mei:space[@dur] | descendant::mei:note[@dur and not(ancestor::mei:tuplet)] | descendant::mei:tuplet | descendant::mei:rest | descendant::mei:chord[@dur and not(.//mei:note[@dur])]"/>
                            
                            <xsl:variable name="tstamps" as="xs:string*">
                                <xsl:for-each select="$elems">
                                    <xsl:variable name="elem" select="."/>
                                    <xsl:value-of select="local:getTstampByDef($elem,$def)"/>
                                </xsl:for-each>
                            </xsl:variable>
                            
                            <xsl:variable name="index" select="index-of($tstamps,$tstamp)"/>
                            
                            <xsl:variable name="rightElem" select="$elems[$index]" as="node()?"/>
                            
                            <xsl:if test="exists($rightElem) and local-name($rightElem) = ('note','chord')">
                                <xsl:value-of select="$rightElem/@xml:id"/>    
                            </xsl:if>
                            
                        </xsl:for-each>
                    </xsl:variable>
                    <xsl:if test="count($targets) gt 0">
                        <xsl:value-of select="$targets[1]"/>    
                    </xsl:if>
                </xsl:when>
            </xsl:choose>
            
        </xsl:for-each>
    </xsl:variable>-->

  <!--<xsl:variable name="slurEnds" as="xs:string*">
        <xsl:for-each select="//mei:slur">
            <xsl:choose>
                <xsl:when test="@endid">
                    <xsl:variable name="endElem" select="$file/id(substring(@endid,2))" as="node()?"/>
                    <xsl:if test="exists($endElem) and local-name($endElem) = ('note','chord')">
                        <xsl:value-of select="substring(@endid,2)"/>
                    </xsl:if>
                </xsl:when>
                <xsl:when test="@tstamp2 and @staff">
                    <xsl:variable name="startMeasure" select="parent::mei:measure" as="node()"/>
                    <xsl:variable name="range" select="number(substring-before(@tstamp2,'m+'))" as="xs:double"/>
                    <xsl:variable name="measure" select="if($range gt 0) then($startMeasure/following::meiMeasure[$range]) else($startMeasure)" as="node()"/>
                    <xsl:variable name="tstamp" select="substring-after(@tstamp2,'m+')" as="xs:string"/>
                    <xsl:variable name="staffN" select="@staff" as="xs:string"/>
                    <xsl:variable name="layers" select="$measure/mei:staff[@n = $staffN]/mei:layer" as="node()*"/>
                    <xsl:variable name="targets" as="xs:string()*">
                        <xsl:for-each select="$layers">
                            
                            <xsl:variable name="def" select="preceding::mei:*[@meter.unit and @meter.count and (local-name() = 'scoreDef' or @n = $staffN)][1]"/>
                            
                            <xsl:variable name="tstamp" select="local:getTstampByDef(.,$def)"/>
                            
                            <xsl:variable name="elems" select="descendant::mei:mRest[@dur] | descendant::mei:space[@dur] | descendant::mei:note[@dur and not(ancestor::mei:tuplet)] | descendant::mei:tuplet | descendant::mei:rest | descendant::mei:chord[@dur and not(.//mei:note[@dur])]"/>
                            
                            <xsl:variable name="tstamps" as="xs:string*">
                                <xsl:for-each select="$elems">
                                    <xsl:variable name="elem" select="."/>
                                    <xsl:value-of select="local:getTstampByDef($elem,$def)"/>
                                </xsl:for-each>
                            </xsl:variable>
                            
                            <xsl:variable name="index" select="index-of($tstamps,$tstamp)"/>
                            
                            <xsl:variable name="rightElem" select="$elems[$index]" as="node()?"/>
                            
                            <xsl:if test="exists($rightElem) and local-name($rightElem) = ('note','chord')">
                                <xsl:value-of select="$rightElem/@xml:id"/>    
                            </xsl:if>
                            
                        </xsl:for-each>
                    </xsl:variable>
                    <xsl:if test="count($targets) gt 0">
                        <xsl:value-of select="$targets[1]"/>    
                    </xsl:if>
                </xsl:when>
            </xsl:choose>
            
        </xsl:for-each>
    </xsl:variable>-->
  <xsl:template match="/">
    <xsl:variable name="firstMeasureID" select="($file//mei:measure)[1]/@xml:id"/>
    <xsl:variable name="lastMeasureID" select="($file//mei:measure)[last()]/@xml:id"/>
    <xsl:variable name="startDef" select="($file//mei:scoreDef)[1]"/>
    <xsl:message select="concat('firstMeasureID: ',$firstMeasureID)"/>
    <xsl:message select="local-name($startDef)"/>
    <xsl:variable name="abc">
      <xsl:variable name="voices" as="xs:string*">
        <xsl:for-each select="$startDef//mei:staffDef">
          <xsl:variable name="staffN" select="@n" as="xs:string"/>
          <xsl:variable name="staffLayers" select="distinct-values(('1',$file//mei:staff[@n = $staffN]/mei:layer/@n))" as="xs:string*"/>
          <xsl:for-each select="$staffLayers">
            <xsl:value-of select="concat('staff',$staffN,'layer',.)"/>
          </xsl:for-each>
        </xsl:for-each>
      </xsl:variable>
      <xsl:call-template name="getABCHead">
        <xsl:with-param name="startDef" select="$startDef"/>
      </xsl:call-template>
      <xsl:for-each select="$voices">
        <xsl:variable name="staffN" select="substring-after(substring-before(.,'layer'),'staff')" as="xs:string"/>
        <xsl:variable name="layerN" select="substring-after(.,'layer')" as="xs:string"/>
        <xsl:value-of select="concat('[V:',.,'] ')"/>
        <xsl:apply-templates select="$file" mode="convertMEI">
          <xsl:with-param name="staffN" select="$staffN" tunnel="yes"/>
          <xsl:with-param name="layerN" select="$layerN" tunnel="yes"/>
        </xsl:apply-templates>
        <xsl:value-of select="codepoints-to-string(13)"/>

        <!-- Lyrics lines -->
        <!--<xsl:if test="exists($file/mei:layer[@n = $layer or count($layers) = 1]//mei:syl)">
                    <xsl:variable name="verses" select="distinct-values($file/mei:layer[@n = $layer or count($layers) = 1]//mei:verse/@n)"/>
                    <xsl:for-each select="$verses">
                        <xsl:value-of select="'w: '"/>
                        <xsl:apply-templates select="$file/node()" mode="lyrics">
                            <xsl:with-param name="layer" select="$layer" tunnel="yes"/>
                            <xsl:with-param name="verse" select="." tunnel="yes"/>
                        </xsl:apply-templates>
                        <xsl:value-of select="codepoints-to-string(13)"/>
                    </xsl:for-each>
                </xsl:if>-->
      </xsl:for-each>
    </xsl:variable>
    <xsl:value-of select="replace($abc,'^[ \n]+|\s+$','','m')"/>
  </xsl:template>

  <!-- mode setupABC -->
  <xsl:template name="getABCHead"><xsl:param name="startDef"/><xsl:param name="layers"/><xsl:variable name="meter.count" select="($startDef//@meter.count)[last()]"/><xsl:variable name="meter.unit" select="($startDef//@meter.unit)[last()]"/><xsl:variable name="meter.sym" select="if($startDef//@meter.sym) then(($startDef//@meter.sym)[last()]) else('')"/><xsl:variable name="key.sig" select="($startDef//@key.sig)[last()]"/><xsl:variable name="clef.line" select="($startDef//@clef.line)[last()]"
      /><xsl:variable name="clef.shape" select="($startDef//@clef.shape)[last()]"/><xsl:variable name="scoreGroups" as="xs:string*"><xsl:for-each select="$startDef//mei:staffDef"><xsl:variable name="staffN" select="@n" as="xs:string"/><xsl:variable name="staffLayers" select="distinct-values(('1',$file//mei:staff[@n = $staffN]/mei:layer/@n))" as="xs:string*"/><xsl:variable name="startBracket" select="if(count($staffLayers) gt 1) then('(') else('')" as="xs:string"/><xsl:variable name="endBracket"
          select="if(count($staffLayers) gt 1) then(')') else('')" as="xs:string"/><xsl:variable name="voiceRefs" as="xs:string*"><xsl:for-each select="$staffLayers"><xsl:value-of select="concat('staff',$staffN,'layer',.)"/></xsl:for-each></xsl:variable><xsl:value-of select="concat($startBracket,string-join($voiceRefs,' '),$endBracket)"/></xsl:for-each></xsl:variable><xsl:variable name="staves" as="xs:string*"><xsl:for-each select="$startDef//mei:staffDef"><xsl:variable name="staffN" select="@n"
          as="xs:string"/><xsl:variable name="label" select="if(@label) then(@label) else('')" as="xs:string"/><xsl:variable name="label.abbr" select="if(@label.abbr) then(@label.abbr) else('')" as="xs:string"/><xsl:variable name="staffLayers" select="distinct-values(('1',$file//mei:staff[@n = $staffN]/mei:layer/@n))" as="xs:string*"/><xsl:variable name="clef" select="local:translateClef(@clef.line, @clef.shape)"/><xsl:for-each select="$staffLayers"><xsl:value-of
            select="concat('V:staff',$staffN,'layer',.,$clef,' name=',codepoints-to-string(34),$label,codepoints-to-string(34),' snm=',codepoints-to-string(34),$label.abbr,codepoints-to-string(34))"/></xsl:for-each></xsl:for-each></xsl:variable> M:<xsl:value-of select="local:translateMeter($meter.count,$meter.unit,$meter.sym)"/> K:<xsl:value-of select="local:translateKey($key.sig)"/> %%barnumbers 1 %%measurefirst <xsl:value-of select="(//mei:measure)[1]/@n"/> L:1/8 %%score <xsl:value-of
      select="concat(string-join($scoreGroups,' '),codepoints-to-string(13))"/><xsl:value-of select="concat(string-join($staves,codepoints-to-string(13)),codepoints-to-string(13))"/></xsl:template>
  <xsl:template match="mei:staffDef" mode="convertMEI">
    <xsl:value-of select="local:resolveDef(.,false())"/>
  </xsl:template>
  <xsl:template match="mei:scoreDef" mode="convertMEI">
    <xsl:if test="preceding-sibling::mei:* or preceding::mei:section or parent::mei:section">
      <xsl:value-of select="local:resolveDef(.,false())"/>
    </xsl:if>
  </xsl:template>
  <xsl:template match="mei:measure" mode="convertMEI">
    <xsl:param name="staffN" tunnel="yes"/>
    <xsl:param name="layerN" tunnel="yes"/>
    <xsl:if test="@left">
      <xsl:apply-templates select="@left" mode="convertMEI"/>
    </xsl:if>
    <xsl:choose>
      <xsl:when test=".//mei:staff[@n = $staffN]/mei:layer[@n = $layerN or ($layerN = '1' and count(parent::mei:staff/mei:layer) = 1)]">
        <xsl:apply-templates select=".//mei:staff[@n = $staffN]/mei:layer[@n = $layerN or ($layerN = '1' and count(parent::mei:staff/mei:layer) = 1)]/*" mode="convertMEI"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="mSpace"/>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:choose>
      <xsl:when test="@right">
        <xsl:apply-templates select="@right" mode="convertMEI"/>
      </xsl:when>
      <xsl:otherwise> |</xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template match="@right" mode="convertMEI">
    <xsl:choose>
      <xsl:when test=". = 'dbl'">||</xsl:when>
      <xsl:when test=". = 'end'">|]</xsl:when>
      <xsl:when test=". = 'rptstart'">|:</xsl:when>
      <xsl:when test=". = 'rptboth'">::</xsl:when>
      <xsl:when test=". = 'rptend'">:|</xsl:when>
      <xsl:when test=". = 'single'">|</xsl:when>
    </xsl:choose>
  </xsl:template>
  <xsl:template match="@left" mode="convertMEI">
    <xsl:choose>
      <xsl:when test=". = 'dbl'"> || </xsl:when>
      <xsl:when test=". = 'end'"> |] </xsl:when>
      <xsl:when test=". = 'rptstart'"> |: </xsl:when>
      <xsl:when test=". = 'rptboth'"> :: </xsl:when>
      <xsl:when test=". = 'rptend'"> :| </xsl:when>
      <xsl:when test=". = 'single'"> | </xsl:when>
    </xsl:choose>
  </xsl:template>
  <xsl:template match="mei:beam" mode="convertMEI">
    <xsl:variable name="content">
      <xsl:apply-templates select="node()" mode="#current"/>
    </xsl:variable>
    <xsl:value-of select="concat(' ',replace($content,' ',''))"/>
  </xsl:template>
  <xsl:template match="mei:tuplet" mode="convertMEI">
    <xsl:variable name="num" select="@num"/>
    <xsl:variable name="notes" select="count(.//mei:note[not(parent::mei:chord) and not(@grace)] | .//mei:chord | .//mei:rest)"/>
    <xsl:variable name="content">
      <xsl:apply-templates select="node()" mode="#current"/>
    </xsl:variable>
    <xsl:value-of select="concat(' (',$num,'::',$notes,' ',$content)"/>
  </xsl:template>
  <xsl:template match="mei:mRest" mode="convertMEI">
    <xsl:variable name="id" select="@xml:id"/>
    <xsl:variable name="meter.count" select="preceding::*[@meter.count][1]/@meter.count"/>
    <xsl:variable name="meter.unit" select="preceding::*[@meter.unit][1]/@meter.unit"/>
    <xsl:variable name="num">
      <xsl:choose>
        <xsl:when test="$meter.unit = '4'">
          <xsl:value-of select="number($meter.count)*2"/>
        </xsl:when>
        <xsl:when test="$meter.unit = '8'">
          <xsl:value-of select="number($meter.count)"/>
        </xsl:when>
        <xsl:when test="$meter.unit = '2'">
          <xsl:value-of select="number($meter.count)*4"/>
        </xsl:when>
        <xsl:when test="$meter.unit = '16'">
          <xsl:value-of select="concat($meter.count,'/2')"/>
        </xsl:when>
        <xsl:when test="$meter.unit = '32'">
          <xsl:value-of select="concat($meter.count,'/4')"/>
        </xsl:when>
        <xsl:when test="$meter.unit = '1'">
          <xsl:value-of select="number($meter.count)*8"/>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="idref">
      <xsl:if test="$includeIDs = true()">
        <xsl:value-of select="concat('!xml:id=',codepoints-to-string(34),$id,codepoints-to-string(34),'!')"/>
      </xsl:if>
    </xsl:variable>
    <xsl:value-of select="concat(' ',$idref,'z',$num)"/>
  </xsl:template>
  <xsl:template name="mSpace" match="mei:mSpace" mode="convertMEI">
    <xsl:variable name="meter.count" select="preceding::*[@meter.count][1]/@meter.count"/>
    <xsl:variable name="meter.unit" select="preceding::*[@meter.unit][1]/@meter.unit"/>
    <xsl:variable name="num">
      <xsl:choose>
        <xsl:when test="$meter.unit = '4'">
          <xsl:value-of select="number($meter.count)*2"/>
        </xsl:when>
        <xsl:when test="$meter.unit = '8'">
          <xsl:value-of select="number($meter.count)"/>
        </xsl:when>
        <xsl:when test="$meter.unit = '2'">
          <xsl:value-of select="number($meter.count)*4"/>
        </xsl:when>
        <xsl:when test="$meter.unit = '16'">
          <xsl:value-of select="concat($meter.count,'/2')"/>
        </xsl:when>
        <xsl:when test="$meter.unit = '32'">
          <xsl:value-of select="concat($meter.count,'/4')"/>
        </xsl:when>
        <xsl:when test="$meter.unit = '1'">
          <xsl:value-of select="number($meter.count)*8"/>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:value-of select="concat(' x',$num)"/>
  </xsl:template>
  <xsl:template match="mei:bTrem" mode="convertMEI">
    <!--<xsl:value-of select="concat(codepoints-to-string(34),'bTrem',codepoints-to-string(34))"/>-->
    <xsl:apply-templates select="node()" mode="#current"/>
  </xsl:template>
  <xsl:template match="mei:mRpt" mode="convertMEI">
    <!-- this resolves mRpts…
            
            <xsl:variable name="staffN" select="ancestor::mei:staff/@n"/>
        <xsl:variable name="layerN" select="ancestor::mei:layer/@n"/>
        <xsl:variable name="targetLayer" select="ancestor::mei:measure/preceding::mei:measure[1]/mei:staff[@n = $staffN]/mei:layer[@n = $layerN or count(parent::mei:staff/mei:layer) = 1]"/>
        
        <xsl:value-of select="'"_mRpt"'"/>
        <xsl:apply-templates select="$targetLayer" mode="#current"/>-->
    <xsl:variable name="meter.count" select="preceding::*[@meter.count][1]/@meter.count"/>
    <xsl:variable name="meter.unit" select="preceding::*[@meter.unit][1]/@meter.unit"/>
    <xsl:variable name="num">
      <xsl:choose>
        <xsl:when test="$meter.unit = '4'">
          <xsl:value-of select="number($meter.count)*2"/>
        </xsl:when>
        <xsl:when test="$meter.unit = '8'">
          <xsl:value-of select="number($meter.count)"/>
        </xsl:when>
        <xsl:when test="$meter.unit = '2'">
          <xsl:value-of select="number($meter.count)*4"/>
        </xsl:when>
        <xsl:when test="$meter.unit = '16'">
          <xsl:value-of select="concat($meter.count,'/2')"/>
        </xsl:when>
        <xsl:when test="$meter.unit = '32'">
          <xsl:value-of select="concat($meter.count,'/4')"/>
        </xsl:when>
        <xsl:when test="$meter.unit = '1'">
          <xsl:value-of select="number($meter.count)*8"/>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:value-of select="concat(' &#34;//;m&#34;y',$num)"/>
  </xsl:template>
  <xsl:template match="mei:halfmRpt" mode="convertMEI">
    <xsl:variable name="meter.count" select="preceding::*[@meter.count][1]/@meter.count"/>
    <xsl:variable name="meter.unit" select="preceding::*[@meter.unit][1]/@meter.unit"/>
    <xsl:variable name="num">
      <xsl:choose>
        <xsl:when test="$meter.unit = '4'">
          <xsl:value-of select="number($meter.count)*2"/>
        </xsl:when>
        <xsl:when test="$meter.unit = '8'">
          <xsl:value-of select="number($meter.count)"/>
        </xsl:when>
        <xsl:when test="$meter.unit = '2'">
          <xsl:value-of select="number($meter.count)*4"/>
        </xsl:when>
        <xsl:when test="$meter.unit = '16'">
          <xsl:value-of select="concat($meter.count,'/2')"/>
        </xsl:when>
        <xsl:when test="$meter.unit = '32'">
          <xsl:value-of select="concat($meter.count,'/4')"/>
        </xsl:when>
        <xsl:when test="$meter.unit = '1'">
          <xsl:value-of select="number($meter.count)*8"/>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:value-of select="concat(' &#34;//;hm&#34;y',($num div 2))"/>
  </xsl:template>
  <xsl:template match="mei:beatRpt" mode="convertMEI">
    <xsl:variable name="meter.unit" select="preceding::*[@meter.unit][1]/@meter.unit"/>
    <xsl:variable name="num">
      <xsl:choose>
        <xsl:when test="$meter.unit = '4'">
          <xsl:value-of select="'2'"/>
        </xsl:when>
        <xsl:when test="$meter.unit = '8'">
          <xsl:value-of select="'1'"/>
        </xsl:when>
        <xsl:when test="$meter.unit = '2'">
          <xsl:value-of select="'4'"/>
        </xsl:when>
        <xsl:when test="$meter.unit = '16'">
          <xsl:value-of select="'1/2'"/>
        </xsl:when>
        <xsl:when test="$meter.unit = '32'">
          <xsl:value-of select="'1/4'"/>
        </xsl:when>
        <xsl:when test="$meter.unit = '1'">
          <xsl:value-of select="'8'"/>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:value-of select="concat(' &#34;//;b&#34;y',$num)"/>
  </xsl:template>
  <xsl:template match="mei:fTrem" mode="convertMEI">
    <!--<xsl:value-of select="concat(codepoints-to-string(34),'fTrem',codepoints-to-string(34))"/>-->
    <xsl:choose>
      <xsl:when test="count(distinct-values(child::*/@dur)) = 1 and @measperf">
        <xsl:variable name="totalDur" select="child::*[1]/@dur"/>
        <xsl:variable name="perfDur" select="@measperf"/>
        <xsl:variable name="iterations" select="(number($perfDur) div number($totalDur) div 2) cast as xs:integer" as="xs:integer"/>
        <xsl:variable name="elem" select="." as="node()"/>
        <xsl:variable name="string">
          <xsl:for-each select="(1 to $iterations - 1)">
            <xsl:apply-templates select="$elem/child::mei:*" mode="#current">
              <xsl:with-param name="dur" select="$perfDur" tunnel="yes" as="xs:string?"/>
            </xsl:apply-templates>
          </xsl:for-each>
          <xsl:apply-templates select="$elem/child::mei:*[1]" mode="#current">
            <xsl:with-param name="dur" select="$perfDur" tunnel="yes" as="xs:string?"/>
          </xsl:apply-templates>
          <xsl:value-of select="'&#34;&gt;&gt;&#34;'"/>
          <xsl:apply-templates select="$elem/child::mei:*[2]" mode="#current">
            <xsl:with-param name="dur" select="$perfDur" tunnel="yes" as="xs:string?"/>
          </xsl:apply-templates>
        </xsl:variable>
        <xsl:value-of select="concat(' &#34;&lt;&lt;&#34;&#34;_fT&#34;',replace($string,'\s+',''),' ')"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="node()" mode="#current"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template match="mei:chord" mode="convertMEI">
    <xsl:param name="dur" tunnel="yes" as="xs:string?"/>
    <xsl:variable name="id" select="@xml:id"/>
    <xsl:variable name="tstamp" select="local:getTstamp(.) cast as xs:string"/>
    <xsl:variable name="slurStart">
      <xsl:for-each select="//mei:slur[substring(@startid,2) = $id]">(</xsl:for-each>
    </xsl:variable>
    <xsl:variable name="idref">
      <xsl:if test="$includeIDs">
        <xsl:value-of select="concat('!xml:id=',codepoints-to-string(34),@xml:id,codepoints-to-string(34),'!')"/>
      </xsl:if>
    </xsl:variable>
    <xsl:variable name="stemDir">
      <xsl:if test="@stem.dir">
        <xsl:value-of select="concat('&#34;',if(@stem.dir='up') then('⇡') else('⇣'),'&#34;')"/>
      </xsl:if>
    </xsl:variable>
    <xsl:variable name="fermata">
      <xsl:if test="@fermata">
        <xsl:value-of select="concat('!',if(@fermata = 'above') then('fermata') else('invertedfermata'),'!')"/>
      </xsl:if>
    </xsl:variable>
    <xsl:variable name="stemMod">
      <xsl:if test="@stem.mod and matches(@stem.mod,'^\d')">
        <xsl:variable name="num" select="number(substring(@stem.mod,1,1)) cast as xs:integer"/>
        <xsl:variable name="slashes">
          <xsl:for-each select="(1 to $num)">
            <xsl:value-of select="'/'"/>
          </xsl:for-each>
        </xsl:variable>
        <xsl:value-of select="concat('!',$slashes,'!')"/>
      </xsl:if>
    </xsl:variable>
    <xsl:variable name="artic">
      <xsl:choose>
        <xsl:when test="@artic = 'stacc'">.</xsl:when>
        <xsl:when test="@artic = 'dot'">.</xsl:when>
        <xsl:when test="@artic = 'acc'">!accent!</xsl:when>
        <xsl:when test="@artic = 'stroke'">!breath!</xsl:when>
        <xsl:when test="@artic = 'marc'">!breath!</xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="dynam">
      <xsl:variable name="dyn" select="ancestor::mei:measure/mei:dynam[@tstamp = $tstamp]"/>
      <xsl:for-each select="$dyn">
        <xsl:value-of select="concat('!',(replace(./text(),'[o:\.rnitez]+',''))[1],'!')"/>
        <!-- BWB replace($dyn... -->
      </xsl:for-each>
    </xsl:variable>
    <xsl:variable name="dur">
      <xsl:if test="@dur">
        <xsl:value-of select="local:resolveDur(if($dur) then($dur) else(@dur),if(@dots) then(@dots) else(''))"/>
      </xsl:if>
    </xsl:variable>
    <xsl:variable name="content">
      <xsl:apply-templates select="node()" mode="#current"/>
    </xsl:variable>
    <xsl:variable name="slurEnd">
      <xsl:for-each select="//mei:slur[substring(@endid,2) = $id]">)</xsl:for-each>
    </xsl:variable>
    <xsl:variable name="tie">
      <xsl:if test="starts-with(@tie,'i') or starts-with(@tie,'m')">-</xsl:if>
    </xsl:variable>
    <xsl:value-of select="concat(' ',$idref,$slurStart,$stemDir,$artic,$stemMod,$fermata,$dynam,'[',replace($content,' ',''),']',$dur,$slurEnd,$tie)"/>
  </xsl:template>
  <xsl:template match="mei:note" mode="convertMEI">
    <xsl:param name="dur" tunnel="yes" as="xs:string?"/>
    <xsl:variable name="id" select="@xml:id"/>
    <xsl:variable name="tstamp" select="local:getTstamp(.) cast as xs:string"/>
    <xsl:variable name="measure" select="ancestor::mei:measure"/>
    <xsl:variable name="staffN" select="ancestor::mei:staff/@n"/>
    <xsl:variable name="layerN" select="ancestor::mei:layer/@n"/>
    <xsl:variable name="slurStart">
      <xsl:for-each select="//mei:slur[substring(@startid,2) = $id]">(</xsl:for-each>
    </xsl:variable>
    <xsl:variable name="idref">
      <xsl:if test="$includeIDs and not(parent::mei:chord)">
        <xsl:value-of select="concat('!xml:id=',codepoints-to-string(34),@xml:id,codepoints-to-string(34),'!')"/>
      </xsl:if>
    </xsl:variable>
    <xsl:variable name="graceStart">
      <xsl:if test="@grace and not(preceding-sibling::mei:note[1]/@grace)">
        <xsl:value-of select="concat('{',if(@stem.mod) then('/') else(''))"/>
      </xsl:if>
    </xsl:variable>
    <xsl:variable name="hairpin">
      <!--<xsl:if test="$layerN = '1'">
                <xsl:variable name="beginHairpin" select="$measure/mei:hairpin[@staff = $staffN and @tstamp = $tstamp]"/>
                <xsl:variable name="localEndHairpin" select="$measure/mei:hairpin[@staff = $staffN and @tstamp2 = $tstamp]"/>
                <xsl:variable name="distantEndHairpin" select="$measure/preceding-sibling::mei:measure/mei:hairpin[@staff = $staffN and local:resolveTstamp2(./parent::mei:measure,$measure,$tstamp, @tstamp2)]"/>
                <!-\-<xsl:variable name="endHairpin" select="$localEndHairpin | $distantEndHairpin"/>-\->
                <!-\-            <xsl:variable name="endHairpin" select="//mei:hairpin[@endid/substring(.,2) = $id]"/>-\->
                <xsl:for-each select="$localEndHairpin">
                    <xsl:variable name="dir" select="if(@form = 'dim') then('diminuendo') else ('crescendo')"/>
                    <xsl:value-of select="concat('!',$dir,')!')"/>
                </xsl:for-each>
                <xsl:for-each select="$beginHairpin">
                    <xsl:variable name="dir" select="if(@form = 'dim') then('diminuendo') else ('crescendo')"/>
                    <xsl:value-of select="concat('!',$dir,'(!')"/>
                </xsl:for-each>
            </xsl:if>--></xsl:variable>
    <xsl:variable name="stemDir">
      <xsl:if test="@stem.dir">
        <xsl:value-of select="concat('&#34;',if(@stem.dir='up') then('⇡') else('⇣'),'&#34;')"/>
      </xsl:if>
    </xsl:variable>
    <xsl:variable name="dynam">
      <xsl:if test="not(ancestor::mei:chord)">
        <xsl:variable name="dyn" select="ancestor::mei:measure/mei:dynam[@tstamp = $tstamp]"/>
        <xsl:for-each select="$dyn">
          <xsl:value-of select="concat('!',replace(replace(string-join($dyn//text(), ''), '\s*(.+)\s*', '$1'),'[o:\.rnitez]+',''),'!')"/>
        </xsl:for-each>
      </xsl:if>
    </xsl:variable>
    <xsl:variable name="artic">
      <xsl:choose>
        <xsl:when test="@artic = 'stacc'">.</xsl:when>
        <xsl:when test="@artic = 'dot'">.</xsl:when>
        <xsl:when test="@artic = 'acc'">!accent!</xsl:when>
        <xsl:when test="@artic = 'stroke'">!breath!</xsl:when>
        <xsl:when test="@artic = 'marc'">!breath!</xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="trill">
      <xsl:if test="$measure/mei:trill[substring(@startid,2) = $id or @tstamp = $tstamp]">T</xsl:if>
    </xsl:variable>
    <xsl:variable name="fermata">
      <xsl:if test="@fermata and not(parent::mei:chord/@fermata)">
        <xsl:value-of select="concat('!',if(@fermata = 'above') then('fermata') else('invertedfermata'),'!')"/>
      </xsl:if>
    </xsl:variable>
    <xsl:variable name="stemMod">
      <xsl:if test="not(@grace) and @stem.mod and not(parent::mei:chord/@stem.mod) and matches(@stem.mod,'^\d')">
        <xsl:variable name="num" select="number(substring(@stem.mod,1,1)) cast as xs:integer"/>
        <xsl:variable name="slashes">
          <xsl:for-each select="(1 to $num)">
            <xsl:value-of select="'/'"/>
          </xsl:for-each>
        </xsl:variable>
        <xsl:value-of select="concat('!',$slashes,'!')"/>
      </xsl:if>
    </xsl:variable>
    <xsl:variable name="accid">
      <xsl:choose>
        <xsl:when test="@accid = 'f'">_</xsl:when>
        <xsl:when test="@accid = 's'">^</xsl:when>
        <xsl:when test="@accid = 'n'">=</xsl:when>
        <xsl:when test="@accid = 'ff'">__</xsl:when>
        <xsl:when test="@accid = 'ss'">^^</xsl:when>
        <xsl:when test="@accid = 'x'">^^</xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="pitch">
      <xsl:choose>
        <xsl:when test="@oct = '8'">
          <xsl:value-of select="concat(lower-case(@pname),codepoints-to-string(39),codepoints-to-string(39),codepoints-to-string(39))"/>
        </xsl:when>
        <xsl:when test="@oct = '7'">
          <xsl:value-of select="concat(lower-case(@pname),codepoints-to-string(39),codepoints-to-string(39))"/>
        </xsl:when>
        <xsl:when test="@oct = '6'">
          <xsl:value-of select="concat(lower-case(@pname),codepoints-to-string(39))"/>
        </xsl:when>
        <xsl:when test="@oct = '5'">
          <xsl:value-of select="lower-case(@pname)"/>
        </xsl:when>
        <xsl:when test="@oct = '4'">
          <xsl:value-of select="upper-case(@pname)"/>
        </xsl:when>
        <xsl:when test="@oct = '3'">
          <xsl:value-of select="concat(upper-case(@pname),',')"/>
        </xsl:when>
        <xsl:when test="@oct = '2'">
          <xsl:value-of select="concat(upper-case(@pname),',,')"/>
        </xsl:when>
        <xsl:when test="@oct = '1'">
          <xsl:value-of select="concat(upper-case(@pname),',,,')"/>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="dur">
      <xsl:if test="not(parent::mei:chord/@dur)">
        <xsl:value-of select="local:resolveDur(if($dur) then($dur) else(@dur),if(@dots) then(@dots) else(''))"/>
      </xsl:if>
    </xsl:variable>
    <xsl:variable name="tie">
      <xsl:if test="starts-with(@tie,'i') or starts-with(@tie,'m')">-</xsl:if>
    </xsl:variable>
    <xsl:variable name="slurEnd">
      <xsl:for-each select="//mei:slur[substring(@endid,2) = $id]">)</xsl:for-each>
    </xsl:variable>
    <xsl:variable name="graceEnd">
      <xsl:if test="@grace and not(following-sibling::mei:note[1]/@grace)">}</xsl:if>
    </xsl:variable>
    <xsl:variable name="tstamp">
      <!--<xsl:if test="$showTstamps">
                <xsl:value-of select="concat(codepoints-to-string(34),$tstamp,codepoints-to-string(34))"/>
            </xsl:if>--></xsl:variable>
    <xsl:value-of select="concat(' ',$idref,$tstamp,$hairpin,$stemDir,$graceStart,$slurStart,$stemMod,$dynam,$trill,$fermata,$artic,$accid,$pitch,$dur,$tie,$slurEnd,$graceEnd)"/>
  </xsl:template>
  <xsl:template match="mei:rest" mode="convertMEI">
    <xsl:variable name="tstamp" select="local:getTstamp(.) cast as xs:string"/>
    <xsl:variable name="staffN" select="ancestor::mei:staff/@n"/>
    <xsl:variable name="layerN" select="ancestor::mei:layer/@n"/>
    <xsl:variable name="measure" select="ancestor::mei:measure"/>
    <xsl:variable name="idref">
      <xsl:if test="$includeIDs">
        <xsl:value-of select="concat('!xml:id=',codepoints-to-string(34),@xml:id,codepoints-to-string(34),'!')"/>
      </xsl:if>
    </xsl:variable>
    <xsl:variable name="fermata">
      <xsl:if test="@fermata">
        <xsl:value-of select="concat('!',if(@fermata = 'above') then('fermata') else('invertedfermata'),'!')"/>
      </xsl:if>
    </xsl:variable>
    <xsl:variable name="hairpin">
      <!--<xsl:if test="$layerN = '1'">
                <xsl:variable name="beginHairpin" select="$measure/mei:hairpin[@staff = $staffN and @tstamp = $tstamp]"/>
                <xsl:variable name="localEndHairpin" select="$measure/mei:hairpin[@staff = $staffN and @tstamp2 = $tstamp]"/>
                <xsl:variable name="distantEndHairpin" select="$measure/preceding-sibling::mei:measure/mei:hairpin[@staff = $staffN and local:resolveTstamp2(./parent::mei:measure,$measure,$tstamp, @tstamp2)]"/>
                <!-\-<xsl:variable name="endHairpin" select="$localEndHairpin | $distantEndHairpin"/>-\->
                <!-\-            <xsl:variable name="endHairpin" select="//mei:hairpin[@endid/substring(.,2) = $id]"/>-\->
                <xsl:for-each select="$localEndHairpin | $distantEndHairpin">
                    <xsl:variable name="dir" select="if(@form = 'dim') then('diminuendo') else ('crescendo')"/>
                    <xsl:value-of select="concat('!',$dir,')!')"/>
                </xsl:for-each>
                <xsl:for-each select="$beginHairpin">
                    <xsl:variable name="dir" select="if(@form = 'dim') then('diminuendo') else ('crescendo')"/>
                    <xsl:value-of select="concat('!',$dir,'(!')"/>
                </xsl:for-each>
            </xsl:if>--></xsl:variable>
    <xsl:variable name="dur" select="local:resolveDur(@dur,if(@dots) then(@dots) else(''))"/>
    <xsl:value-of select="concat(' ',$idref,$fermata,$hairpin,'z',$dur)"/>
  </xsl:template>
  <xsl:template match="mei:clef[@line and @shape]" mode="convertMEI">
    <xsl:value-of select="concat('[K:',local:translateClef(@line,@shape),']')"/>
  </xsl:template>
  <xsl:template match="mei:space" mode="convertMEI">
    <xsl:variable name="dur" select="local:resolveDur(@dur,if(@dots) then(@dots) else(''))"/>
    <xsl:value-of select="concat(' x',$dur)"/>
  </xsl:template>

  <!-- mode: lyrics -->
  <xsl:template match="mei:measure" mode="lyrics">
    <xsl:param name="staffN" tunnel="yes"/>
    <xsl:param name="layerN" tunnel="yes"/>
    <xsl:apply-templates select="//mei:staff[@n = $staffN]/mei:layer[@n = $layerN]" mode="lyrics"/>
  </xsl:template>
  <xsl:template match="mei:note[not(parent::mei:chord) and not(@grace)] | mei:chord" mode="lyrics">
    <xsl:param name="verse" tunnel="yes"/>
    <xsl:choose>
      <xsl:when test=".//mei:verse[@n = $verse]/mei:syl">
        <xsl:variable name="syl" select="(.//mei:verse[@n = $verse]/mei:syl)"/>
        <xsl:if test="count($syl) gt 1">
          <xsl:message select="concat('Note ',@xml:id,' has more than one syllable in one verse. Only the first is processed.')"/>
        </xsl:if>
        <xsl:variable name="pre">
          <xsl:choose>
            <xsl:when test="$syl[1]/@wordpos = 'i'">
              <xsl:value-of select="''"/>
            </xsl:when>
            <xsl:when test="$syl[1]/@wordpos = 'm'">
              <xsl:value-of select="''"/>
            </xsl:when>
            <xsl:when test="$syl[1]/@wordpos = 't'">
              <xsl:value-of select="''"/>
            </xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="post">
          <xsl:choose>
            <xsl:when test="$syl[1]/@wordpos = 'i'">
              <xsl:value-of select="'-'"/>
            </xsl:when>
            <xsl:when test="$syl[1]/@wordpos = 'm'">
              <xsl:value-of select="'-'"/>
            </xsl:when>
            <xsl:when test="$syl[1]/@wordpos = 't'">
              <xsl:value-of select="' '"/>
            </xsl:when>
            <xsl:when test="not($syl[1]/@wordpos)">
              <xsl:value-of select="' '"/>
            </xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:value-of select="concat($pre,$syl[1]//text(),$post)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="'* '"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template match="*" mode="lyrics">
    <xsl:apply-templates select="node()" mode="#current"/>
  </xsl:template>

  <!-- functions -->
  <xsl:function name="local:resolveDur">
    <xsl:param name="dur" as="xs:string"/>
    <xsl:param name="dots" as="xs:string"/>
    <xsl:choose>
      <xsl:when test="$dots = ''">
        <xsl:choose>
          <xsl:when test="$dur = '1'">
            <xsl:value-of select="8"/>
          </xsl:when>
          <xsl:when test="$dur = '2'">
            <xsl:value-of select="4"/>
          </xsl:when>
          <xsl:when test="$dur = '4'">
            <xsl:value-of select="2"/>
          </xsl:when>
          <xsl:when test="$dur = '8'">
            <xsl:value-of select="1"/>
          </xsl:when>
          <xsl:when test="$dur = '16'">
            <xsl:value-of select="'/2'"/>
          </xsl:when>
          <xsl:when test="$dur = '32'">
            <xsl:value-of select="'/4'"/>
          </xsl:when>
          <xsl:when test="$dur = '64'">
            <xsl:value-of select="'/8'"/>
          </xsl:when>
          <xsl:when test="$dur = '128'">
            <xsl:value-of select="'/16'"/>
          </xsl:when>
          <xsl:when test="$dur = 'breve'">
            <xsl:value-of select="16"/>
          </xsl:when>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="$dots = '1'">
        <xsl:choose>
          <xsl:when test="$dur = '1'">
            <xsl:value-of select="12"/>
          </xsl:when>
          <xsl:when test="$dur = '2'">
            <xsl:value-of select="6"/>
          </xsl:when>
          <xsl:when test="$dur = '4'">
            <xsl:value-of select="3"/>
          </xsl:when>
          <xsl:when test="$dur = '8'">
            <xsl:value-of select="'3/2'"/>
          </xsl:when>
          <xsl:when test="$dur = '16'">
            <xsl:value-of select="'3/4'"/>
          </xsl:when>
          <xsl:when test="$dur = '32'">
            <xsl:value-of select="'3/8'"/>
          </xsl:when>
          <xsl:when test="$dur = '64'">
            <xsl:value-of select="'3/16'"/>
          </xsl:when>
          <xsl:when test="$dur = '128'">
            <xsl:value-of select="'3/32'"/>
          </xsl:when>
          <xsl:when test="$dur = 'breve'">
            <xsl:value-of select="24"/>
          </xsl:when>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="$dots = '2'">
        <xsl:choose>
          <xsl:when test="$dur = '1'">
            <xsl:value-of select="14"/>
          </xsl:when>
          <xsl:when test="$dur = '2'">
            <xsl:value-of select="7"/>
          </xsl:when>
          <xsl:when test="$dur = '4'">
            <xsl:value-of select="'7/2'"/>
          </xsl:when>
          <xsl:when test="$dur = '8'">
            <xsl:value-of select="'7/4'"/>
          </xsl:when>
          <xsl:when test="$dur = '16'">
            <xsl:value-of select="'7/8'"/>
          </xsl:when>
          <xsl:when test="$dur = '32'">
            <xsl:value-of select="'7/16'"/>
          </xsl:when>
          <xsl:when test="$dur = '64'">
            <xsl:value-of select="'7/32'"/>
          </xsl:when>
          <xsl:when test="$dur = '128'">
            <xsl:value-of select="'7/64'"/>
          </xsl:when>
          <xsl:when test="$dur = 'breve'">
            <xsl:value-of select="28"/>
          </xsl:when>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="$dots = '3'">
        <xsl:choose>
          <xsl:when test="$dur = '1'">
            <xsl:value-of select="15"/>
          </xsl:when>
          <xsl:when test="$dur = '2'">
            <xsl:value-of select="'15/2'"/>
          </xsl:when>
          <xsl:when test="$dur = '4'">
            <xsl:value-of select="'15/4'"/>
          </xsl:when>
          <xsl:when test="$dur = '8'">
            <xsl:value-of select="'15/8'"/>
          </xsl:when>
          <xsl:when test="$dur = '16'">
            <xsl:value-of select="'15/16'"/>
          </xsl:when>
          <xsl:when test="$dur = '32'">
            <xsl:value-of select="'15/32'"/>
          </xsl:when>
          <xsl:when test="$dur = '64'">
            <xsl:value-of select="'15/64'"/>
          </xsl:when>
          <xsl:when test="$dur = '128'">
            <xsl:value-of select="'15/128'"/>
          </xsl:when>
          <xsl:when test="$dur = 'breve'">
            <xsl:value-of select="30"/>
          </xsl:when>
        </xsl:choose>
      </xsl:when>
    </xsl:choose>
  </xsl:function>
  <xsl:function name="local:translateKey">
    <xsl:param name="key" as="xs:string"/>
    <xsl:choose>
      <xsl:when test="$key = '7s'">C#</xsl:when>
      <xsl:when test="$key = '6s'">F#</xsl:when>
      <xsl:when test="$key = '5s'">B</xsl:when>
      <xsl:when test="$key = '4s'">E</xsl:when>
      <xsl:when test="$key = '3s'">A</xsl:when>
      <xsl:when test="$key = '2s'">D</xsl:when>
      <xsl:when test="$key = '1s'">G</xsl:when>
      <xsl:when test="$key = '0'">C</xsl:when>
      <xsl:when test="$key = '1f'">F</xsl:when>
      <xsl:when test="$key = '2f'">Bb</xsl:when>
      <xsl:when test="$key = '3f'">Eb</xsl:when>
      <xsl:when test="$key = '4f'">Ab</xsl:when>
      <xsl:when test="$key = '5f'">Db</xsl:when>
      <xsl:when test="$key = '6f'">Gb</xsl:when>
      <xsl:when test="$key = '7f'">Cb</xsl:when>
    </xsl:choose>
  </xsl:function>
  <xsl:function name="local:translateMeter">
    <xsl:param name="meter.count" as="xs:string?"/>
    <xsl:param name="meter.unit" as="xs:string?"/>
    <xsl:param name="meter.sym" as="xs:string?"/>
    <xsl:choose>
      <xsl:when test="$meter.sym = 'common'">C</xsl:when>
      <xsl:when test="$meter.sym = 'cut'">C|</xsl:when>
      <xsl:when test="contains($meter.count,'+')">
        <xsl:value-of select="concat('(',$meter.count,')/',$meter.unit)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="concat($meter.count,'/',$meter.unit)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  <xsl:function name="local:translateClef">
    <xsl:param name="clef.line" as="xs:string"/>
    <xsl:param name="clef.shape" as="xs:string"/>
    <xsl:variable name="clefDef" select="concat(upper-case($clef.shape),$clef.line)"/>
    <xsl:variable name="clefString">
      <xsl:choose>
        <xsl:when test="$clefDef = 'G2'">treble</xsl:when>
        <xsl:when test="$clefDef = 'F4'">bass</xsl:when>
        <xsl:when test="$clefDef = 'F3'">baritone</xsl:when>
        <xsl:when test="$clefDef = 'C4'">tenor</xsl:when>
        <xsl:when test="$clefDef = 'C3'">alto</xsl:when>
        <xsl:when test="$clefDef = 'C2'">mezzosoprano</xsl:when>
        <xsl:when test="$clefDef = 'C1'">soprano</xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$clefDef"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:value-of select="concat(' clef=',$clefString)"/>
  </xsl:function>
  <xsl:function name="local:getTstamp">
    <xsl:param name="elem"/>
    <xsl:variable name="eventid" select="$elem/@xml:id"/>
    <xsl:variable name="layer" select="$elem/ancestor::mei:layer"/>
    <xsl:variable name="meter.unit" select="$elem/preceding::*[@meter.unit][1]/@meter.unit"/>

    <!--  Given a context layer and an @xml:id of a note or rest, 
                    return the timestamp of the note or rest.-->
    <xsl:variable name="base" select="number($meter.unit)"/>
    <xsl:variable name="events">
      <xsl:for-each select="$layer/descendant::mei:note[@dur] | $layer/descendant::mei:rest | $layer/descendant::mei:chord[@dur and not(.//mei:note[@dur])]">
        <!-- Other events that should be considered? -->
        <local:event>
          <xsl:if test="$eventid = @xml:id">
            <xsl:attribute name="this">this</xsl:attribute>
          </xsl:if>
          <xsl:value-of select="1 div @dur"/>
        </local:event>
        <xsl:if test="@dots">
          <xsl:variable name="total" select="@dots"/>
          <xsl:variable name="dur" select="@dur"/>
          <xsl:call-template name="add_dots">
            <xsl:with-param name="dur" select="$dur"/>
            <xsl:with-param name="total" select="$total"/>
          </xsl:call-template>
        </xsl:if>
        <xsl:if test="descendant::mei:dot">
          <xsl:variable name="total" select="count(descendant::mei:dot)"/>
          <xsl:variable name="dur" select="@dur"/>
          <xsl:call-template name="add_dots">
            <xsl:with-param name="dur" select="$dur"/>
            <xsl:with-param name="total" select="$total"/>
          </xsl:call-template>
        </xsl:if>
      </xsl:for-each>
    </xsl:variable>
    <!--DEBUG<xsl:copy-of select="$events"/>-->

    <!--<xsl:value-of select="count($events//local:event[@this])"/>-->
    <xsl:value-of select="(sum($events//local:event[@this]/preceding::local:event) div (1 div $base))+1"/>
  </xsl:function>
  <xsl:template name="add_dots">
    <xsl:param name="dur"/>
    <xsl:param name="total"/>

    <!--Given an event's duration and a number of dots, 
                    return the value of the dots-->
    <local:event dot="extradot">
      <xsl:value-of select="1 div ($dur * 2)"/>
    </local:event>
    <xsl:if test="$total != 1">
      <xsl:call-template name="add_dots">
        <xsl:with-param name="dur" select="$dur * 2"/>
        <xsl:with-param name="total" select="$total - 1"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>
  <xsl:function name="local:resolveTstamp2">
    <xsl:param name="beginMeasure" as="node()"/>
    <xsl:param name="endMeasure" as="node()"/>
    <xsl:param name="targetTstamp" as="xs:string"/>
    <xsl:param name="tstamp2" as="xs:string"/>
    <xsl:variable name="dist" select="number(substring-before($tstamp2,'m+')) cast as xs:integer"/>
    <xsl:variable name="target" select="substring-after($tstamp2,'m+')"/>
    <xsl:variable name="distFit" select="$beginMeasure/following-sibling::mei:measure[$dist]/@xml:id = $endMeasure/@xml:id"/>
    <xsl:value-of select="$distFit and $target = $targetTstamp"/>
  </xsl:function>
  <xd:doc scope="component">
    <xd:desc>
      <xd:p>local function for resolving scoreDef and staffDef elements</xd:p>
    </xd:desc>
    <xd:param>elem</xd:param>
    <xd:param>head</xd:param>
  </xd:doc>
  <xsl:function name="local:resolveDef">
    <xsl:param name="elem" as="node()"/>
    <xsl:param name="head" as="xs:boolean"/>
    <xsl:variable name="start">
      <xsl:if test="not($head)">[</xsl:if>
    </xsl:variable>
    <xsl:variable name="key">
      <xsl:choose>
        <xsl:when test="$elem//mei:staffDef[@key.sig]">
          <xsl:value-of select="local:translateKey($elem//mei:staffDef/@key.sig)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:if test="$elem/@key.sig">
            <xsl:value-of select="local:translateKey($elem/@key.sig)"/>
          </xsl:if>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="clef">
      <xsl:choose>
        <xsl:when test="$elem//mei:staffDef[@clef.line and @clef.shape]">
          <xsl:variable name="child" select="$elem//mei:staffDef[@clef.line and @clef.shape]"/>
          <xsl:value-of select="local:translateClef($child/@clef.line, $child/@clef.shape)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:if test="$elem/@clef.line and $elem/@clef.shape">
            <xsl:value-of select="local:translateClef($elem/@clef.line, $elem/@clef.shape)"/>
            <!--<xsl:value-of select="concat(' clef=',upper-case($elem/@clef.shape),$elem/@clef.line)"/>-->
          </xsl:if>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="meter">
      <xsl:if test="(($elem/@meter.count and $elem/@meter.unit) or ($elem/@meter.sym)) and not($elem/@meter.showchange = 'false')">
        <xsl:value-of select="local:translateMeter($elem/@meter.count,$elem/@meter.unit,$elem/@meter.sym)"/>
      </xsl:if>
    </xsl:variable>
    <xsl:variable name="end">
      <xsl:choose>
        <xsl:when test="$head">
          <xsl:value-of select="codepoints-to-string(13)"/>
        </xsl:when>
        <xsl:otherwise>]</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:if test="$key != '' or $clef != ''">
      <xsl:value-of select="concat($start,'K:',$key,$clef,$end)"/>
    </xsl:if>
    <xsl:if test="$meter != ''">
      <xsl:value-of select="concat($start,'M:',$meter,$end)"/>
    </xsl:if>
  </xsl:function>
  <xsl:function name="local:getTstampByDef">
    <xsl:param name="elem"/>
    <xsl:param name="def"/>
    <xsl:variable name="eventid" select="$elem/@xml:id"/>
    <xsl:variable name="layer" select="$elem/ancestor::mei:layer"/>
    <xsl:variable name="meter.unit" select="$def/@meter.unit"/>
    <xsl:variable name="meter.count" select="$def/@meter.count"/>

    <!--  Given a context layer and an @xml:id of a note or rest, 
                    return the timestamp of the note or rest.-->
    <xsl:variable name="base" select="number($meter.unit)"/>
    <xsl:variable name="events">
      <xsl:for-each select="$layer/descendant::mei:space[@dur] | $layer/descendant::mei:note[@dur] | $layer/descendant::mei:rest | $layer/descendant::mei:chord[@dur and not(.//mei:note[@dur])]">
        <!-- Other events that should be considered? -->
        <local:event>
          <xsl:if test="$eventid = @xml:id">
            <xsl:attribute name="this">this</xsl:attribute>
          </xsl:if>
          <xsl:value-of select="1 div @dur"/>
        </local:event>
        <xsl:if test="@dots">
          <xsl:variable name="total" select="@dots"/>
          <xsl:variable name="dur" select="@dur"/>
          <xsl:call-template name="add_dots">
            <xsl:with-param name="dur" select="$dur"/>
            <xsl:with-param name="total" select="$total"/>
          </xsl:call-template>
        </xsl:if>
        <xsl:if test="descendant::dot">
          <xsl:variable name="total" select="count(descendant::dot)"/>
          <xsl:variable name="dur" select="@dur"/>
          <xsl:call-template name="add_dots">
            <xsl:with-param name="dur" select="$dur"/>
            <xsl:with-param name="total" select="$total"/>
          </xsl:call-template>
        </xsl:if>
      </xsl:for-each>
    </xsl:variable>
    <!--DEBUG<xsl:copy-of select="$events"/>-->

    <!--<xsl:value-of select="count($events//local:event[@this])"/>-->
    <xsl:value-of select="(sum($events//local:event[@this]/preceding::local:event) div (1 div $base))+1"/>
  </xsl:function>
  <xsl:template match="node() | @*" mode="test">
    <xsl:message select="concat('processing ',local-name(.))"/>
    <xsl:copy>
      <xsl:apply-templates select="node() | @*" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  <xsl:template match="node() | @*" mode="convertMEI">
    <xsl:apply-templates select="node() | @*" mode="#current"/>
  </xsl:template>
</xsl:stylesheet>

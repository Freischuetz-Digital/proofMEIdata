<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:math="http://www.w3.org/2005/xpath-functions/math" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:mei="http://www.music-encoding.org/ns/mei" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" exclude-result-prefixes="xs math xd" version="3.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p>
                <xd:b>Created on:</xd:b> Nov 6, 2014</xd:p>
            <xd:p>
                <xd:ul>
                    <xd:li>
                        <xd:b>Author:</xd:b> Maja Hartwig</xd:li>
                    <xd:li>
                        <xd:b>Author:</xd:b> Johannes Kepper</xd:li>
                </xd:ul>
            </xd:p>
            <xd:p>
                This stylesheet performs various adjustments to an MEI file in order to render it with Verovio. 
                Most of this is temporary until Verovio handles these situations natively.  
            </xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:output method="xml" indent="yes"/>
    
    <!-- start processing -->
    <xsl:template match="/">
        <xsl:apply-templates/>
    </xsl:template>
    
    <!-- if a layer contains chords, this template splits them up and creates multiple layers -->
    <xsl:template match="mei:layer">
        
        <!-- get the maximum number of notes in a chord -->
        <xsl:variable name="maxNotes" select="if(.//mei:chord) then(max(.//mei:chord/count(.//mei:note))) else(0)" as="xs:integer"/>
        
        <!-- put the original layer in a variable to make it more accessible in later processing -->
        <xsl:variable name="layer" select="./mei:*" as="node()*"/>
        <xsl:choose>
            
            <!-- when the chord contains no layers, just copy the layer-->
            <xsl:when test="$maxNotes = 0">
                <xsl:copy>
                    <xsl:apply-templates select="node() | @*"/>
                </xsl:copy>
            </xsl:when>
            
            <!-- the layer contains chords -->
            <xsl:otherwise>
                <!-- process the layer in mode getFirstNote -->
                <xsl:copy>
                    <xsl:apply-templates select="node() | @*" mode="getFirstNote"/>
                </xsl:copy>
                <!-- for all notes beyond the first, create additional layers -->
                <xsl:for-each select="(2 to $maxNotes)">
                    <xsl:variable name="i" select="."/>
                    <layer xmlns="http://www.music-encoding.org/ns/mei">
                        
                        <!-- for each iteration, pass in its "number" as parameter  -->
                        <xsl:apply-templates select="$layer" mode="stripToLayer">
                            <xsl:with-param name="noteNum" select="$i" tunnel="yes" as="xs:integer"/>
                        </xsl:apply-templates>
                    </layer>
                </xsl:for-each>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- in getFirstNote mode, replace chords with a note element. this note gets all attributes
        from the chord (except the chord/@xml:id) and all attributes from the first contained note -->
    <xsl:template match="mei:chord" mode="getFirstNote">
        <note xmlns="http://www.music-encoding.org/ns/mei">
            <xsl:apply-templates select="(@* except @xml:id) | ./mei:note[1]/@*" mode="#current"/>
        </note>
    </xsl:template>
    
    <!-- for all subsequent "new" layers, replace everything with a duration that is not a chord with a space of equal duration.
        this avoids rendering single notes and rests multiple times -->
    <xsl:template match="mei:*[@dur]" mode="stripToLayer">
        <space xmlns="http://www.music-encoding.org/ns/mei">
            <xsl:apply-templates select="@dur | @dots" mode="#current"/>
        </space>
    </xsl:template>
    
    <!-- handling of chords in subsequent "new" layers. this template gets priority over the template matching "mei:*[@dur]" in mode="stripToLayer" -->
    <xsl:template match="mei:chord" mode="stripToLayer" priority="1">
        <!-- identify in which iteration we are -->
        <xsl:param name="noteNum" tunnel="yes" as="xs:integer"/>
        <xsl:choose>
            <!-- if this particular chord has sufficient notes, create a note for this layer -->
            <xsl:when test="exists(./mei:note[$noteNum])">
                <note xmlns="http://www.music-encoding.org/ns/mei">
                    <xsl:apply-templates select="(@* except @xml:id) | ./mei:note[$noteNum]/@*" mode="#current"/>
                </note>
            </xsl:when>
            <!-- if this particular chord doesn't have sufficient notes, create a space of corresponding duration instead -->
            <xsl:otherwise>
                <space xmlns="http://www.music-encoding.org/ns/mei">
                    <xsl:apply-templates select="@dur | @dots" mode="#current"/>
                </space>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- for the additional "new" layers, ignore beams -->
    <xsl:template match="mei:beam" mode="stripToLayer">
        <xsl:apply-templates select="node()" mode="#current"/>
    </xsl:template>
    
    <!-- for the additional "new" layers, ignore clefs -->
    <xsl:template match="mei:clef" mode="stripToLayer"/>
    
    <!-- specify the right barline for all measures. this template seems irrelevant already -->
    <xsl:template match="mei:measure[not(@right)]" mode="#all">
        <xsl:copy>
            <xsl:attribute name="right" select="'single'"/>
            <xsl:apply-templates select="node() | @*" mode="#current"/>
        </xsl:copy>
    </xsl:template>
  
  <!-- ignore cpMarks -->
    <xsl:template match="mei:cpMark"/>
  
  <!-- sic -->
  <!-- abbr -->
  <!-- expan -->
    <xsl:template match="mei:choice" mode="#all">
        <xsl:choose>
            <xsl:when test="mei:sic and mei:corr">
                <xsl:apply-templates select="mei:sic/*" mode="#current"/>
            </xsl:when>
            <xsl:when test="mei:abbr and mei:expan">
                <xsl:apply-templates select="mei:expan/*" mode="#current"/>
            </xsl:when>
            <xsl:when test="mei:orig and mei:reg">
                <xsl:apply-templates select="mei:reg/*" mode="#current"/>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    
    <!-- generic copy template -->
    <xsl:template match="node() | @*" mode="#all">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*" mode="#current"/>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>
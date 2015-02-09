<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:mei="http://www.music-encoding.org/ns/mei" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" exclude-result-prefixes="xs xd mei" version="2.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Apr 23, 2014</xd:p>
            <xd:p><xd:b>Author:</xd:b> johannes</xd:p>
            <xd:p>This sytelsheet wraps a control element with a choice</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:output method="xml" indent="yes"/>
    <xsl:param name="startIDs"/>
    <xsl:param name="endIDs"/>
    <xsl:param name="tstamp"/>
    <xsl:param name="tstamp2"/>
    <xsl:variable name="elem" select="/mei:*"/>
    <xsl:variable name="starts" select="tokenize($startIDs,',')" as="xs:string*"/>
    <xsl:variable name="ends" select="tokenize($endIDs,',')" as="xs:string*"/>
    <xsl:variable name="ceType"
        select="if(local-name($elem) = 'choice') then(local-name($elem/mei:orig/mei:*)) else(local-name($elem))"
        as="xs:string"/>
    <xsl:variable name="tstamped" select="$tstamp != '' or $tstamp2 != ''" as="xs:boolean"/>
    <xsl:variable name="singleElem" select="count($starts) = 1 and count($ends) = 1" as="xs:boolean"/>
    <xsl:variable name="wasChoiced" select="local-name($elem) = 'choice'" as="xs:boolean"/>
    <xsl:variable name="sameas" select="(//@sameas)[1]"/>
    <xsl:template match="/">
        <xsl:choose>
            <xsl:when test="$singleElem and not($tstamped)">
                <xsl:choose>
                    <xsl:when test="$ceType = 'slur'">
                        <slur xmlns="http://www.music-encoding.org/ns/mei" startid="#{$startIDs[1]}"
                            endid="#{$endIDs[1]}">
                            <xsl:attribute name="xml:id" select="$elem/@xml:id"/>
                            <xsl:attribute name="sameas" select="$sameas"/>
                            <xsl:apply-templates
                                select="$elem//(@* except (@tstamp,@tstamp2,@xml:id,@startid,@endid,@sameas,@xmlns))"
                            />
                        </slur>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="$wasChoiced">
                        <xsl:variable name="origElem" select="$elem/mei:orig/mei:*"/>
                        <xsl:choose>
                            <xsl:when test="$ceType = 'slur'">
                                <choice xmlns="http://www.music-encoding.org/ns/mei">
                                    <xsl:attribute name="xml:id" select="$elem/@xml:id"/>
                                    <orig>
                                        <slur>
                                            <xsl:apply-templates
                                                select="$origElem/(@* except (@xml:id,@startid,@endid,@sameas))"/>
                                            <xsl:if test="not($tstamp = '')">
                                                <xsl:attribute name="tstamp" select="$tstamp"/>
                                            </xsl:if>
                                            <xsl:if test="not($tstamp2 = '')">
                                                <xsl:attribute name="tstamp2" select="$tstamp2"/>
                                            </xsl:if>
                                        </slur>
                                    </orig>
                                    <xsl:for-each select="$starts">
                                        <xsl:variable name="currentStart" select="."/>
                                        <xsl:for-each select="$ends">
                                            <xsl:variable name="currentEnd" select="."/>
                                            <reg>
                                                <slur startid="#{$currentStart}"
                                                  endid="#{$currentEnd}" sameas="{$sameas}"/>
                                            </reg>
                                        </xsl:for-each>
                                    </xsl:for-each>
                                </choice>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:when test="local-name($elem) = 'slur'">
                        <choice xmlns="http://www.music-encoding.org/ns/mei">
                            <xsl:attribute name="xml:id" select="$elem/@xml:id"/>
                            <orig>
                                <slur>
                                    <xsl:apply-templates
                                        select="$elem/(@* except (@xml:id,@startid,@endid,@sameas))"/>
                                    <xsl:if test="not($tstamp = '')">
                                        <xsl:attribute name="tstamp" select="$tstamp"/>
                                    </xsl:if>
                                    <xsl:if test="not($tstamp2 = '')">
                                        <xsl:attribute name="tstamp2" select="$tstamp2"/>
                                    </xsl:if>
                                </slur>
                            </orig>
                            <xsl:for-each select="$starts">
                                <xsl:variable name="currentStart" select="."/>
                                <xsl:for-each select="$ends">
                                    <xsl:variable name="currentEnd" select="."/>
                                    <reg>
                                        <slur startid="#{$currentStart}" endid="#{$currentEnd}"
                                            sameas="{$sameas}"/>
                                    </reg>
                                </xsl:for-each>
                            </xsl:for-each>
                        </choice>
                    </xsl:when>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="node() | @*">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*"/>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>

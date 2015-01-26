<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:mei="http://www.music-encoding.org/ns/mei" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" exclude-result-prefixes="xs xd mei" version="2.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p>
                <xd:b>Created on:</xd:b> Mar 17, 2014</xd:p>
            <xd:p>
                <xd:b>Author:</xd:b> Johannes Kepper</xd:p>
            <xd:p>This stylesheet removes all contents from mei:staff. They need to be filled in 
                for saving the results.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:param name="staffID" as="xs:string"/>
    <xsl:param name="id_prefix" as="xs:string"/>
    <xsl:output method="xml" indent="yes"/>
    <xsl:variable name="staff" select="id($staffID)" as="node()"/>
    <xsl:variable name="providedScoreDef" select="//mei:meiHead//mei:scoreDef" as="node()?"/>
    <xsl:variable name="providedStaffDef" select="//mei:meiHead//mei:scoreDef//mei:staffDef[@n = $staff/@n]" as="node()?"/>
    <xsl:variable name="scoreDef" select="$staff/(preceding::mei:scoreDef)[1]" as="node()?"/>
    <xsl:variable name="staffDef" select="$staff/(preceding::mei:staffDef[@n = $staff/@n])[1]" as="node()?"/>
    <xsl:variable name="measure" select="$staff/parent::mei:measure" as="node()"/>
    <xsl:variable name="crossesPage" select="not(exists($measure/following::mei:measure))" as="xs:boolean"/>
    <xsl:variable name="crossesSection" select="not($crossesPage) and not(exists($measure/following-sibling::mei:measure))" as="xs:boolean"/>
    <xsl:variable name="nextMeasure" as="node()">
        <xsl:choose>
            <xsl:when test="not($crossesPage)">
                <xsl:copy-of select="$measure/(following::mei:measure)[1]"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="docname" select="substring-before(tokenize(document-uri(root()),'/')[last()],'.xml')" as="xs:string"/>
                <xsl:variable name="nextDoc">
                    <xsl:variable name="isSystem" select="matches($docname,'_sys\d+.xml')" as="xs:boolean"/>
                    <xsl:variable name="hasFollowingSystem" as="xs:boolean">
                        <xsl:choose>
                            <xsl:when test="$isSystem">
                                <xsl:variable name="sysNo" select="number(substring-before(substring-after($docname,'_sys'),'.xml'))" as="xs:double"/>
                                <xsl:variable name="nextSysName" select="replace($docname,concat('_sys',string($sysNo),'.xml'),concat('_sys',string($sysNo + 1),'.xml'))" as="xs:string"/>
                                <xsl:variable name="nextSysPath" select="replace(document-uri(root()),$docname,$nextSysName)" as="xs:string"/>
                                <xsl:value-of select="doc-available($nextSysPath)"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="false()"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <xsl:choose>
                        <xsl:when test="$hasFollowingSystem">
                            <xsl:variable name="sysNo" select="number(substring-before(substring-after($docname,'_sys'),'.xml'))" as="xs:double"/>
                            <xsl:variable name="nextSysName" select="replace($docname,concat('_sys',string($sysNo),'.xml'),concat('_sys',string($sysNo + 1),'.xml'))" as="xs:string"/>
                            <xsl:variable name="nextSysPath" select="replace(document-uri(root()),$docname,$nextSysName)" as="xs:string"/>
                            <xsl:copy-of select="doc($nextSysPath)"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:variable name="pageNo" select="number(substring-before(substring-after($docname,'_page'),'.xml'))" as="xs:double"/>
                            <xsl:variable name="nextPageName" select="replace($docname,concat('_page',string($pageNo),'.xml'),concat('_page',string($pageNo + 1),'.xml'))" as="xs:string"/>
                            <xsl:variable name="nextPagePath" select="replace(document-uri(root()),$docname,$nextPageName)" as="xs:string"/>
                            <xsl:copy-of select="doc($nextPagePath)"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:copy-of select="$nextDoc//(mei:measure)[1]"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="nextStaff" select="$nextMeasure/mei:staff[@n = $staff/@n]" as="node()"/>
    <xsl:template match="/">
        <mei xmlns="http://www.music-encoding.org/ns/mei" meiversion="2013">
            <meiHead>
                <fileDesc>
                    <titleStmt>
                        <title>excerpted staff</title>
                    </titleStmt>
                    <pubStmt/>
                </fileDesc>
            </meiHead>
            <music>
                <body>
                    <mdiv>
                        <score>
                            <scoreDef>
                                <xsl:copy-of select="$providedScoreDef/@* | $scoreDef/@*"/>
                                <staffGrp>
                                    <staffDef>
                                        <xsl:copy-of select="$providedStaffDef/@* | $staffDef/@*"/>
                                    </staffDef>
                                </staffGrp>
                            </scoreDef>
                            <xsl:choose>
                                <xsl:when test="not($crossesSection)">
                                    <section>
                                        <measure>
                                            <xsl:copy-of select="$measure/(@* except @xml:id)"/>
                                            <xsl:apply-templates select="$staff"/>
                                        </measure>
                                        <measure>
                                            <xsl:copy-of select="$nextMeasure/(@* except @xml:id)"/>
                                            <xsl:apply-templates select="$nextStaff" mode="nextStaff">
                                                <xsl:with-param name="firstID" tunnel="yes" select="$nextStaff//(mei:*[local-name() = ('note','rest','chord') and not(parent::mei:chord)])[1]/@xml:id"/>
                                            </xsl:apply-templates>
                                        </measure>
                                    </section>
                                </xsl:when>
                                <xsl:otherwise>
                                    <section>
                                        <measure>
                                            <xsl:copy-of select="$measure/(@* except @xml:id)"/>
                                            <xsl:apply-templates select="$staff"/>
                                        </measure>
                                    </section>
                                    <section>
                                        <xsl:copy-of select="$measure/(following::mei:section)[1]/(@* except @xml:id)"/>
                                        <measure>
                                            <xsl:copy-of select="$nextMeasure/(@* except @xml:id)"/>
                                            <xsl:apply-templates select="$nextStaff" mode="nextStaff">
                                                <xsl:with-param name="firstID" tunnel="yes" select="($nextStaff//mei:chord | mei:rest | mei:note[not(parent::mei:chord)])[1]/@xml:id"/>
                                            </xsl:apply-templates>
                                        </measure>
                                    </section>
                                </xsl:otherwise>
                            </xsl:choose>
                        </score>
                    </mdiv>
                </body>
            </music>
        </mei>
    </xsl:template>
    <xsl:template match="mei:beam" mode="nextStaff">
        <xsl:apply-templates select="(child::mei:*)[1]" mode="#current"/>
    </xsl:template>
    <xsl:template match="mei:tuplet" mode="nextStaff">
        <xsl:apply-templates select="(child::mei:*)[1]" mode="#current"/>
    </xsl:template>
    
    <!--<xsl:template match="mei:chord" mode="nextStaff">
        <xsl:param name="firstID" tunnel="yes"/>
        
        <xsl:if test="@xml:id = $firstID">
            <xsl:copy>
                <xsl:apply-templates select="node() | @*" mode="#current"/>
            </xsl:copy>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="mei:rest" mode="nextStaff">
        <xsl:param name="firstID" tunnel="yes"/>
        
        <xsl:if test="@xml:id = $firstID">
            <xsl:copy>
                <xsl:apply-templates select="node() | @*" mode="#current"/>
            </xsl:copy>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="mei:note[not(parent::mei:chord)]" mode="nextStaff">
        <xsl:param name="firstID" tunnel="yes"/>
        
        <xsl:if test="@xml:id = $firstID">
            <xsl:copy>
                <xsl:apply-templates select="node() | @*" mode="#current"/>
            </xsl:copy>
        </xsl:if>
    </xsl:template>-->
    <xsl:template match="mei:fTrem">
        <beam xmlns="http://www.music-encoding.org/ns/mei">
            <xsl:apply-templates select="node()"/>
        </beam>
    </xsl:template>
    <xsl:template match="mei:note[ancestor::mei:fTrem]">
        <xsl:copy>
            <xsl:apply-templates select="@* except @dur"/>
            <xsl:attribute name="dur" select="'8'"/>
            <xsl:attribute name="type" select="'fTrem'"/>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="mei:layer" mode="nextStaff">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates select="(child::mei:*)[1]" mode="nextStaff"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="@xml:id" mode="#all">
        <xsl:attribute name="xml:id" select="concat($id_prefix,.)"/>
    </xsl:template>
    <xsl:template match="node() | @*" mode="#all">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*" mode="#current"/>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>
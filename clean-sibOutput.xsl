<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:mei="http://www.music-encoding.org/ns/mei"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <!-- cleaning up the standard sibmei output and create a fully compatible MEI 3.0 version -->
    
    <!-- strip spaces -->
    <!--<xsl:strip-space elements="mei:staffDef mei:scoreDef mei:measure mei:section"/>-->
    
    
    <!-- adding application info -->
    <xsl:template match="mei:appInfo">
        <xsl:copy>
            <xsl:copy-of select="*"/>
            <xsl:element name="application" namespace="http://www.music-encoding.org/ns/mei">
                <xsl:attribute name="xml:id">
                    <xsl:text>clean-sibOutput</xsl:text>
                </xsl:attribute>
                <xsl:attribute name="isodate">
                    <xsl:value-of select="current-dateTime()"/>
                </xsl:attribute>
                <xsl:attribute name="type">
                    <xsl:text>xslt-script</xsl:text>
                </xsl:attribute>
                <xsl:element name="name" namespace="http://www.music-encoding.org/ns/mei">
                    <xsl:text>CMO clean sibmei Output prototype</xsl:text>
                </xsl:element>
            </xsl:element>
        </xsl:copy>
    </xsl:template>
    
    <!-- insert title information in header -->
    <!-- Title -->
    <xsl:template match="//mei:fileDesc/mei:titleStmt/mei:title">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:value-of select="./ancestor::mei:mei//mei:anchoredText/mei:title"/>    
        </xsl:copy>
        <xsl:apply-templates select="node()" />
    </xsl:template>
    <xsl:template match="mei:anchoredText[mei:title]"/>
    
    <!-- Composer -->
    <xsl:template match="//mei:fileDesc/mei:titleStmt/mei:respStmt/mei:persName[@xml:id]" name="composer">
        <xsl:copy>
            <xsl:attribute name="role">
                <xsl:text>Composer</xsl:text>
            </xsl:attribute>
            <xsl:apply-templates select="@*"/>
            <xsl:value-of select="./ancestor::mei:mei//mei:anchoredText[@label='composer']"/>  
        </xsl:copy>
    </xsl:template>
    <xsl:template match="mei:anchoredText[@label='composer']"/>
    
    <!-- Editor -->
    <xsl:template match="//mei:fileDesc/mei:titleStmt/mei:respStmt">
        <xsl:copy>
            <xsl:apply-templates select="@xml:id"/>
            <xsl:apply-templates select="node()"/>
            <xsl:element name="persName" namespace="http://www.music-encoding.org/ns/mei">
                <xsl:attribute name="role">
                    <xsl:text>Editor</xsl:text>
                </xsl:attribute>
                <xsl:value-of select="./ancestor::mei:mei//mei:anchoredText[@label='Editor_Initials']"/>
            </xsl:element>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="mei:anchoredText[@label='Editor_Initials']"/>
    
    <!-- clean notes -->
    <xsl:template match="mei:note/@dur.ges"/>
    <xsl:template match="mei:note/@oct.ges"/>
    <xsl:template match="mei:note/@pnum"/>
    
    <!-- clean rests -->
    <xsl:template match="mei:rest/@dur.ges"/>
    
    <!-- clean chords -->
    <xsl:template match="mei:chord/@dur.ges"/>
    
    <!-- clean scoreDef -->
    <xsl:template match="mei:scoreDef/@lyric.name"/>
    <xsl:template match="mei:scoreDef/@music.name"/>
    <xsl:template match="mei:scoreDef/@page.botmar"/>
    <xsl:template match="mei:scoreDef/@page.height"/>
    <xsl:template match="mei:scoreDef/@page.leftmar"/>
    <xsl:template match="mei:scoreDef/@page.rightmar"/>
    <xsl:template match="mei:scoreDef/@page.topmar"/>
    <xsl:template match="mei:scoreDef/@page.width"/>
    <xsl:template match="mei:scoreDef/@ppq"/>
    <xsl:template match="mei:scoreDef/@text.name"/>
    
    <!--
    <xsl:template match="mei:scoreDef/@meter.count"/>
    <xsl:template match="mei:scoreDef/@meter.unit"/>
    -->
    
    <!-- clean staffDef -->
    <xsl:template match="mei:staffDef/mei:instrDef"/>
    <xsl:template match="mei:staffDef/@key.mode"/>
    <xsl:template match="mei:staffDef/@key.sig"/>
    <xsl:template match="mei:staffDef/@clef.dis"/>
    <xsl:template match="mei:staffDef/@clef.dis.place"/>
    <xsl:template match="mei:staffDef/comment()"/>
    
    <!-- correct accidentals -->
    
    
    <!-- delete page breaks -->
    <xsl:template match="mei:pb"/>
    
    <!-- put Hanes into sections -->
    <xsl:template match="mei:measure[mei:anchoredText/@label='Hâne']">
        <xsl:variable name="start_measure" select="."/>
        <xsl:variable name="next_start" select="$start_measure/following-sibling::mei:measure[mei:anchoredText/@label='Hâne'][1]/@xml:id"/>
        <xsl:element name="section" namespace="http://www.music-encoding.org/ns/mei">
            <xsl:attribute name="label">
                <xsl:value-of select="mei:anchoredText[@label='Hâne']"/>
            </xsl:attribute>
            <xsl:copy>
                <!-- mark measure as hamparsum sub division or end of cycle -->
                <xsl:choose>
                    <xsl:when test="mei:dir/mei:symbol/@type = 'HampSubDivision'">
                        <xsl:attribute name="type">
                            <xsl:text>HampSubDivision</xsl:text>
                        </xsl:attribute>
                    </xsl:when>
                    <xsl:when test="mei:dir/mei:symbol/@type = 'HampEndCycle'">
                        <xsl:attribute name="type">
                            <xsl:text>HampEndCycle</xsl:text>
                        </xsl:attribute>
                    </xsl:when>
                </xsl:choose>
                <xsl:apply-templates select="@* | node()"/>
            </xsl:copy>
            <xsl:for-each select="./following-sibling::mei:measure[not(mei:anchoredText/@label='Hâne')][preceding-sibling::mei:measure[mei:anchoredText/@label='Hâne'][1] = $start_measure]">
                <xsl:copy>
                    <!-- mark measure as hamparsum sub division or end of cycle -->
                    <xsl:choose>
                        <xsl:when test="mei:dir/mei:symbol/@type = 'HampSubDivision'">
                            <xsl:attribute name="type">
                                <xsl:text>HampSubDivision</xsl:text>
                            </xsl:attribute>
                        </xsl:when>
                        <xsl:when test="mei:dir/mei:symbol/@type = 'HampEndCycle'">
                            <xsl:attribute name="type">
                                <xsl:text>HampEndCycle</xsl:text>
                            </xsl:attribute>
                        </xsl:when>
                    </xsl:choose>
                    <xsl:apply-templates select="@* | node()"/>
                </xsl:copy>
            </xsl:for-each>
        </xsl:element>
    </xsl:template>
    <xsl:template match="mei:measure[not(mei:anchoredText/@label='Hâne')]"/>
    <xsl:template match="mei:anchoredText[@label='Hâne']"/>
    
    <!-- copy every node in file -->  
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" />
        </xsl:copy>
    </xsl:template>
    
    
    
</xsl:stylesheet>
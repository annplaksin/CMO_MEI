<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:mei="http://www.music-encoding.org/ns/mei"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <xsl:variable name="suppliedColor" select="'rgba(170,0,0,1)'"/>
    <xsl:variable name="suppliedSubtype" select="'supplied'"/>
    
    <!-- catching colored notes and transform them into <supplied> elements -->
    <!--<xsl:template match="*[(./mei:note[@color=$suppliedColor]) and (count(./mei:note[@color=$suppliedColor]) &lt; count(./*))]">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:for-each-group select="*" group-adjacent="@color=$suppliedColor">
                <xsl:variable name="grp" select="current-group()"/>
                <xsl:choose>
                    <xsl:when test="current-grouping-key()">
                        <xsl:element name="supplied" namespace="http://www.music-encoding.org/ns/mei">
                            <xsl:apply-templates select="$grp"/>
                        </xsl:element>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates select="$grp"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each-group>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="mei:beam[count(./mei:note[@color=$suppliedColor]) = count(./*)]">
        <xsl:element name="supplied" namespace="http://www.music-encoding.org/ns/mei">
            <xsl:copy>
                <xsl:apply-templates select="@*"/>
                <xsl:apply-templates select="./*"/>
            </xsl:copy>
        </xsl:element>
    </xsl:template>-->
    
    <!-- suppress color -->
    <xsl:template match="@color[$suppliedColor]"/>
    
    <!-- put whole measures into supplied elements if not a whole section is affected -->
    <xsl:template match="*[(./mei:measure[contains(@type,$suppliedSubtype)]) and (count(./mei:measure[contains(@type,$suppliedSubtype)]) &lt; count(./*))]">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:for-each-group select="*" group-adjacent="@subtype=$suppliedSubtype">
                <xsl:variable name="grp" select="current-group()"/>
                <xsl:choose>
                    <xsl:when test="current-grouping-key()">
                        <xsl:element name="supplied" namespace="http://www.music-encoding.org/ns/mei">
                            <xsl:apply-templates select="$grp"/>
                        </xsl:element>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates select="$grp"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each-group>
        </xsl:copy>
    </xsl:template>
    
    <!-- put whole section into supplied element if every measure of a section is affected -->
    <xsl:template match="*[(./mei:measure[contains(@type,$suppliedSubtype)]) and (count(./mei:measure[contains(@type,$suppliedSubtype)]) = count(./*))]">
        <xsl:element name="supplied" namespace="http://www.music-encoding.org/ns/mei">
            <xsl:copy>
                <xsl:apply-templates select="@*|node()"/>
            </xsl:copy>
        </xsl:element>
    </xsl:template>
    
    <!-- catching enclosed accidentals and put them into <supplied> elements -->
    <xsl:template match="mei:accid[@enclose='paren']">
        <xsl:element name="supplied" namespace="http://www.music-encoding.org/ns/mei">
            <xsl:copy>
                <xsl:apply-templates select="@*"/>
            </xsl:copy>
        </xsl:element>
    </xsl:template>
    <xsl:template match="@enclose['paren']"/>
    
    <!-- copy every node in file -->  
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" />
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>
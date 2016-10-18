<?xml version='1.0'?>
<xsl:stylesheet version="1.0"
                xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
                xmlns:marc="http://www.loc.gov/MARC21/slim"
                xmlns:bf="http://id.loc.gov/ontologies/bibframe/"
                xmlns:bflc="http://id.loc.gov/ontologies/bibframe/lc-extensions/"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                exclude-result-prefixes="xsl marc">

  <!--
      Conversion specs for Uniform Titles
  -->

  <!-- bf:Work properties from Uniform Title fields -->
  <xsl:template match="marc:datafield[@tag='130' or @tag='240']" mode="work">
    <xsl:param name="recordid"/>
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:variable name="titleiri"><xsl:value-of select="$recordid"/>#Title<xsl:value-of select="@tag"/>-<xsl:value-of select="position()"/></xsl:variable>
    <xsl:apply-templates mode="workUnifTitle" select=".">
      <xsl:with-param name="titleiri" select="$titleiri"/>
      <xsl:with-param name="serialization" select="$serialization"/>
    </xsl:apply-templates>
  </xsl:template>

  <!-- can be applied by template above or by name/subject/series templates -->
  <xsl:template match="*" mode="workUnifTitle">
    <xsl:param name="titleiri"/>
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:variable name="tag">
      <xsl:choose>
        <xsl:when test="@tag=880">
          <xsl:value-of select="substring(marc:subfield[@code='6'],1,3)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="@tag"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$serialization = 'rdfxml'">
        <bf:title>
          <xsl:apply-templates mode="titleUnifTitle" select=".">
            <xsl:with-param name="titleiri" select="$titleiri"/>
            <xsl:with-param name="serialization" select="$serialization"/>
          </xsl:apply-templates>
        </bf:title>
        <xsl:if test="substring($tag,2,2)='10' or substring($tag,2,2)='30' or $tag='240'">
          <xsl:for-each select="marc:subfield[@code='d']">
            <bf:legalDate><xsl:value-of select="."/></bf:legalDate>
          </xsl:for-each>
        </xsl:if>
        <xsl:for-each select="marc:subfield[@code='f']">
          <bf:originDate><xsl:value-of select="."/></bf:originDate>
        </xsl:for-each>
        <xsl:for-each select="marc:subfield[@code='g']">
          <bf:genreForm>
            <bf:GenreForm>
              <rdfs:label><xsl:value-of select="."/></rdfs:label>
            </bf:GenreForm>
          </bf:genreForm>
        </xsl:for-each>
        <xsl:for-each select="marc:subfield[@code='h']">
          <bf:genreForm>
            <bf:GenreForm>
              <rdfs:label><xsl:value-of select="."/></rdfs:label>
            </bf:GenreForm>
          </bf:genreForm>
        </xsl:for-each>        
        <xsl:for-each select="marc:subfield[@code='k']">
          <bf:natureOfContent><xsl:value-of select="."/></bf:natureOfContent>
          <bf:genreForm>
            <bf:GenreForm>
              <rdfs:label><xsl:value-of select="."/></rdfs:label>
            </bf:GenreForm>
          </bf:genreForm>
        </xsl:for-each>        
        <xsl:for-each select="marc:subfield[@code='l']">
          <bf:language>
            <bf:Language>
              <rdfs:label><xsl:value-of select="."/></rdfs:label>
            </bf:Language>
          </bf:language>
        </xsl:for-each>
        <xsl:for-each select="marc:subfield[@code='m']">
          <bf:musicMedium>
            <bf:MusicMedium>
              <rdfs:label><xsl:value-of select="."/></rdfs:label>
            </bf:MusicMedium>
          </bf:musicMedium>
        </xsl:for-each>
        <xsl:for-each select="marc:subfield[@code='o' or @code='s']">
          <bf:version><xsl:value-of select="."/></bf:version>
        </xsl:for-each>
        <xsl:for-each select="marc:subfield[@code='r']">
          <bf:musicKey><xsl:value-of select="."/></bf:musicKey>
        </xsl:for-each>
        <xsl:for-each select="marc:subfield[@code='i']">
          <bf:relationship>
            <bf:Relationship>
              <bf:relation>
                <rdf:Resource>
                  <rdfs:label><xsl:value-of select="."/></rdfs:label>
                </rdf:Resource>
              </bf:relation>
              <bf:relatedTo><xsl:value-of select="concat(substring-before($titleiri,'#'),'#Work')"/></bf:relatedTo>
            </bf:Relationship>
          </bf:relationship>
        </xsl:for-each>
        <xsl:if test="substring($tag,1,1)='8'">
          <xsl:for-each select="marc:subfield[@code='v']">
            <bf:seriesEnumeration><xsl:value-of select="."/></bf:seriesEnumeration>
          </xsl:for-each>
        </xsl:if>
        <xsl:if test="substring($tag,1,1)='7' or substring($tag,1,1)='8'">
         <xsl:for-each select="marc:subfield[@code='x']">
           <bf:identifiedBy>
             <bf:Issn>
               <rdf:value><xsl:value-of select="."/></rdf:value>
             </bf:Issn>
           </bf:identifiedBy>
         </xsl:for-each>
        </xsl:if>
        <xsl:for-each select="marc:subfield[@code='0' or code='w']">
          <xsl:apply-templates mode="subfield0orw" select=".">
            <xsl:with-param name="serialization" select="$serialization"/>
          </xsl:apply-templates>
        </xsl:for-each>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="*" mode="titleUnifTitle">
    <xsl:param name="titleiri"/>
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:variable name="tag">
      <xsl:choose>
        <xsl:when test="@tag=880">
          <xsl:value-of select="substring(marc:subfield[@code='6'],1,3)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="@tag"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="nfi">
      <xsl:choose>
        <xsl:when test="$tag='130' or $tag='630' or $tag='730'">
          <xsl:value-of select="@ind1"/>
        </xsl:when>
        <xsl:when test="$tag='240'">
          <xsl:value-of select="@ind2"/>
        </xsl:when>
        <xsl:otherwise>0</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="label">
      <xsl:choose>
        <xsl:when test="substring($tag,2,2)='00'">
          <xsl:apply-templates mode="concat-nodes-space"
                               select="marc:subfield[@code='t' or
                                   @code='f' or
                                   @code='g' or 
                                   @code='k' or
                                   @code='l' or
                                   @code='m' or
                                   @code='n' or
                                   @code='o' or
                                   @code='p' or
                                   @code='r' or
                                   @code='s']"/>
        </xsl:when>
        <xsl:when test="substring($tag,2,2)='10'">
          <xsl:apply-templates mode="concat-nodes-space"
                               select="marc:subfield[@code='t' or
                                   @code='d' or
                                   @code='f' or
                                   @code='g' or 
                                   @code='k' or
                                   @code='l' or
                                   @code='m' or
                                   @code='n' or
                                   @code='o' or
                                   @code='p' or
                                   @code='r' or
                                   @code='s']"/>
        </xsl:when>
        <xsl:when test="substring($tag,2,2)='11'">
          <xsl:apply-templates mode="concat-nodes-space"
                               select="marc:subfield[@code='t' or
                                   @code='f' or
                                   @code='g' or 
                                   @code='k' or
                                   @code='l' or
                                   @code='n' or
                                   @code='p' or
                                   @code='s']"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates mode="concat-nodes-space"
                               select="marc:subfield[@code='a' or
                                   @code='d' or
                                   @code='f' or
                                   @code='g' or 
                                   @code='k' or
                                   @code='l' or
                                   @code='m' or
                                   @code='n' or
                                   @code='o' or
                                   @code='p' or
                                   @code='r' or
                                   @code='s']"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="marckey">
      <xsl:choose>
        <xsl:when test="substring($tag,2,2)='00'">
          <xsl:apply-templates mode="titleMarcKey"
                               select="marc:subfield[@code='t' or
                                   @code='f' or
                                   @code='g' or 
                                   @code='k' or
                                   @code='l' or
                                   @code='m' or
                                   @code='n' or
                                   @code='o' or
                                   @code='p' or
                                   @code='r' or
                                   @code='s']"/>
        </xsl:when>
        <xsl:when test="substring($tag,2,2)='10'">
          <xsl:apply-templates mode="titleMarcKey"
                               select="marc:subfield[@code='t' or
                                   @code='d' or
                                   @code='f' or
                                   @code='g' or 
                                   @code='k' or
                                   @code='l' or
                                   @code='m' or
                                   @code='n' or
                                   @code='o' or
                                   @code='p' or
                                   @code='r' or
                                   @code='s']"/>
        </xsl:when>
        <xsl:when test="substring($tag,2,2)='11'">
          <xsl:apply-templates mode="titleMarcKey"
                               select="marc:subfield[@code='t' or
                                   @code='f' or
                                   @code='g' or 
                                   @code='k' or
                                   @code='l' or
                                   @code='n' or
                                   @code='p' or
                                   @code='s']"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates mode="titleMarcKey"
                               select="marc:subfield[@code='a' or
                                   @code='d' or
                                   @code='f' or
                                   @code='g' or 
                                   @code='k' or
                                   @code='l' or
                                   @code='m' or
                                   @code='n' or
                                   @code='o' or
                                   @code='p' or
                                   @code='r' or
                                   @code='s']"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$serialization = 'rdfxml'">
        <bf:Title>
          <xsl:attribute name="rdf:about"><xsl:value-of select="$titleiri"/></xsl:attribute>
          <rdf:type>bf:WorkTitle</rdf:type>
          <xsl:if test="$label != ''">
            <xsl:choose>
              <xsl:when test="substring($tag,2,2)='00'">
                <bflc:title00MatchKey>
                  <xsl:call-template name="simple-normalize">
                    <xsl:with-param name="str" select="$label"/>
                  </xsl:call-template>
                </bflc:title00MatchKey>
                <bflc:title00MarcKey><xsl:value-of select="normalize-space($marckey)"/></bflc:title00MarcKey>
              </xsl:when>
              <xsl:when test="substring($tag,2,2)='10'">
                <bflc:title10MatchKey>
                  <xsl:call-template name="simple-normalize">
                    <xsl:with-param name="str" select="$label"/>
                  </xsl:call-template>
                </bflc:title10MatchKey>
                <bflc:title10MarcKey><xsl:value-of select="normalize-space($marckey)"/></bflc:title10MarcKey>
              </xsl:when>
              <xsl:when test="substring($tag,2,2)='11'">
                <bflc:title11MatchKey>
                  <xsl:call-template name="simple-normalize">
                    <xsl:with-param name="str" select="$label"/>
                  </xsl:call-template>
                </bflc:title11MatchKey>
                <bflc:title11MarcKey><xsl:value-of select="normalize-space($marckey)"/></bflc:title11MarcKey>
              </xsl:when>
              <xsl:when test="substring($tag,2,2)='30'">
                <bflc:title30MatchKey>
                  <xsl:call-template name="simple-normalize">
                    <xsl:with-param name="str" select="$label"/>
                  </xsl:call-template>
                </bflc:title30MatchKey>
                <bflc:title30MarcKey><xsl:value-of select="normalize-space($marckey)"/></bflc:title30MarcKey>
              </xsl:when>
              <xsl:when test="substring($tag,2,2)='40'">
                <bflc:title40MatchKey>
                  <xsl:call-template name="simple-normalize">
                    <xsl:with-param name="str" select="$label"/>
                  </xsl:call-template>
                </bflc:title40MatchKey>
                <bflc:title40MarcKey><xsl:value-of select="normalize-space($marckey)"/></bflc:title40MarcKey>
              </xsl:when>
            </xsl:choose>
            <rdfs:label><xsl:value-of select="normalize-space($label)"/></rdfs:label>
            <bflc:titleSortKey><xsl:value-of select="normalize-space(substring($label,$nfi+1))"/></bflc:titleSortKey>
          </xsl:if>            
          <xsl:for-each select="marc:subfield[@code='a' or @code='t']">
            <bf:mainTitle><xsl:value-of select="."/></bf:mainTitle>
          </xsl:for-each>
          <xsl:for-each select="marc:subfield[@code='n']">
            <bf:partNumber><xsl:value-of select="."/></bf:partNumber>
          </xsl:for-each>
          <xsl:for-each select="marc:subfield[@code='p']">
            <bf:partName><xsl:value-of select="."/></bf:partName>
          </xsl:for-each>
        </bf:Title>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="*" mode="titleMarcKey">
    <xsl:text>$</xsl:text><xsl:value-of select="@code"/><xsl:text> </xsl:text><xsl:value-of select="."/><xsl:text> </xsl:text>
  </xsl:template>
  
</xsl:stylesheet>
<?xml version="1.0" encoding="UTF-8" ?>
<!--
/**
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements. See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License. You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
-->

<!--
* ====================================================================
* wsdl-viewer.xsl
* Author: tomi vanek
* ====================================================================
* Description:
* 		Source code syntax highlighting
* ====================================================================
-->

<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns="http://www.w3.org/1999/xhtml"
	xmlns:ws="http://schemas.xmlsoap.org/wsdl/"
	xmlns:ws2="http://www.w3.org/ns/wsdl"
	xmlns:xsd="http://www.w3.org/2001/XMLSchema"
	xmlns:soap="http://schemas.xmlsoap.org/wsdl/soap/"
	xmlns:local="http://tomi.vanek.sk/xml/wsdl-viewer"
	exclude-result-prefixes="ws ws2 xsd soap local">

<!--
==================================================================
	Rendering: Imported files
==================================================================
-->
<xsl:template match="@*" mode="src.import">
	<xsl:param name="src.import.stack"/>
	<xsl:variable name="recursion.label" select="concat('[', string(.), ']')"/>
	<xsl:variable name="recursion.check" select="concat($src.import.stack, $recursion.label)"/>

	<xsl:choose>
		<xsl:when test="contains($src.import.stack, $recursion.label)">
			<h2 style="red"><xsl:value-of select="concat('Cyclic include / import: ', $recursion.check)"/></h2>
		</xsl:when>
		<xsl:otherwise>
			<h2><a name="{concat($SRC-FILE-PREFIX, generate-id(..))}">
			<xsl:choose>
				<xsl:when test="parent::xsd:include">Included </xsl:when>
				<xsl:otherwise>Imported </xsl:otherwise>
			</xsl:choose>

			<xsl:choose>
				<xsl:when test="name() = 'location'">WSDL </xsl:when>
				<xsl:otherwise>Schema </xsl:otherwise>
			</xsl:choose>
			<i><xsl:value-of select="."/></i></a></h2>

			<div class="box">
				<xsl:apply-templates select="document(string(.))" mode="src"/>
			</div>

			<xsl:apply-templates select="document(string(.))/*/*[local-name() = 'import'][@location]/@location" mode="src.import">
				<xsl:with-param name="src.import.stack" select="$recursion.check"/>
			</xsl:apply-templates>
			<xsl:apply-templates select="document(string(.))//xsd:import[@schemaLocation]/@schemaLocation" mode="src.import">
				<xsl:with-param name="src.import.stack" select="$recursion.check"/>
			</xsl:apply-templates>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<!--
==================================================================
	Rendering: Source code syntax coloring
==================================================================
-->
<xsl:template match="*" mode="src">
	<div class="xml-element">
		<a name="{concat($SRC-PREFIX, generate-id(.))}">
			<xsl:apply-templates select="." mode="src.link"/>
			<xsl:apply-templates select="." mode="src.start-tag"/>
		</a>
		<xsl:apply-templates select="*|comment()|processing-instruction()|text()[string-length(normalize-space(.)) &gt; 0]" mode="src"/>
		<xsl:apply-templates select="." mode="src.end-tag"/>
	</div>
</xsl:template>

<xsl:template match="*" mode="src.start-tag">
	<xsl:call-template name="src.elem">
		<xsl:with-param name="src.elem.end-slash"> /</xsl:with-param>
	</xsl:call-template>
</xsl:template>

<xsl:template match="*[*|comment()|processing-instruction()|text()[string-length(normalize-space(.)) &gt; 0]]" mode="src.start-tag">
	<xsl:call-template name="src.elem"/>
</xsl:template>

<xsl:template match="*" mode="src.end-tag"/>

<xsl:template match="*[*|comment()|processing-instruction()|text()[string-length(normalize-space(.)) &gt; 0]]" mode="src.end-tag">
	<xsl:call-template name="src.elem">
		<xsl:with-param name="src.elem.start-slash">/</xsl:with-param>
	</xsl:call-template>
</xsl:template>

<!--
==================================================================
	Rendering: Linking
==================================================================
-->
<xsl:template match="*" mode="src.link-attribute">
<xsl:if test="$ENABLE-LINK">
	<xsl:attribute name="href"><xsl:value-of select="concat('#', $SRC-PREFIX, generate-id(.))"/></xsl:attribute>
</xsl:if>
</xsl:template>

<xsl:template match="*[local-name() = 'import' or local-name() = 'include'][@location or @schemaLocation]" mode="src.link">
<xsl:if test="$ENABLE-LINK">
	<xsl:attribute name="href"><xsl:value-of select="concat('#', $SRC-FILE-PREFIX, generate-id(.))"/></xsl:attribute>
</xsl:if>
</xsl:template>

<xsl:template match="*" mode="src.link"/>

<!--
==================================================================
	Rendering: WSDL 2.0
==================================================================
-->
<xsl:template match="ws2:service|ws2:binding" mode="src.link">
	<xsl:variable name="iface-name">
		<xsl:apply-templates select="@interface" mode="qname.normalized"/>
	</xsl:variable>
	<xsl:apply-templates select="$consolidated-wsdl/ws2:interface[@name = $iface-name]" mode="src.link-attribute"/>
</xsl:template>

<xsl:template match="ws2:endpoint" mode="src.link">
	<xsl:variable name="binding-name">
		<xsl:apply-templates select="@binding" mode="qname.normalized"/>
	</xsl:variable>
	<xsl:apply-templates select="$consolidated-wsdl/ws2:binding[@name = $binding-name]" mode="src.link-attribute"/>
</xsl:template>

<xsl:template match="ws2:binding/ws2:operation" mode="src.link">
	<xsl:variable name="operation-name">
		<xsl:apply-templates select="@ref" mode="qname.normalized"/>
	</xsl:variable>
	<xsl:apply-templates select="$consolidated-wsdl/ws2:interface/ws2:operation[@name = $operation-name]" mode="src.link-attribute"/>
</xsl:template>

<xsl:template match="ws2:binding/ws2:fault|ws2:interface/ws2:operation/ws2:infault|ws2:interface/ws2:operation/ws2:outfault" mode="src.link">
	<xsl:variable name="operation-name">
		<xsl:apply-templates select="@ref" mode="qname.normalized"/>
	</xsl:variable>
	<xsl:apply-templates select="$consolidated-wsdl/ws2:interface/ws2:fault[@name = $operation-name]" mode="src.link-attribute"/>
</xsl:template>

<xsl:template match="ws2:interface/ws2:operation/ws2:input|ws2:interface/ws2:operation/ws2:output|ws2:interface/ws2:fault" mode="src.link">
	<xsl:variable name="elem-name">
		<xsl:apply-templates select="@element" mode="qname.normalized"/>
	</xsl:variable>
	<xsl:apply-templates select="$consolidated-xsd[@name = $elem-name]" mode="src.link-attribute"/>
</xsl:template>

<!--
==================================================================
	Rendering: WSDL 1.1
==================================================================
-->
<xsl:template match="ws:operation/ws:input[@message] | ws:operation/ws:output[@message] | ws:operation/ws:fault[@message] | soap:header[ancestor::ws:operation and @message]" mode="src.link">
	<xsl:apply-templates select="$consolidated-wsdl/ws:message[@name = substring-after( current()/@message, ':' )]" mode="src.link-attribute"/>
</xsl:template>

<xsl:template match="ws:operation/ws:input[@message] | ws:operation/ws:output[@message] | ws:operation/ws:fault[@message] | soap:header[ancestor::ws:operation and @message]" mode="src.link">
	<xsl:apply-templates select="$consolidated-wsdl/ws:message[@name = substring-after( current()/@message, ':' )]" mode="src.link-attribute"/>
</xsl:template>

<xsl:template match="ws:message/ws:part[@element or @type]" mode="src.link">
	<xsl:variable name="elem-local-name" select="substring-after(@element, ':')"/>
	<xsl:variable name="type-local-name" select="substring-after(@type, ':')"/>
	<xsl:variable name="elem-name">
		<xsl:choose>
			<xsl:when test="$elem-local-name"><xsl:value-of select="$elem-local-name"/></xsl:when>
			<xsl:when test="$type-local-name"><xsl:value-of select="$type-local-name"/></xsl:when>
			<xsl:when test="@element"><xsl:value-of select="@element"/></xsl:when>
			<xsl:when test="@type"><xsl:value-of select="@type"/></xsl:when>
			<xsl:otherwise><xsl:call-template name="src.syntax-error"/></xsl:otherwise>
		</xsl:choose>
	</xsl:variable>

	<xsl:apply-templates select="$consolidated-xsd[@name = $elem-name]" mode="src.link-attribute"/>
</xsl:template>

<xsl:template match="ws:service/ws:port[@binding]" mode="src.link">
	<xsl:variable name="binding-name">
		<xsl:apply-templates select="@binding" mode="qname.normalized"/>
	</xsl:variable>
	<xsl:apply-templates select="$consolidated-wsdl/ws:binding[@name = $binding-name]" mode="src.link-attribute"/>
</xsl:template>

<xsl:template match="ws:operation[@name and parent::ws:binding/@type]" mode="src.link">
	<xsl:variable name="type-name">
		<xsl:apply-templates select="../@type" mode="qname.normalized"/>
	</xsl:variable>
	<xsl:apply-templates select="$consolidated-wsdl/ws:portType[@name = $type-name]/ws:operation[@name = current()/@name]" mode="src.link-attribute"/>
</xsl:template>

<!--
==================================================================
	Rendering: XSD
==================================================================
-->
<xsl:template match="xsd:element[@ref or @type]" mode="src.link">
	<xsl:variable name="ref-or-type">
		<xsl:choose>
			<xsl:when test="@type"><xsl:value-of select="@type"/></xsl:when>
			<xsl:otherwise><xsl:value-of select="@ref"/></xsl:otherwise>
		</xsl:choose>
	</xsl:variable>

	<xsl:variable name="type-local-name" select="substring-after($ref-or-type, ':')"/>
	<xsl:variable name="xsd-name">
		<xsl:choose>
			<xsl:when test="$type-local-name"><xsl:value-of select="$type-local-name"/></xsl:when>
			<xsl:when test="$ref-or-type"><xsl:value-of select="$ref-or-type"/></xsl:when>
			<xsl:otherwise></xsl:otherwise>
		</xsl:choose>
	</xsl:variable>

	<xsl:if test="$xsd-name">
		<xsl:variable name="msg" select="$consolidated-xsd[@name = $xsd-name and contains(local-name(), 'Type')][1]"/>
		<xsl:apply-templates select="$msg" mode="src.link-attribute"/>
	</xsl:if>
</xsl:template>

<xsl:template match="xsd:attribute[contains(@ref, 'arrayType')]" mode="src.link">
	<xsl:variable name="att-array-type" select="substring-before(@*[local-name() = 'arrayType'], '[]')"/>
	<xsl:variable name="xsd-local-name" select="substring-after($att-array-type, ':')"/>
	<xsl:variable name="xsd-name">
		<xsl:choose>
			<xsl:when test="$xsd-local-name"><xsl:value-of select="$xsd-local-name"/></xsl:when>
			<xsl:otherwise><xsl:value-of select="$att-array-type"/></xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:if test="$xsd-name">
		<xsl:variable name="msg" select="$consolidated-xsd[@name = $xsd-name][1]"/>
		<xsl:apply-templates select="$msg" mode="src.link-attribute"/>
	</xsl:if>
</xsl:template>

<xsl:template match="xsd:extension | xsd:restriction" mode="src.link">
	<xsl:variable name="xsd-local-name" select="substring-after(@base, ':')"/>
	<xsl:variable name="xsd-name">
		<xsl:choose>
			<xsl:when test="$xsd-local-name"><xsl:value-of select="$xsd-local-name"/></xsl:when>
			<xsl:otherwise><xsl:value-of select="@type"/></xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:variable name="msg" select="$consolidated-xsd[@name = $xsd-name][1]"/>
	<xsl:apply-templates select="$msg" mode="src.link-attribute"/>
</xsl:template>


<!--
==================================================================
	Rendering: XML elements
==================================================================
-->
<xsl:template name="src.elem">
	<xsl:param name="src.elem.start-slash"/>
	<xsl:param name="src.elem.end-slash"/>

	<xsl:value-of select="concat('&lt;', $src.elem.start-slash, name(.))" disable-output-escaping="no"/>
	<xsl:if test="not($src.elem.start-slash)"><xsl:apply-templates select="@*" mode="src"/><xsl:apply-templates select="." mode="src.namespace"/></xsl:if>
	<xsl:value-of select="concat($src.elem.end-slash, '&gt;')" disable-output-escaping="no"/>
</xsl:template>

<xsl:template match="@*" mode="src">
	<xsl:text> </xsl:text>
	<span class="xml-att">
		<xsl:value-of select="concat(name(), '=')"/>
		<span class="xml-att-val">
			<xsl:value-of select="concat('&quot;', ., '&quot;')" disable-output-escaping="yes"/>
		</span>
	</span>
</xsl:template>

<!-- Inspiration: Jonathan Marsh -->
<xsl:template match="*" mode="src.namespace">
	<xsl:variable name="supports-namespace-axis" select="count(/*/namespace::*) &gt; 0"/>
	<xsl:variable name="current" select="current()"/>

	<xsl:choose>
		<xsl:when test="count(/*/namespace::*) &gt; 0">
				<!--
					When the namespace axis is present (e.g. Internet Explorer), we can simulate
					the namespace declarations by comparing the namespaces in scope on this element
					with those in scope on the parent element.  Any difference must have been the
					result of a namespace declaration.  Note that this doesn't reflect the actual
					source - it will strip out redundant namespace declarations.
				-->
			<xsl:for-each select="namespace::*[. != 'http://www.w3.org/XML/1998/namespace']"> 
				<xsl:if test="not($current/parent::*[namespace::*[. = current()]])">
					<div class="xml-att">
						<xsl:text> xmlns</xsl:text>
						<xsl:if test="string-length(name())">:</xsl:if>
						<xsl:value-of select="concat(name(), '=')"/>
						<span class="xml-att-val">
							<xsl:value-of select="concat('&quot;', ., '&quot;')" disable-output-escaping="yes"/>
						</span>
					</div>
				</xsl:if>
			</xsl:for-each>
		</xsl:when>
		<xsl:otherwise>
			<!-- 
				When the namespace axis isn't supported (e.g. Mozilla), we can simulate
				appropriate declarations from namespace elements.
				This currently doesn't check for namespaces on attributes.
				In the general case we can't reliably detect the use of QNames in content, but
				in the case of schema, we know which content could contain a QName and look
				there too.  This mechanism is rather unpleasant though, since it records
				namespaces where they are used rather than showing where they are declared 
				(on some parent element) in the source.  Yukk!
			-->
			<xsl:if test="namespace-uri(.) != namespace-uri(parent::*) or not(parent::*)">
				<span class="xml-att">
					<xsl:text> xmlns</xsl:text>
					<xsl:if test="substring-before(name(),':') != ''">:</xsl:if>
					<xsl:value-of select="substring-before(name(),':')"/>
					<xsl:text>=</xsl:text>
					<span class="xml-att-val">
						<xsl:value-of select="concat('&quot;', namespace-uri(.), '&quot;')" disable-output-escaping="yes"/>
					</span>
				</span>
			</xsl:if>
		</xsl:otherwise>
	</xsl:choose>

</xsl:template>

<xsl:template match="text()" mode="src">
	<span class="xml-text"><xsl:value-of select="." disable-output-escaping="no"/></span>
</xsl:template>

<xsl:template match="comment()" mode="src">
<div class="xml-comment">
	<xsl:text disable-output-escaping="no">&lt;!-- </xsl:text>
	<xsl:value-of select="." disable-output-escaping="no"/>
	<xsl:text disable-output-escaping="no"> --&gt;
</xsl:text>
</div>
</xsl:template>

<xsl:template match="processing-instruction()" mode="src">
<div class="xml-proc">
	<xsl:text disable-output-escaping="no">&lt;?</xsl:text>
	<xsl:copy-of select="name(.)"/>
	<xsl:value-of select="concat(' ', .)" disable-output-escaping="yes"/>
	<xsl:text disable-output-escaping="no"> ?&gt;
</xsl:text>
</div>
</xsl:template>


</xsl:stylesheet>

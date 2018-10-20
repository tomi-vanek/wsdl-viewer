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
* 		WSDL Operations rendering
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
	exclude-result-prefixes="ws xsd soap local">


<!--
==================================================================
	Rendering: WSDL operations declaration - WSDL 2.0
==================================================================
-->
<xsl:template match="ws2:interface" mode="operations">
	<xsl:if test="$ENABLE-PORTTYPE-NAME">
	<h3>
		<a name="{concat($IFACE-PREFIX, generate-id(.))}"><xsl:value-of select="$IFACE-TEXT"/><xsl:text>
</xsl:text><b> <xsl:value-of select="@name"/> </b></a>
		<xsl:call-template name="render.source-code-link"/>
	</h3>
	</xsl:if>

	<ol>
		<xsl:apply-templates select="ws2:operation" mode="operations">
			<xsl:sort select="@name"/>
		</xsl:apply-templates>
	</ol>
</xsl:template>

<xsl:template match="ws2:operation" mode="operations">
	<xsl:variable name="binding-info" select="$consolidated-wsdl/ws2:binding[@interface = current()/../@name or substring-after(@interface, ':') = current()/../@name]/ws2:operation[@ref = current()/@name or substring-after(@ref, ':') = current()/@name]"/>
<li>
<xsl:if test="position() != last()">
<xsl:attribute name="class">operation</xsl:attribute>
</xsl:if>
<big><b><a name="{concat($OPERATIONS-PREFIX, generate-id(.))}"><xsl:value-of select="@name"/></a></b></big>
	<div class="value"><xsl:text>
</xsl:text><xsl:call-template name="render.source-code-link"/></div>
	<xsl:apply-templates select="ws2:documentation" mode="documentation.render"/>

	<xsl:if test="$ENABLE-STYLEOPTYPEPATH">
		<!-- TODO: add the operation attributes - according the WSDL 2.0 spec. -->
	</xsl:if>
	<xsl:apply-templates select="ws2:input|ws2:output|../ws2:fault[@name = ws2:infault/@ref or @name = ws2:outfault/@ref]" mode="operations.message">
		<xsl:with-param name="binding-data" select="$binding-info"/>
	</xsl:apply-templates>
</li>
</xsl:template>

<xsl:template match="ws2:input|ws2:output|ws2:fault" mode="operations.message">
	<xsl:param name="binding-data"/>
	<xsl:if test="$ENABLE-INOUTFAULT">
		<div class="label"><xsl:value-of select="concat(translate(substring(local-name(.), 1, 1), 'abcdefghijklmnoprstuvwxyz', 'ABCDEFGHIJKLMNOPRSTUVWXYZ'), substring(local-name(.), 2), ':')"/></div>

		<div class="value">
			<xsl:variable name="type-name">
				<xsl:apply-templates select="@element" mode="qname.normalized"/>
			</xsl:variable>
	
			<xsl:call-template name="render-type">
				<xsl:with-param name="type-local-name" select="$type-name"/>
			</xsl:call-template>

			<xsl:call-template name="render.source-code-link"/>

			<xsl:variable name="type-tree" select="$consolidated-xsd[@name = $type-name and not(xsd:simpleType)][1]"/>
			<xsl:apply-templates select="$type-tree" mode="operations.message.part"/>
		</div>
	</xsl:if>
</xsl:template>

<!--
==================================================================
	Rendering: WSDL operations declaration - WSDL 1.1
==================================================================
-->
<xsl:template match="ws:portType" mode="operations">
<div>
<xsl:if test="position() != last()">
<xsl:attribute name="class">port</xsl:attribute>
</xsl:if>
<xsl:if test="$ENABLE-PORTTYPE-NAME">
<h3>
	<a name="{concat($PORT-PREFIX, generate-id(.))}"><xsl:value-of select="$PORT-TYPE-TEXT"/><xsl:text>
</xsl:text><b> <xsl:value-of select="@name"/> </b></a>
	<xsl:call-template name="render.source-code-link"/>
</h3>
</xsl:if>
<ol>
<xsl:apply-templates select="ws:operation" mode="operations">
	<xsl:sort select="@name"/>
</xsl:apply-templates>
</ol>
</div>
</xsl:template>

<xsl:template match="ws:operation" mode="operations">
	<xsl:variable name="binding-info" select="$consolidated-wsdl/ws:binding[@type = current()/../@name or substring-after(@type, ':') = current()/../@name]/ws:operation[@name = current()/@name]"/>
<li>
<xsl:if test="position() != last()">
<xsl:attribute name="class">operation</xsl:attribute>
</xsl:if>
<big><b><a name="{concat($OPERATIONS-PREFIX, generate-id(.))}"><xsl:value-of select="@name"/></a></b></big>
	<div class="value"><xsl:text>
</xsl:text><xsl:call-template name="render.source-code-link"/></div>

	<xsl:if test="$ENABLE-DESCRIPTION and string-length(ws:documentation) &gt; 0">
		<div class="label">Description:</div>
		<div class="value"><xsl:value-of select="ws:documentation" disable-output-escaping="yes"/></div>
	</xsl:if>

	<xsl:if test="$ENABLE-STYLEOPTYPEPATH">
		<xsl:variable name="binding-operation" select="$binding-info/*[local-name() = 'operation']"/>
		<xsl:if test="$binding-operation/@style">
			<div class="label">Style:</div>
			<div class="value"><xsl:value-of select="$binding-operation/@style" /></div>
		</xsl:if>
	
		<div class="label">Operation type:</div>
		<div class="value">
		<xsl:choose>
			<xsl:when test="$binding-info/ws:input[not(../ws:output)]"><i>One-way.</i> The endpoint receives a message.</xsl:when>
			<xsl:when test="$binding-info/ws:input[following-sibling::ws:output]"><i>Request-response.</i> The endpoint receives a message, and sends a correlated message.</xsl:when>
			<xsl:when test="$binding-info/ws:input[preceding-sibling::ws:output]"><i>Solicit-response.</i> The endpoint sends a message, and receives a correlated message.</xsl:when>
			<xsl:when test="$binding-info/ws:output[not(../ws:input)]"><i>Notification.</i> The endpoint sends a message.</xsl:when>
			<xsl:otherwise>unknown</xsl:otherwise>
		</xsl:choose>
		</div>
	
		<xsl:if test="string-length($binding-operation/@soapAction) &gt; 0">
			<div class="label">SOAP action:</div>
			<div class="value"><xsl:value-of select="$binding-operation/@soapAction" /></div>
		</xsl:if>
	
		<xsl:if test="$binding-operation/@location">
			<div class="label">HTTP path:</div>
			<div class="value"><xsl:value-of select="$binding-operation/@location" /></div>
		</xsl:if>
	</xsl:if>
	<xsl:apply-templates select="ws:input|ws:output|ws:fault" mode="operations.message">
		<xsl:with-param name="binding-data" select="$binding-info"/>
	</xsl:apply-templates>
</li>
</xsl:template>

<!--
==================================================================
	Rendering: WSDL operations - input, output, fault
==================================================================
-->
<xsl:template match="ws:input|ws:output|ws:fault" mode="operations.message">
	<xsl:param name="binding-data"/>
	<xsl:if test="$ENABLE-INOUTFAULT">
		<div class="label"><xsl:value-of select="concat(translate(substring(local-name(.), 1, 1), 'abcdefghijklmnoprstuvwxyz', 'ABCDEFGHIJKLMNOPRSTUVWXYZ'), substring(local-name(.), 2), ':')"/></div>
	
		<xsl:variable name="msg-local-name" select="substring-after(@message, ':')"/>
		<xsl:variable name="msg-name">
			<xsl:choose>
				<xsl:when test="$msg-local-name"><xsl:value-of select="$msg-local-name"/></xsl:when>
				<xsl:otherwise><xsl:value-of select="@message"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
	
		<xsl:variable name="msg" select="$consolidated-wsdl/ws:message[@name = $msg-name]"/>
		<xsl:choose>
			<xsl:when test="$msg">
				<xsl:apply-templates select="$msg" mode="operations.message">
					<xsl:with-param name="binding-data" select="$binding-data/ws:*[local-name(.) = local-name(current())]/*"/>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:otherwise><div class="value"><i>none</i></div></xsl:otherwise>
		</xsl:choose>
	</xsl:if>
</xsl:template>

<xsl:template match="ws:message" mode="operations.message">
	<xsl:param name="binding-data"/>
	<div class="value">
		<xsl:value-of select="@name"/>
		<xsl:if test="$binding-data">
			<xsl:text> (</xsl:text>
			<xsl:value-of select="name($binding-data)"/>
			<xsl:variable name="use" select="$binding-data/@use"/>
			<xsl:if test="$use"><xsl:text>, use = </xsl:text><xsl:value-of select="$use"/></xsl:if>
			<xsl:variable name="part" select="$binding-data/@part"/>
			<xsl:if test="$part"><xsl:text>, part = </xsl:text><xsl:value-of select="$part"/></xsl:if>
			<xsl:text>)</xsl:text>
		</xsl:if>
		<xsl:call-template name="render.source-code-link"/>
	</div>

	<xsl:apply-templates select="ws:part" mode="operations.message"/>
</xsl:template>

<xsl:template match="ws:part" mode="operations.message">
	<div class="value box" style="margin-bottom: 3px">
		<xsl:choose>
			<xsl:when test="string-length(@name) &gt; 0">
				<b><xsl:value-of select="@name"/></b>

				<xsl:variable name="elem-or-type">
					<xsl:choose>
						<xsl:when test="@type"><xsl:value-of select="@type"/></xsl:when>
						<xsl:otherwise><xsl:value-of select="@element"/></xsl:otherwise>
					</xsl:choose>
				</xsl:variable>

				<xsl:variable name="type-local-name" select="substring-after($elem-or-type, ':')"/>
				<xsl:variable name="type-name">
					<xsl:choose>
						<xsl:when test="$type-local-name"><xsl:value-of select="$type-local-name"/></xsl:when>
						<xsl:when test="$elem-or-type"><xsl:value-of select="$elem-or-type"/></xsl:when>
						<xsl:otherwise>unknown</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>

				<xsl:call-template name="render-type">
					<xsl:with-param name="type-local-name" select="$type-name"/>
				</xsl:call-template>

				<xsl:variable name="part-type" select="$consolidated-xsd[@name = $type-name and not(xsd:simpleType)][1]"/>
				<xsl:apply-templates select="$part-type" mode="operations.message.part"/>

			</xsl:when>
			<xsl:otherwise><i>none</i></xsl:otherwise>
		</xsl:choose>
	</div>
</xsl:template>


</xsl:stylesheet>

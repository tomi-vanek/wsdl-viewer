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
* wsdl-viewer-service.xsl
* Author: tomi vanek
* ====================================================================
* Description:
* 		Rendering of the service-level information
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

<xsl:template match="ws:service|ws2:service" mode="service-start">
	<div class="indent">
		<div class="label">Target Namespace:</div>
		<div class="value"><xsl:value-of select="$consolidated-wsdl/@targetNamespace" /></div>
		<xsl:apply-templates select="*[local-name(.) = 'documentation']" mode="documentation.render"/>
		<xsl:apply-templates select="ws:port|ws2:endpoint" mode="service"/>
	</div>
</xsl:template>

<!--
==================================================================
	Rendering: Service detail - WSDL 2.0
==================================================================
-->
<xsl:template match="ws2:endpoint" mode="service">
	<xsl:variable name="binding-name">
		<xsl:apply-templates select="@binding" mode="qname.normalized"/>
	</xsl:variable>
	<xsl:variable name="binding" select="$consolidated-wsdl/ws2:binding[@name = $binding-name]"/>

	<xsl:variable name="binding-type" select="$binding/@type"/>
	<xsl:variable name="binding-protocol" select="$binding/@*[local-name() = 'protocol']"/>
	<xsl:variable name="protocol">
		<xsl:choose>
			<xsl:when test="starts-with($binding-type, 'http://schemas.xmlsoap.org/wsdl/soap')">SOAP 1.1</xsl:when>
			<xsl:when test="starts-with($binding-type, 'http://www.w3.org/2005/08/wsdl/soap')">SOAP 1.2</xsl:when>
			<xsl:when test="starts-with($binding-type, 'http://schemas.xmlsoap.org/wsdl/mime')">MIME</xsl:when>
			<xsl:when test="starts-with($binding-type, 'http://schemas.xmlsoap.org/wsdl/http')">HTTP</xsl:when>
			<xsl:otherwise>Unknown</xsl:otherwise>
		</xsl:choose>

		<!-- TODO: Add all bindings to transport protocols -->
		<xsl:choose>
			<xsl:when test="starts-with($binding-protocol, 'http://www.w3.org/2003/05/soap/bindings/HTTP')"> over HTTP</xsl:when>
			<xsl:otherwise></xsl:otherwise>
		</xsl:choose>
	</xsl:variable>

	<div class="label">Location:</div>
	<div class="value"><xsl:value-of select="@address" /></div>

	<div class="label">Protocol:</div>
	<div class="value"><xsl:value-of select="$protocol"/></div>

	<xsl:apply-templates select="$binding" mode="service"/>

	<xsl:variable name="iface-name">
		<xsl:apply-templates select="../@interface" mode="qname.normalized"/>
	</xsl:variable>
	<xsl:apply-templates select="$consolidated-wsdl/ws2:interface[@name = $iface-name]" mode="service"/>

</xsl:template>

<xsl:template match="ws2:interface" mode="service">
	<h3>Interface <b><xsl:value-of select="@name" /></b>
<xsl:if test="$ENABLE-LINK">
<xsl:text> </xsl:text><small><xsl:if test="$ENABLE-OPERATIONS-PARAGRAPH"><a class="local" href="#{concat($PORT-PREFIX, generate-id(.))}"> <xsl:value-of select="$PORT-TYPE-TEXT"/></a></xsl:if> <xsl:call-template name="render.source-code-link"/></small>
</xsl:if>
</h3>

	<xsl:variable name="base-iface-name">
		<xsl:apply-templates select="@extends" mode="qname.normalized"/>
	</xsl:variable>

	<xsl:if test="$base-iface-name">
		<div class="label">Extends: </div>
		<div class="value"><xsl:value-of select="$base-iface-name"/></div>
	</xsl:if>

	<xsl:variable name="base-iface" select="$consolidated-wsdl/ws2:interface[@name = $base-iface-name]"/>

	<div class="label">Operations:</div>
	<div class="value"><xsl:text>
</xsl:text>
		<ol style="line-height: 180%;">
			<xsl:apply-templates select="$base-iface/ws2:operation | ws2:operation" mode="service">
				<xsl:sort select="@name"/>
			</xsl:apply-templates>
		</ol>
	</div>
</xsl:template>


<!--
==================================================================
	Rendering: Service detail - WSDL 1.1
==================================================================
-->
<xsl:template match="ws:port" mode="service">
	<xsl:variable name="binding-name">
		<xsl:apply-templates select="@binding" mode="qname.normalized"/>
	</xsl:variable>
	<xsl:variable name="binding" select="$consolidated-wsdl/ws:binding[@name = $binding-name]"/>

	<xsl:variable name="binding-uri" select="namespace-uri( $binding/*[local-name() = 'binding'] )"/>
	<xsl:variable name="protocol">
		<xsl:choose>
			<xsl:when test="starts-with($binding-uri, 'http://schemas.xmlsoap.org/wsdl/soap')">SOAP</xsl:when>
			<xsl:when test="starts-with($binding-uri, 'http://schemas.xmlsoap.org/wsdl/mime')">MIME</xsl:when>
			<xsl:when test="starts-with($binding-uri, 'http://schemas.xmlsoap.org/wsdl/http')">HTTP</xsl:when>
			<xsl:otherwise>unknown</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>

	<xsl:variable name="port-type-name">
		<xsl:apply-templates select="$binding/@type" mode="qname.normalized"/>
	</xsl:variable>

	<xsl:variable name="port-type" select="$consolidated-wsdl/ws:portType[@name = $port-type-name]"/>


	<h3>Port <b><xsl:value-of select="@name" /></b>
<xsl:if test="$ENABLE-LINK">
<xsl:text> </xsl:text><small><xsl:if test="$ENABLE-OPERATIONS-PARAGRAPH"><a class="local" href="#{concat($PORT-PREFIX, generate-id($port-type))}"> <xsl:value-of select="$PORT-TYPE-TEXT"/></a></xsl:if> <xsl:call-template name="render.source-code-link"/></small>
</xsl:if>
</h3>

	<div class="label">Location:</div>
	<div class="value"><xsl:value-of select="*[local-name() = 'address']/@location" /></div>

	<div class="label">Protocol:</div>
	<div class="value"><xsl:value-of select="$protocol"/></div>

	<xsl:apply-templates select="$binding" mode="service"/>

	<div class="label">Operations:</div>
	<div class="value"><xsl:text>
</xsl:text>
		<ol style="line-height: 180%;">
			<xsl:apply-templates select="$consolidated-wsdl/ws:portType[@name = $port-type-name]/ws:operation" mode="service">
				<xsl:sort select="@name"/>
			</xsl:apply-templates>
		</ol>
	</div>
</xsl:template>

<xsl:template match="ws:operation|ws2:operation" mode="service">
	<li><big><i><xsl:value-of select="@name"/></i></big>
<xsl:if test="$ENABLE-LINK">
		<xsl:if test="$ENABLE-OPERATIONS-PARAGRAPH"><a class="local" href="{concat('#', $OPERATIONS-PREFIX, generate-id(.))}">Detail</a></xsl:if> <xsl:call-template name="render.source-code-link"/>
</xsl:if>
	</li>
</xsl:template>

<xsl:template match="ws:binding|ws2:binding" mode="service">
	<xsl:variable name="real-binding" select="*[local-name() = 'binding']|self::ws2:*"/>

	<xsl:if test="$real-binding/@style">
		<div class="label">Default style:</div>
		<div class="value"><xsl:value-of select="$real-binding/@style" /></div>
	</xsl:if>


	<xsl:if test="$real-binding/@transport|$real-binding/*[local-name() = 'protocol']">
		<xsl:variable name="protocol" select="concat($real-binding/@transport, $real-binding/*[local-name() = 'protocol'])"/>
		<div class="label">Transport protocol:</div>
		<div class="value">
			<xsl:choose>
				<xsl:when test="$protocol = 'http://schemas.xmlsoap.org/soap/http'">SOAP over HTTP</xsl:when>
				<xsl:otherwise><xsl:value-of select="$protocol"/></xsl:otherwise>
			</xsl:choose>
		</div>
	</xsl:if>

	<xsl:if test="$real-binding/@verb">
		<div class="label">Default method:</div>
		<div class="value"><xsl:value-of select="$real-binding/@verb" /></div>
	</xsl:if>
</xsl:template>


</xsl:stylesheet>

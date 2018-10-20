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
* 		XSD rendered as a tree
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
	Rendering: XSD parsing and rendering
==================================================================
-->

<xsl:template match="xsd:simpleType" mode="operations.message.part"/>

<xsl:template name="recursion.should.continue">
	<xsl:param name="anti.recursion"/>
	<xsl:param name="recursion.label"/>
	<xsl:param name="recursion.count">1</xsl:param>
	<xsl:variable name="has.recursion" select="contains($anti.recursion, $recursion.label)"/>
	<xsl:variable name="anti.recursion.fragment" select="substring-after($anti.recursion, $recursion.label)"/>
	<xsl:choose>
		<xsl:when test="$recursion.count &gt; $ANTIRECURSION-DEPTH"/>

		<xsl:when test="not($ENABLE-ANTIRECURSION-PROTECTION) or string-length($anti.recursion) = 0 or not($has.recursion)">
			<xsl:text>1</xsl:text>
		</xsl:when>

		<xsl:otherwise>
			<xsl:call-template name="recursion.should.continue">
				<xsl:with-param name="anti.recursion" select="$anti.recursion.fragment"/>
				<xsl:with-param name="recursion.label" select="$recursion.label"/>
				<xsl:with-param name="recursion.count" select="$recursion.count + 1"/>
			</xsl:call-template>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="xsd:complexType" mode="operations.message.part">
	<xsl:param name="anti.recursion"/>

	<xsl:variable name="recursion.label" select="concat('[', @name, ']')"/>
	<xsl:variable name="recursion.test">
		<xsl:call-template name="recursion.should.continue">
			<xsl:with-param name="anti.recursion" select="$anti.recursion"/>
			<xsl:with-param name="recursion.label" select="$recursion.label"/>
		</xsl:call-template>
	</xsl:variable>

	<xsl:choose>
		<xsl:when test="string-length($recursion.test) != 0">
			<xsl:apply-templates select="*" mode="operations.message.part">
				<xsl:with-param name="anti.recursion" select="concat($anti.recursion, $recursion.label)"/>
			</xsl:apply-templates>
		</xsl:when>
		<xsl:otherwise>
			<small style="color:blue">
				<xsl:value-of select="$RECURSIVE"/>
			</small>
		</xsl:otherwise>
	</xsl:choose>

</xsl:template>

<xsl:template match="xsd:complexContent" mode="operations.message.part">
	<xsl:param name="anti.recursion"/>

	<xsl:apply-templates select="*" mode="operations.message.part">
		<xsl:with-param name="anti.recursion" select="$anti.recursion"/>
	</xsl:apply-templates>
</xsl:template>

<xsl:template match="xsd:complexType[descendant::xsd:attribute[ not(@*[local-name() = 'arrayType']) ]]" mode="operations.message.part">
	<xsl:param name="anti.recursion"/>
	<xsl:variable name="recursion.label" select="concat('[', @name, ']')"/>
	<xsl:variable name="recursion.test">
		<xsl:call-template name="recursion.should.continue">
			<xsl:with-param name="anti.recursion" select="$anti.recursion"/>
			<xsl:with-param name="recursion.label" select="$recursion.label"/>
		</xsl:call-template>
	</xsl:variable>

	<xsl:choose>
		<xsl:when test="string-length($recursion.test) != 0">
			<ul type="circle">
				<xsl:apply-templates select="*" mode="operations.message.part">
					<xsl:with-param name="anti.recursion" select="concat($anti.recursion, $recursion.label)"/>
				</xsl:apply-templates>
			</ul>
		</xsl:when>
		<xsl:otherwise>
			<small style="color:blue">
				<xsl:value-of select="$RECURSIVE"/>
			</small>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="xsd:restriction | xsd:extension" mode="operations.message.part">
	<xsl:param name="anti.recursion"/>
	<xsl:variable name="type-local-name" select="substring-after(@base, ':')"/>
	<xsl:variable name="type-name">
		<xsl:choose>
			<xsl:when test="$type-local-name"><xsl:value-of select="$type-local-name"/></xsl:when>
			<xsl:when test="@base"><xsl:value-of select="@base"/></xsl:when>
			<xsl:otherwise>unknown type</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:variable name="base-type" select="$consolidated-xsd[@name = $type-name][1]"/>
	<!-- xsl:if test="not($type/@abstract)">
		<xsl:apply-templates select="$type"/>
	</xsl:if -->
	<xsl:if test="$base-type != 'Array'">
		<xsl:apply-templates select="$base-type" mode="operations.message.part">
			<xsl:with-param name="anti.recursion" select="$anti.recursion"/>
		</xsl:apply-templates>
	</xsl:if>
	<xsl:apply-templates select="*" mode="operations.message.part">
		<xsl:with-param name="anti.recursion" select="$anti.recursion"/>
	</xsl:apply-templates>
</xsl:template>

<xsl:template match="xsd:union" mode="operations.message.part">
	<xsl:call-template name="process-union">
		<xsl:with-param name="set" select="@memberTypes"/>
	</xsl:call-template>
</xsl:template>

<xsl:template name="process-union">
	<xsl:param name="set"/>
	<xsl:if test="$set">
		<xsl:variable name="item" select="substring-before($set, ' ')"/>
		<xsl:variable name="the-rest" select="substring-after($set, ' ')"/>

		<xsl:variable name="type-local-name" select="substring-after($item, ':')"/>
		<xsl:variable name="type-name">
			<xsl:choose>
				<xsl:when test="$type-local-name"><xsl:value-of select="$type-local-name"/></xsl:when>
				<xsl:otherwise><xsl:value-of select="$item"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:call-template name="render-type">
			<xsl:with-param name="type-local-name" select="$type-name"/>
		</xsl:call-template>

		<xsl:call-template name="process-union">
			<xsl:with-param name="set" select="$the-rest"/>
		</xsl:call-template>
	</xsl:if>
</xsl:template>

<xsl:template match="xsd:sequence" mode="operations.message.part">
	<xsl:param name="anti.recursion"/>
	<ul type="square">
		<xsl:apply-templates select="*" mode="operations.message.part">
			<xsl:with-param name="anti.recursion" select="$anti.recursion"/>
		</xsl:apply-templates>
	</ul>
</xsl:template>

<xsl:template match="xsd:all|xsd:any|xsd:choice" mode="operations.message.part">
	<xsl:param name="anti.recursion"/>
	<xsl:variable name="list-type">
		<xsl:choose>
			<xsl:when test="self::xsd:all">disc</xsl:when>
			<xsl:when test="self::xsd:any">circle</xsl:when>
			<xsl:otherwise>square</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>

	<xsl:element name="ul">
		<xsl:attribute name="style">
			<xsl:value-of select="concat('list-style-type:', $list-type)"/>
		</xsl:attribute>
		<xsl:apply-templates select="*" mode="operations.message.part">
			<xsl:with-param name="anti.recursion" select="$anti.recursion"/>
		</xsl:apply-templates>
	</xsl:element>
</xsl:template>

<xsl:template match="xsd:element[parent::xsd:schema]" mode="operations.message.part">
	<xsl:param name="anti.recursion"/>
	<xsl:variable name="recursion.label" select="concat('[', @name, ']')"/>
	<xsl:variable name="recursion.test">
		<xsl:call-template name="recursion.should.continue">
			<xsl:with-param name="anti.recursion" select="$anti.recursion"/>
			<xsl:with-param name="recursion.label" select="$recursion.label"/>
		</xsl:call-template>
	</xsl:variable>

	<xsl:choose>
		<xsl:when test="string-length($recursion.test) != 0">
			<xsl:variable name="type-name"><xsl:call-template name="xsd.element-type"/></xsl:variable>
			<xsl:variable name="elem-type" select="$consolidated-xsd[generate-id() != generate-id(current()) and $type-name and @name=$type-name and contains(local-name(), 'Type')][1]"/>
	
			<xsl:if test="$type-name != @name">
				<xsl:apply-templates select="$elem-type" mode="operations.message.part">
					<xsl:with-param name="anti.recursion" select="concat($anti.recursion, $recursion.label)"/>
				</xsl:apply-templates>
	
				<xsl:if test="not($elem-type)">
					<xsl:call-template name="render-type">
						<xsl:with-param name="type-local-name" select="$type-name"/>
					</xsl:call-template>
				</xsl:if>
		
				<xsl:apply-templates select="*" mode="operations.message.part">
					<xsl:with-param name="anti.recursion" select="concat($anti.recursion, $recursion.label)"/>
				</xsl:apply-templates>
			</xsl:if>
		</xsl:when>
		<xsl:otherwise>
			<small style="color:blue">
				<xsl:value-of select="$RECURSIVE"/>
			</small>
		</xsl:otherwise>
	</xsl:choose>

</xsl:template>

<xsl:template match="xsd:element | xsd:attribute" mode="operations.message.part">
	<xsl:param name="anti.recursion"/>
<!--
	<xsl:variable name="recursion.label" select="concat('[', @name, ']')"/>
-->
	<li>
		<xsl:variable name="local-ref" select="concat(@name, substring-after(@ref, ':'))"/>
		<xsl:variable name="elem-name">
			<xsl:choose>
				<xsl:when test="@name"><xsl:value-of select="@name"/></xsl:when>
				<xsl:when test="$local-ref"><xsl:value-of select="$local-ref"/></xsl:when>
				<xsl:when test="@ref"><xsl:value-of select="@ref"/></xsl:when>
				<xsl:otherwise>anonymous</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:value-of select="$elem-name"/>

		<xsl:variable name="type-name"><xsl:call-template name="xsd.element-type"/></xsl:variable>

		<xsl:call-template name="render-type">
			<xsl:with-param name="type-local-name" select="$type-name"/>
		</xsl:call-template>

		<xsl:variable name="elem-type" select="$consolidated-xsd[@name = $type-name and contains(local-name(), 'Type')][1]"/>
		<xsl:apply-templates select="$elem-type | *" mode="operations.message.part">
			<xsl:with-param name="anti.recursion" select="$anti.recursion"/>
		</xsl:apply-templates>
	</li>
</xsl:template>

<xsl:template match="xsd:attribute[ @*[local-name() = 'arrayType'] ]" mode="operations.message.part">
	<xsl:param name="anti.recursion"/>
	<xsl:variable name="array-local-name" select="substring-after(@*[local-name() = 'arrayType'], ':')"/>
	<xsl:variable name="type-local-name" select="substring-before($array-local-name, '[')"/>
	<xsl:variable name="array-type" select="$consolidated-xsd[@name = $type-local-name][1]"/>

	<xsl:variable name="recursion.label" select="concat('[', $type-local-name, ']')"/>
	<xsl:variable name="recursion.test">
		<xsl:call-template name="recursion.should.continue">
			<xsl:with-param name="anti.recursion" select="$anti.recursion"/>
			<xsl:with-param name="recursion.label" select="$recursion.label"/>
		</xsl:call-template>
	</xsl:variable>

	<xsl:choose>
		<xsl:when test="string-length($recursion.test) != 0">
			<xsl:apply-templates select="$array-type" mode="operations.message.part">
				<xsl:with-param name="anti.recursion" select="concat($anti.recursion, $recursion.label)"/>
			</xsl:apply-templates>
		</xsl:when>
		<xsl:otherwise>
			<small style="color:blue">
				<xsl:value-of select="$RECURSIVE"/>
			</small>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template name="xsd.element-type">
	<xsl:variable name="ref-or-type">
		<xsl:choose>
			<xsl:when test="@type"><xsl:value-of select="@type"/></xsl:when>
			<xsl:otherwise><xsl:value-of select="@ref"/></xsl:otherwise>
		</xsl:choose>
	</xsl:variable>

	<xsl:variable name="type-local-name" select="substring-after($ref-or-type, ':')"/>
	<xsl:variable name="type-name">
		<xsl:choose>
			<xsl:when test="$type-local-name"><xsl:value-of select="$type-local-name"/></xsl:when>
			<xsl:when test="$ref-or-type"><xsl:value-of select="$ref-or-type"/></xsl:when>
			<xsl:otherwise>undefined</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:value-of select="$type-name"/>
</xsl:template>

<xsl:template match="xsd:documentation" mode="operations.message.part">
	<div style="color:green"><xsl:value-of select="." disable-output-escaping="yes"/></div>
</xsl:template>


<!--
==================================================================
	render-type
==================================================================
-->
<xsl:template name="render-type">
	<xsl:param name="anti.recursion"/>
	<xsl:param name="type-local-name"/>

	<xsl:if test="$ENABLE-OPERATIONS-TYPE">
		<xsl:variable name="properties">
			<xsl:if test="self::xsd:element | self::xsd:attribute[parent::xsd:complexType]">
				<xsl:variable name="min"><xsl:if test="@minOccurs = '0'">optional</xsl:if></xsl:variable>
				<xsl:variable name="max"><xsl:if test="@maxOccurs = 'unbounded'">unbounded</xsl:if></xsl:variable>
				<xsl:variable name="nillable"><xsl:if test="@nillable">nillable</xsl:if></xsl:variable>
	
				<xsl:if test="(string-length($min) + string-length($max) + string-length($nillable) + string-length(@use)) &gt; 0">
					<xsl:text> - </xsl:text>
					<xsl:value-of select="$min"/>
					<xsl:if test="string-length($min) and string-length($max)"><xsl:text>, </xsl:text></xsl:if>
					<xsl:value-of select="$max"/>
					<xsl:if test="(string-length($min) + string-length($max)) &gt; 0 and string-length($nillable)"><xsl:text>, </xsl:text></xsl:if>
					<xsl:value-of select="$nillable"/>
					<xsl:if test="(string-length($min) + string-length($max) + string-length($nillable)) &gt; 0 and string-length(@use)"><xsl:text>, </xsl:text></xsl:if>
					<xsl:value-of select="@use"/>
					<xsl:text>; </xsl:text>
				</xsl:if>
			</xsl:if>
		</xsl:variable>

		<xsl:variable name="recursion.label" select="concat('[', $type-local-name, ']')"/>
		<xsl:variable name="recursion.test">
			<xsl:call-template name="recursion.should.continue">
				<xsl:with-param name="anti.recursion" select="$anti.recursion"/>
				<xsl:with-param name="recursion.label" select="$recursion.label"/>
				<xsl:with-param name="recursion.count" select="$ANTIRECURSION-DEPTH"/>
			</xsl:call-template>
		</xsl:variable>

		<xsl:if test="string-length($recursion.test) != 0">
			<small style="color:blue">
				<xsl:value-of select="$properties"/>
				<xsl:variable name="elem-type" select="$consolidated-xsd[@name = $type-local-name and (not(contains(local-name(current()), 'element')) or contains(local-name(), 'Type'))][1]"/>
				<xsl:if test="string-length($type-local-name) &gt; 0">
					<xsl:call-template name="render-type.write-name">
						<xsl:with-param name="type-local-name" select="$type-local-name"/>
					</xsl:call-template>
				</xsl:if>

				<xsl:choose>
					<xsl:when test="$elem-type">

						<xsl:apply-templates select="$elem-type" mode="render-type">
							<xsl:with-param name="anti.recursion" select="concat($anti.recursion, $recursion.label)"/>
						</xsl:apply-templates>
					</xsl:when>
					<xsl:otherwise>

						<xsl:apply-templates select="*" mode="render-type">
							<xsl:with-param name="anti.recursion" select="concat($anti.recursion, $recursion.label)"/>
						</xsl:apply-templates>
					</xsl:otherwise>
				</xsl:choose>
			</small>
		</xsl:if>
	</xsl:if>
</xsl:template>

<xsl:template name="render-type.write-name">
	<xsl:param name="type-local-name"/>
	<xsl:text> type </xsl:text>
	<big><i>
		<xsl:choose>
			<xsl:when test="$type-local-name"><xsl:value-of select="$type-local-name"/></xsl:when>
			<xsl:otherwise>undefined</xsl:otherwise>
		</xsl:choose>
	</i></big>
</xsl:template>

<xsl:template match="*" mode="render-type"/>

<xsl:template match="xsd:element | xsd:complexType | xsd:simpleType | xsd:complexContent" mode="render-type">
	<xsl:param name="anti.recursion"/>
	<xsl:apply-templates select="*" mode="render-type">
		<xsl:with-param name="anti.recursion" select="$anti.recursion"/>
	</xsl:apply-templates>
</xsl:template>

<xsl:template match="xsd:restriction[ parent::xsd:simpleType ]" mode="render-type">
	<xsl:param name="anti.recursion"/>
	<xsl:variable name="type-local-name" select="substring-after(@base, ':')"/>
	<xsl:variable name="type-name">
		<xsl:choose>
			<xsl:when test="$type-local-name"><xsl:value-of select="$type-local-name"/></xsl:when>
			<xsl:when test="@base"><xsl:value-of select="@base"/></xsl:when>
			<xsl:otherwise>undefined</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>

	<xsl:text> - </xsl:text>
	<xsl:call-template name="render-type.write-name">
		<xsl:with-param name="type-local-name" select="$type-local-name"/>
	</xsl:call-template>
	<xsl:text> with </xsl:text>
	<xsl:value-of select="local-name()" />
	<xsl:apply-templates select="*" mode="render-type">
		<xsl:with-param name="anti.recursion" select="$anti.recursion"/>
	</xsl:apply-templates>
</xsl:template>

<xsl:template match="xsd:simpleType/xsd:restriction/xsd:*[not(self::xsd:enumeration)]" mode="render-type">
	<xsl:text> </xsl:text>
	<xsl:value-of select="local-name()"/>
	<xsl:text>(</xsl:text>
	<xsl:value-of select="@value"/>
	<xsl:text>)</xsl:text>
</xsl:template>

<xsl:template match="xsd:restriction | xsd:extension" mode="render-type">
	<xsl:param name="anti.recursion"/>
	<xsl:variable name="type-local-name" select="substring-after(@base, ':')"/>
	<xsl:variable name="type-name">
		<xsl:choose>
			<xsl:when test="$type-local-name"><xsl:value-of select="$type-local-name"/></xsl:when>
			<xsl:when test="@base"><xsl:value-of select="@base"/></xsl:when>
			<xsl:otherwise>undefined</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:variable name="base-type" select="$consolidated-xsd[@name = $type-name][1]"/>
	<xsl:variable name="abstract"><xsl:if test="$base-type/@abstract">abstract </xsl:if></xsl:variable>

	<xsl:if test="not($type-name = 'Array')">
		<xsl:value-of select="concat(' - ', local-name(), ' of ', $abstract)" />
		<xsl:call-template name="render-type.write-name">
			<xsl:with-param name="type-local-name" select="$type-name"/>
		</xsl:call-template>
	</xsl:if>

	<xsl:apply-templates select="$base-type | *" mode="render-type">
		<xsl:with-param name="anti.recursion" select="$anti.recursion"/>
	</xsl:apply-templates>
</xsl:template>

<xsl:template match="xsd:attribute[ @*[local-name() = 'arrayType'] ]" mode="render-type">
	<xsl:param name="anti.recursion"/>
	<xsl:variable name="array-local-name" select="substring-after(@*[local-name() = 'arrayType'], ':')"/>
	<xsl:variable name="type-local-name" select="substring-before($array-local-name, '[')"/>
	<xsl:variable name="array-type" select="$consolidated-xsd[@name = $type-local-name][1]"/>

	<xsl:text> - array of </xsl:text>
	<xsl:call-template name="render-type.write-name">
		<xsl:with-param name="type-local-name" select="$type-local-name"/>
	</xsl:call-template>

	<xsl:apply-templates select="$array-type" mode="render-type">
		<xsl:with-param name="anti.recursion" select="$anti.recursion"/>
	</xsl:apply-templates>
</xsl:template>

<xsl:template match="xsd:enumeration" mode="render-type"/>

<xsl:template match="xsd:enumeration[not(preceding-sibling::xsd:enumeration)]" mode="render-type">
	<xsl:text> - enum { </xsl:text>
	<xsl:apply-templates select="self::* | following-sibling::xsd:enumeration" mode="render-type.enum"/>
	<xsl:text> }</xsl:text>
</xsl:template>

<xsl:template match="xsd:enumeration" mode="render-type.enum">
	<xsl:if test="preceding-sibling::xsd:enumeration">
		<xsl:text>, </xsl:text>
	</xsl:if>
	<xsl:text disable-output-escaping="yes">&apos;</xsl:text>
	<xsl:value-of select="@value"/>
	<xsl:text disable-output-escaping="yes">&apos;</xsl:text>
</xsl:template>


</xsl:stylesheet>

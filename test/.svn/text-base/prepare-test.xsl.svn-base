<?xml version="1.0" encoding="UTF-8" ?>
<!--
 ! Licensed to the Apache Software Foundation (ASF) under one or more
 ! contributor license agreements.  See the NOTICE file distributed with
 ! this work for additional information regarding copyright ownership.
 ! The ASF licenses this file to You under the Apache License, Version 2.0
 ! (the "License"); you may not use this file except in compliance with
 ! the License.  You may obtain a copy of the License at
 !
 !      http://www.apache.org/licenses/LICENSE-2.0
 !
 ! Unless required by applicable law or agreed to in writing, software
 ! distributed under the License is distributed on an "AS IS" BASIS,
 ! WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 ! See the License for the specific language governing permissions and
 ! limitations under the License.
 !-->

<!--
	This XSLT script prepares an aget (Ant-script) in each test of the w3c test suite.
	The agent copies the tested wsdl-viewer.xsl into the tested directory
	and executes the transformation.
	The agent solution eliminates base-dir problems in Ant:
		Ant xslt tag works with base-dir for XSLT includes, but does not set the base-dir
		for processed XML's includes. This seems to be a bug in the Ant tag implementation.

	ChangeLog:

	2007-12-17 tomi vanek (tomi.vanek@gmail.com)
	- created

-->

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns:tm="http://www.w3.org/2006/02/wsdl/TestMetadata" exclude-result-prefixes="tm">

<xsl:output method="xml" version="1.0" encoding="utf-8" indent="yes" omit-xml-declaration="no" />

<xsl:strip-space elements="*"/>

<xsl:param name="timestamp"/>
<xsl:param name="woden.dir"/>
<xsl:param name="result.dir"/>

<xsl:variable name="test.name" select="substring-after(normalize-space(/*/tm:Identifier), 'test-suite/documents/')"/>


<!--
==================================================================
	Starting point
==================================================================
-->

<xsl:template match="/">
	<xsl:call-template name="header-comment.render"/>

	<project default="test" basedir=".">
		<property name="woden.dir" value="{$woden.dir}" />
		<property name="wsdl-viewer.xsl" value="wsdl-viewer.xsl"/>
		<property name="wsdl-viewer.dir" value="${{woden.dir}}/wsdl-viewer" />
		<property name="result.dir" location="{concat($result.dir, '/', $test.name)}" />
	
		<target name="test" description="{concat('## WSDL-viewer Test: ', normalize-space(/*/tm:Title), ' [', normalize-space(/*/tm:Identifier), ']')}">
			<copy todir="." file="${{wsdl-viewer.dir}}/${{wsdl-viewer.xsl}}"/>
			<xslt force="yes" style="${{wsdl-viewer.xsl}}" basedir="." includes="*.wsdl" destdir="${{result.dir}}" extension=".html" />
			<delete file="${{wsdl-viewer.xsl}}" quiet="true"/>
		</target>
	</project>
</xsl:template>


<!--
==================================================================
	Header comment
==================================================================
-->
<xsl:template name="header-comment.render">
	<xsl:comment><xsl:text> 
</xsl:text>
<xsl:value-of select="concat('This file was generated for w3c test &quot;', $test.name, '&quot; ')"/>
<xsl:if test="$timestamp"><xsl:value-of select="concat(' [', $timestamp, ']')"/></xsl:if>
<xsl:text>.
</xsl:text>
</xsl:comment>
</xsl:template>

</xsl:stylesheet>

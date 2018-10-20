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
* all-in-one.xsl
* Version: 1.0.00
*
* Author: tomi vanek
* ====================================================================
* Description:
* 		TODO
* ====================================================================
* ====================================================================
* History:
* 	2007-11-07 - Initial implementation
* ====================================================================
-->

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:output method="xml" version="1.0" encoding="utf-8" indent="yes" omit-xml-declaration="no" />


<!--
==================================================================
	Copy the file
==================================================================
-->
<xsl:template match="*|@*|processing-instruction()|text()">
	<xsl:copy>
		<xsl:apply-templates select="*|@*|processing-instruction()|text()|comment()"/>
	</xsl:copy>
</xsl:template>

<xsl:template match="comment()">
<xsl:text>

</xsl:text><xsl:copy-of select="."/>
<xsl:text>
</xsl:text>
</xsl:template>


<!--
==================================================================
	Copy the included content
==================================================================
-->
<xsl:template match="xsl:include">
	<xsl:call-template name="mark.render">
		<xsl:with-param name="text">Begin</xsl:with-param>
	</xsl:call-template>

	<xsl:copy-of select="document(@href)/*/*"/>

	<xsl:call-template name="mark.render">
		<xsl:with-param name="text">End</xsl:with-param>
	</xsl:call-template>
</xsl:template>

<!--
==================================================================
	Render a mark for beginning and ending the included block
==================================================================
-->
<xsl:template name="mark.render">
	<xsl:param name="text"/>
<xsl:variable name="local.line">
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
</xsl:variable>

<xsl:text>

</xsl:text>
<xsl:comment>
	<xsl:value-of select="concat($local.line, '    ', $text, ' of included transformation: ', @href, $local.line)"/>
</xsl:comment>
<xsl:text>
</xsl:text>
</xsl:template>


</xsl:stylesheet>
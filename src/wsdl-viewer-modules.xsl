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
* Version: 3.1.01
*
* URL: http://tomi.vanek.sk/xml/wsdl-viewer.xsl
*
* Author: tomi vanek
* Inspiration: Uche Ogbui - WSDL processing with XSLT
* 		http://www-106.ibm.com/developerworks/library/ws-trans/index.html
* ====================================================================
-->

<!--
* ====================================================================
* Description:
* 		wsdl-viewer.xsl is a lightweight XSLT 1.0 transformation with minimal
* 		usage of any hacks that extend the possibilities of the transformation
* 		over the XSLT 1.0 constraints but eventually would harm the engine independance.
*
* 		The transformation has to run even in the browser offered XSLT engines
* 		(tested in IE 6 and Firefox) and in ANT "batch" processing.
* ====================================================================
* How to add the HTML look to a WSDL:
* 		<?xml version="1.0" encoding="utf-8"?>
* 		<?xml-stylesheet type="text/xsl" href="wsdl-viewer.xsl"?>
* 		<wsdl:definitions ...>
* 		    ... Here is the service declaration
* 		</wsdl:definitions>
*
* 		The web-browsers (in Windows) are not able by default automatically recognize
* 		the ".wsdl" file type (suffix). For the type recognition the WSDL file has
* 		to be renamed by adding the suffix ".xml" - i.e. "myservice.wsdl.xml".
* ====================================================================
* Constraints:
* 	1. Processing of imported files
* 		1.1 Only 1 imported WSDL and 1 imported XSD is processed
* 			(well, maybe with a smarter recursive strategy this restriction could be overcome)
* 		1.2 No recursive including is supported (i.e. includes in included XSD are ignored)
* 	2. Namespace support
* 		2.1 Namespaces are not taken in account by processing (references with NS)
* 	3. Source code
* 		3.1 Only the source code allready processed by the XML parser is rendered - implications:
* 			== no access to the XML head line (<?xml version="1.0" encoding="utf-8"?>)
* 			== "expanded" CDATA blocks (parser processes the CDATA,
* 				XSLT does not have access to the original code)
* 			== no control over the code page
* 			== processing of special characters
* 			== namespace nodes are not rendered (just the namespace aliases)
* ====================================================================
* Possible improvements:
* 	* Functional requirements
* 		+ SOAP 1.2 binding (http://schemas.xmlsoap.org/wsdl/soap12/WSDL11SOAP12.pdf)
* 		+ WSDL 2.0 (http://www.w3.org/TR/2006/CR-wsdl20-primer-20060327/)
* 		+ Recognition of WSDL patterns (interface, binding, service instance, ...)
* 		- Creating an xsd-viewer.xsl for XML-Schema file viewing
* 			(extracting the functionality from wsdl-viewer into separate XSLT)
* 		- Check the full support of the WSDL and XSD going through the standards
* 		- Real-world WSDL testing
* 		- XSLT 2.0 (http://www-128.ibm.com/developerworks/library/x-xslt20pt5.html) ???
* 		? Adding more derived information
* 			* to be defined, what non-trivial information can we read out from the WSDL
* 	* XSLT
* 		+ Modularization
* 			- Is it meaningful?
* 			- Maybe more distribution alternatives (modular, fat monolithic, thin performance monolithic)?
* 			- Distribution build automatization
* 		+ Dynamic page: JavaSript
* 		+ Performance
* 		- Better code comments / documentation
* 		- SOAP client form - for testing the web service (AJAX based)
* 		- New XSD parser - clean-up the algorithm
* 		- Complete (recursive, multiple) include support
* 		? Namespace-aware version (no string processing hacks ;-)
* 			* I think, because of the goal to support as many engines as possible,
* 				this requirement is unrealistic. Maybe when XSLT 2.0 will be supported
* 				in a huge majority of platforms, we can rethink this point....
* 				(problems with different functionality of namespace-uri XPath function by different engines)
* 	* Development architecture
* 		- Setup of the development infrastructure
* 		- Unit testing
* 		? Collaboration platform
* 	* Documentation, web
* 		- Better user guide
* 		? Forum, Wiki
* ====================================================================
-->

<!--
* ====================================================================
* History:
* 	2005-04-15 - Initial implementation
* 	2005-09-12 - Removed xsl:key to be able to use the James Clark's XT engine on W3C web-site
* 	2006-10-06 - Removed the Oliver Becker's method of conditional selection
* 				of a value in a single expression (in Xalan/XSLTC this hack does not work!)
* 	2005-10-07 - Duplicated operations
* 	2006-12-08 - Import element support
* 	2006-12-14 - Displays all fault elements (not just the first one)
* 	2006-12-28 - W3C replaced silently the James Clark's XT engine with Michael Kay's closed-source Saxon!
* 				wsdl-viewer.xsl will no longer support XT engine
* 	2007-02-28 - Stack-overflow bug (if the XSD element @name and @type are identic)
* 	2007-03-08 - 3.0.00 - New parsing, new layout
* 	2007-03-28 - 3.0.01 - Fix: New anti-recursion defense (no error message by recursion
* 						because of dirty solution of namespace processing)
* 						- Added: variables at the top to turn on/off certain details
* 	2007-03-29 - 3.0.02 - Layout clean-up for IE
* 	2007-03-29 - 3.0.03 - Fix: Anti-recursion algorithm
* 	2007-03-30 - 3.0.04 - Added: source code rendering of imported WSDL and XSD
* 	2007-04-15 - 3.0.05 - Fix: Recursive calls in element type rendering
* 						- Fix: Rendering of messages (did not render the message types of complex types)
* 						- Fix: Links in src. by arrays
* 						- Fix: $binding-info
* 	2007-04-15 - 3.0.06 - Added: Extended rendering control ENABLE-xxx parameters
* 						- Changed: Anti-recursion algorithm has recursion-depth parameter
* 	2007-07-19 - 3.0.07 - Fix: Rendering of array type in detail
* 	2007-08-01 - 3.0.08 - Fix: xsl:template name="render-type"
* 						  Fix: typo - "Impotred WSDL" should be "Impotred WSDL"
* 	2007-08-16 - 3.0.09 - Fix: xsl:template name="render-type" - anti recursion
* 	2007-12-05 - 3.1.00 - Modularized
* 	2007-12-23 - 3.1.01 - Terminating message by WS without interface or service definition was removed
* 						  (seems to be a correct state)
* 	2008-08-20 - 3.1.02 - Woden-214: Anti-recursion bypassed in xsd:choice element
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

<xsl:output method="xml" version="1.0" encoding="utf-8" indent="no"
	omit-xml-declaration="no" media-type="text/html"
	doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"
    doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN" />

<xsl:strip-space elements="*" />

<xsl:param name="wsdl-viewer.version">3.1.01</xsl:param>

<xsl:include href="wsdl-viewer-global.xsl"/>
<xsl:include href="wsdl-viewer-css.xsl"/>

<xsl:include href="wsdl-viewer-util.xsl"/>
<xsl:include href="wsdl-viewer-service.xsl"/>
<xsl:include href="wsdl-viewer-operations.xsl"/>
<xsl:include href="wsdl-viewer-xsd-tree.xsl"/>
<xsl:include href="wsdl-viewer-src.xsl"/>


<!--
==================================================================
	Starting point
==================================================================
-->
<xsl:template match="/">
	<html>
		<xsl:call-template name="head.render"/>
		<xsl:call-template name="body.render"/>
	</html>
</xsl:template>

<!--
==================================================================
	Rendering: HTML head
==================================================================
-->
<xsl:template name="head.render">
<head>
	<title><xsl:value-of select="concat($html-title, ' - ', 'Generated by wsdl-viewer.xsl')" /></title>
	<meta http-equiv="content-type" content="text/html; charset=utf-8" />
	<meta http-equiv="content-script-type" content="text/javascript" />
	<meta http-equiv="content-style-type" content="text/css" />
	<meta name="Generator" content="http://tomi.vanek.sk/xml/wsdl-viewer.xsl" />

	<meta http-equiv="imagetoolbar" content="false" />
	<meta name="MSSmartTagsPreventParsing" content="true" />

	<style type="text/css"><xsl:value-of select="$css" disable-output-escaping="yes" /></style>

	<script src="wsdl-viewer.js" type="text/javascript" language="javascript"> <xsl:comment><xsl:text>
	// </xsl:text></xsl:comment>
	</script>
</head>
</xsl:template>

<!--
==================================================================
	Rendering: HTML body
==================================================================
-->
<xsl:template name="body.render">
<body id="operations"><div id="outer_box"><div id="inner_box" onload="pagingInit()">
	<xsl:call-template name="title.render"/>
<!-- TODO: pages with tabs for selecting some aspect of the WSDL
	<xsl:call-template name="navig.render"/>
-->
	<xsl:call-template name="content.render"/>
	<xsl:call-template name="footer.render"/>
</div></div></body>
</xsl:template>

<!--
==================================================================
	Rendering: heading
==================================================================
-->
<xsl:template name="title.render">
	<div id="header">
		<h1><xsl:value-of select="$html-title"/></h1>
	</div>
</xsl:template>

<!--
==================================================================
	Rendering: navigation
==================================================================
-->
<xsl:template name="navig.render">
<div id="outer_nav">
	<div id="nav" class="floatcontainer">
		<ul>
			<li id="nav-service"><a href="#page.service">Service</a></li>
			<li id="nav-operations"><a href="#page.operations">Operations</a></li>
			<li id="nav-wsdl"><a href="#page.src">Source Code</a></li>
<!--			<li id="nav-client"><a href="#TODO-1">Client</a></li>
-->
			<li id="nav-about"><a href="#page.about" class="current">About</a></li>
		</ul>
	</div>
</div>
</xsl:template>

<!--
==================================================================
	Rendering: content
==================================================================
-->
<xsl:template name="content.render">
<div id="content">
	<xsl:if test="$ENABLE-SERVICE-PARAGRAPH">
		<xsl:call-template name="service.render"/>
	</xsl:if>
	<xsl:if test="$ENABLE-OPERATIONS-PARAGRAPH">
		<xsl:call-template name="operations.render"/>
	</xsl:if>
	<xsl:if test="$ENABLE-SRC-CODE-PARAGRAPH">
		<xsl:call-template name="src.render"/>
	</xsl:if>
	<xsl:if test="$ENABLE-ABOUT-PARAGRAPH">
		<xsl:call-template name="about.render">
			<xsl:with-param name="version" select="$wsdl-viewer.version" />
		</xsl:call-template>
	</xsl:if>
</div>
</xsl:template>

<!--
==================================================================
	Rendering: footer
==================================================================
-->
<xsl:template name="footer.render">
<div id="footer">
	This page was generated by wsdl-viewer.xsl (<a href="http://tomi.vanek.sk">http://tomi.vanek.sk</a>)
</div>
</xsl:template>

<!--
==================================================================
	Rendering: WSDL service information
==================================================================
-->
<xsl:template name="service.render">
<div class="page">
	<a class="target" name="page.service">
		<h2><xsl:value-of select="$html-title"/></h2>
	</a>
	<xsl:apply-templates select="$consolidated-wsdl/*[local-name(.) = 'documentation']" mode="documentation.render"/>
	<xsl:apply-templates select="$consolidated-wsdl/ws:service|$consolidated-wsdl/ws2:service" mode="service-start"/>
	<xsl:if test="not($consolidated-wsdl/*[local-name() = 'service']/@name)">
		<!-- If the WS is without implementation, just with binding points = WS interface -->
		<xsl:apply-templates select="$consolidated-wsdl/ws:binding" mode="service-start"/>
		<xsl:apply-templates select="$consolidated-wsdl/ws2:interface" mode="service"/>
	</xsl:if>
</div>
</xsl:template>

<!--
==================================================================
	Rendering: WSDL operations - detail
==================================================================
-->
<xsl:template name="operations.render">
<div class="page">
	<a class="target" name="page.operations">
		<h2>Operations</h2>
	</a>
	<ul>
		<xsl:apply-templates select="$consolidated-wsdl/ws:portType" mode="operations">
			<xsl:sort select="@name"/>
		</xsl:apply-templates>

		<xsl:choose>
			<xsl:when test="$consolidated-wsdl/*[local-name() = 'service']/@name">
				<xsl:variable name="iface-name">
					<xsl:apply-templates select="$consolidated-wsdl/*[local-name() = 'service']/@interface" mode="qname.normalized"/>
				</xsl:variable>
				<xsl:apply-templates select="$consolidated-wsdl/ws2:interface[@name = $iface-name]" mode="operations">
					<xsl:sort select="@name"/>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:when test="$consolidated-wsdl/ws2:interface/@name">
				<!-- TODO: What to do if there are more interfaces? -->
				<xsl:apply-templates select="$consolidated-wsdl/ws2:interface[1]" mode="operations"/>
			</xsl:when>
			<xsl:otherwise>
				<!-- TODO: Error message or handling somehow this unexpected situation -->
			</xsl:otherwise>
		</xsl:choose>
	</ul>
</div>
</xsl:template>

<!--
==================================================================
	Rendering: WSDL and XSD source code files
==================================================================
-->
<xsl:template name="src.render">
<div class="page">
	<a class="target" name="page.src">
		<h2>WSDL source code</h2>
	</a>
	<div class="box">
		<div class="xml-proc">
			<xsl:text>&lt;?xml version=&quot;1.0&quot;?&gt;</xsl:text>
		</div>
		<xsl:apply-templates select="/" mode="src"/>
	</div>

	<xsl:apply-templates select="/*/*[local-name() = 'import'][@location]/@location" mode="src.import"/>
	<xsl:apply-templates select="$consolidated-wsdl/*[local-name() = 'types']//xsd:import[@schemaLocation]/@schemaLocation | $consolidated-wsdl/*[local-name() = 'types']//xsd:include[@schemaLocation]/@schemaLocation" mode="src.import"/>
</div>
</xsl:template>

<!--
==================================================================
	Rendering: About
==================================================================
-->
<xsl:template name="about.render">
<xsl:param name="version"/>
<div class="page">
	<a class="target" name="page.about">
		<h2>About <em>wsdl-viewer.xsl</em></h2>
	</a>
	<div class="floatcontainer">
		<div id="fix_column">
		<div class="shadow"><div class="box">
			<xsl:call-template name="processor-info.render"/>
		</div></div>
		</div>
	
		<div id="flexi_column">
			<xsl:call-template name="about.detail">
				<xsl:with-param name="version" select="$wsdl-viewer.version"/>
			</xsl:call-template>
		</div>
	</div>
</div>
</xsl:template>


</xsl:stylesheet>

# wsdl-viewer

Tool to visualize web-service in an intuitive way.

Example HTML documentation for [simple example service](http://services.w3.org/xslt?xslfile=http://tomi.vanek.sk/xml/wsdl-viewer.xsl&xmlfile=http://www.dneonline.com/calculator.asmx?wsdl) generated by _vsdl-viewer_.

You can see your WSDL rendered by _wsdl-viewer_ using a form on [http://tomi.vanek.sk](http://tomi.vanek.sk).

WSDL has its constructive logic, but it is hard to read / understand the content by business professionals (mostly non-programmers). Here is a small tool to visualize the web-service in a more intuitive way and to generate human-readable documentation. I developed this transformation for WSDL interface analysis of a complex system.

## How to use _wsdl-viewer_

### 1) Online generated documentation

A smart composite URL uses the [W3C XSLT service](https://www.w3.org/2001/05/xslt) to generate the documentation for your WSDL. URL is constructed from

* service address `http://services.w3.org/xslt`
* wsdl-viewer xslt address `?xslfile=http://tomi.vanek.sk/xml/wsdl-viewer.xsl`
* and the WSDL address `&xmlfile=URL_OF_YOUR_WSDL`

Example URL for the online transformation:

[http://services.w3.org/xslt?xslfile=http://tomi.vanek.sk/xml/wsdl-viewer.xsl&xmlfile=http://www.dneonline.com/calculator.asmx?wsdl](http://services.w3.org/xslt?xslfile=http://tomi.vanek.sk/xml/wsdl-viewer.xsl&xmlfile=http://www.dneonline.com/calculator.asmx?wsdl)

### 2) Stylesheet link in WSDL

An elegant option is to add the userfriendly face directly into the WSDL. This way by opening the WSDL in a browser the transformation prepares on-fly the HTML view. This requires just this changes in WSDL: The WSDL is just an XML, so adding a processing instruction can suggest the browser to use on-fly the XSLT to convert the WSDL into a human-readable HTML page. Example of the instruction:

``` xml
<?xml version="1.0" encoding="utf-8"?>
<?xml-stylesheet type="text/xsl" href="wsdl-viewer.xsl"?>

<wsdl:definitions ...>
    <!-- ... Here is the service declaration ... -->
</wsdl:definitions>
```

Of course in this case the XSLT is placed in the same directory as the WSDL. You can define also an absolute URL (i.e. `<?xml-stylesheet type="text/xsl" href="http://tomi.vanek.sk/xml/wsdl-viewer.xsl"?>`).

Some legacy web-browsers are not able by default automatically recognize the .wsdl file type (suffix). For the type recognition the WSDL file has to be renamed by adding the suffix .xml - i.e. myservice.wsdl.xml.

### 3) Command-line or batch execution of XSLT

A set of WSDL-s can be converted into web pages (HTML) from command line or in a batch process (i.e. an ANT script, that has native XSLT support).

## Development

Version 3.1.xx has support for WSDL 2.0 and modularization for better development / maintenance.

The modular XSLT is in folder `src`, the build script in `build` folder uses the [Apache Ant](https://ant.apache.org/) build tool to create single-file XSLT and a distribution ZIP file.

## Credits

* The transformation was inspired by an article of _Uche Ogbuji: WSDL processing with XSLT_.
* The use of XSLT service from W3C is inspired by an idea in _CapeScience.com_.
* The WSDL Viewer was included in the WSDL parser [Apache Woden](https://ws.apache.org/woden/)
* Author's page about the `vsdl-viewer` tool: [tomi.vanek.sk](http://tomi.vanek.sk/)

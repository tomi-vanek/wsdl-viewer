# wsdl-viewer

Tool to visualize web-service in an intuitive way.

WSDL has its constructive logic, but it is hard to read / understand the content by business professionals (mostly non-programmers). Here is a small tool to visualize the web-service in a more intuitive way. I developed this transformation for WSDL interface analysis (to understand the service business functionality).

You can test the viewer on [http://tomi.vanek.sk](http://tomi.vanek.sk).

I hope you will find the transformation useful.

## Usage

A set of WSDL-s can be converted into web pages (HTML) in a batch process (i.e. an ANT script, that has native XSLT support).

Another elegant option is to add the userfriendly face directly into the WSDL. This way by opening the WSDL in a browser the transformation prepares on-fly the HTML view. This requires just this changes in WSDL:

The WSDL is just an XML. Adding a processing instruction can suggest the browser to use on-fly our XSLT to convert the WSDL into a "nicer" HTML page. Example of the instruction:

``` xml
<?xml version="1.0" encoding="utf-8"?>
<?xml-stylesheet type="text/xsl" href="wsdl-viewer.xsl"?>

<wsdl:definitions ...>
    <!-- ... Here is the service declaration ... -->
</wsdl:definitions>
```

Of course in this case the XSLT is placed in the same directory as the WSDL. You can define also an absolute URL (i.e. `<?xml-stylesheet type="text/xsl" href="http://tomi.vanek.sk/xml/wsdl-viewer.xsl"?>`).

Some legacy web-browsers are not able by default automatically recognize the .wsdl file type (suffix). For the type recognition the WSDL file has to be renamed by adding the suffix .xml - i.e. myservice.wsdl.xml.

## Build

Version 3.1.xx has support for WSDL 2.0 and modularization for better development / maintenance.

The modular XSLT is in folder `src`, the build script in `build` folder uses the [Apache Ant](https://ant.apache.org/) build tool to create single-file XSLT and a distribution ZIP file.

## Credits

The transformation was inspired by an article of _Uche Ogbuji: WSDL processing with XSLT_.
The use of XSLT service from W3C is inspired by an idea in _CapeScience.com_.
Author's page about the `vsdl-viewer` tool: [tomi.vanek.sk](http://tomi.vanek.sk/)

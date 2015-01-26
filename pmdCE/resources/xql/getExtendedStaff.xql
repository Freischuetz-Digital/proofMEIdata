xquery version "3.0";

declare namespace request="http://exist-db.org/xquery/request";
declare namespace mei="http://www.music-encoding.org/ns/mei";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace xmldb="http://exist-db.org/xquery/xmldb";
declare namespace system="http://exist-db.org/xquery/system";
declare namespace transform="http://exist-db.org/xquery/transform";

declare option exist:serialize "method=xml media-type=text/plain omit-xml-declaration=yes indent=yes";


let $path := request:get-parameter('path', '')
let $staffID := request:get-parameter('staffID', '')
let $id_prefix := request:get-parameter('id_prefix', '')
let $xslbase := concat(replace(system:get-module-load-path(), 'embedded-eXist-server', ''), '/../xsl/')


let $doc := doc('/db/apps/controlevents-data/' || $path)

let $snippet := transform:transform($doc, doc($xslbase || 'stripPage2staff.xsl'), <parameters><param name="staffID" value="{$staffID}"/><param name="id_prefix" value="{$id_prefix}"/></parameters>)
let $preparedSnippet := transform:transform($snippet, doc($xslbase || 'prepareRendering.xsl'), <parameters></parameters>)

return 
    $preparedSnippet